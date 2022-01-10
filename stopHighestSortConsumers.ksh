
#!/usr/bin/ksh
. $HOME/sqllib/db2profile
#-------------------------------------------------------------------------------
# (C) COPYRIGHT International Business Machines Corp. 2004
# All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
# NAME: stopHighestSortConsumers.ksh
#
# FUNCTION: Find the highest sort consumers and force those application off which
#           can potentially cause paging on the system.
#
# The script is provided to you on an "AS IS" basis, without warranty of
# any kind. IBM HEREBY EXPRESSLY DISCLAIMS ALL WARRANTIES, EITHER EXPRESS OR
# IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. Some jurisdictions do
# not allow for the exclusion or limitation of implied warranties, so the above
# limitations or exclusions may not apply to you. IBM shall not be liable for
# any damages you suffer as a result of using, copying, modifying or
# distributing the Sample, even if IBM has been advised of the possibility of
# such damages.
#
#
# The main program logic works as follows:
#  a) User sets server threshold by using the -S option ( default its set to 1GB x number of partitions per server )
#  b) User also has flexibility of killing how many apphandles when the server threshold is breached
#     using -t option (default: 5 )
#   Script converts the threshold set by user to per partition and then issues the SQL query to check if for one partition
#   total sort memory crosses the threshold.
#   If yes: kill the <n> top consumers of sort memory where <n> is set by user or defaults to 5 and then exit.
#   If no:
#         If user wants to check sub-sections per query, check if any apphandle is breaching the sub-section
#         threshold AND application sort memory threshold. If yes, force it off.
#         If no, check for the application threshold per apphandle
#   If apphandle threshold breached, kill the apphandles breaching the threshold and then exit
#   If the threshold is not breached, don't do anything
#
# Script should be scheduled to run every <x> mins through cron and preferably on the co-ordinator node.
# Script creates a few files and it purges them every 2 hours ( by default) and can be adjusted using
# the -p option. If you want to investigate the event later, it would be advisable to move the files
# to another archive dir.
#
# Author: Rajib Sarkar (rsarkar@us.ibm.com), Krishna ( krishnamurthy.a@in.ibm.com )
#
# September 29th, 2014:
# Changed logic to have 2 threshold checks.
#  a) Sort memory consumed on the whole physical server
#  b) Sort memory consumed by an application handle per partition
#
# January 9th, 2015:
# Additions:

# Added another threshold check for number of sub-sections AND sort memory usage per apphandle.
# ( Note: It'll get only the apphandles which have greater than configured sub-sections and sort
#         memory usage per apphandle. This was done to avoid killing queries which have large number
#         of sub-sections but are not consuming that much of sort memory.  Also, its not ON by default
#         This feature will turn on only if the user uses the -e option and provides a number)
#
# Added timeout code for global snapshot for application. Default is 20 seconds. If it does not return
# within that time, it'll switch to local snapshot and collect db2pd info and force the apphandles ( if -m 0 is set )
#
# May 26th 2015:
#  Fixed issue where the memory_pool_used should be treated in KB in v9.7FP10+ and v10.1+
#
###############################################################################################################################

trap 'rmdir $HOME/.`basename $0`' 1 2 15
trap 'rmdir $HOME/.`basename $0`; timeout_handler' USR1

# We expect DB2INSTANCE variable is set
if [ -z "$DB2INSTANCE" ]; then
  echo "DB2INSTANCE environment variable is not set."
  error_exit 1 DB2INSTANCE_not_set
fi

# An easy way to find out the home directory
# of DB2INSTANCE
INSTHOME=~${DB2INSTANCE}
eval INSTHOME=$INSTHOME

typeset -f SORTMEM_APPHANDLE
typeset -f SORTMEM_SERVER
typeset -f PURGETIME
typeset -i SUBSECTIONS
typeset -i TIMEOUT
DBNAME=""
PARTITION=""
MANUAL=1
OUTPUTDIR="."
SORTMEM_APPHANDLE=.5
SORTMEM_SERVER=""
PURGETIME=2
DB2VERSIONV10ANDHIGHER=0
NUMBEROFPARTITIONS=0
TOPCONSUMERS=5
TIMEOUT=20
SUBSECTIONS=""
LOGFILE=sortheapUsage.log

############################
## usage()
############################

usage()
{
    prog=`basename $0`
    echo "Usage: $prog -d <dbname> -n <node number> [ -o <outputdir> -s <sortmem_apph> -S <sortmem_server>"
    echo "                                                                   -t <top> -m <1|0> -p <time_in_hours>"
    echo "                                                                   -i <timeout_in_secs> ]"
    echo "-d <dbname>       -- Database name"
    echo "-n <nodenum>      -- Node number"
    echo "-s <sortmem_apph> -- Check for any apphandle using more than this sort memory. Unit is GB ( Default: 0.5GB)"
    echo "-S <sortmem_serv> -- Check for sort memory used on the server ( Default: 1GB x number of logical partitions )"
    echo "-t <top>          -- If server threshold is breached remove this many sort consumers ( default: 5)"
    echo "-m <0|1>          -- If set to 1 ( default ), program will just identify the sort consumer, user has to"
    echo "                     force the application(s) manually. If set to 0, the program will do that automatically"
    echo "-o <outputdir>    -- Output directory ( Default: current directory )"
    echo "-i <timeout>      -- Set the timeout value for global application snapshot ( default: 20 seconds )"
    echo "-e <num_subsect>  -- Set the threshold number of sections in a query ( default: none )"
    echo "-p <time_in_hour> -- Purge the older files ( Default: purge files older than 2 hours )"
    echo "\nNote: It is advised that this program is run in manual mode ( -m 1 ) for some time to confirm that its"
    echo "identifying the right application handles. Once that is confirmed, it can be run in auto mode ( -m 0 )\n"
    exit 0
}

###########################################################
## log_it
###########################################################

log_it()
{
  if [ "x$LOGFILE" != "x" ];then
      echo "`date`: " $* >> $OUTPUTDIR/$LOGFILE
  else
      echo "`date`: " $*
  fi
}

##########################################################
# error_exit
##########################################################

error_exit()
{
    rc=$1
    details=$2
    progname=$3
    typeset exit_code="${rc:-1}"
    log_it "Error return code $exit_code ( $details )"
    echo "!! `date`: Error return code $exit_code ( $details ) !!"
    rmdir $HOME/.$progname
    usage
}

###########################################################
# timeout_handler
# Function to handle the timeout of a global snapshot
###########################################################

timeout_handler()
{
    log_it "!!TIMEOUT!! Timeout ( $TIMEOUT seconds ) happened while running global snapshot. Switching to db2pd and local snapshots"

    timeoutstamp=`date "+%Y%m%d_%H%M%S"`
    HOST=`hostname -s`

    db2pd -db $DBNAME -alldbp -apinfo all > $outputdir/localDb2pd_apinfo_TIMEOUT.$HOST.$timeoutstamp

    db2 get snapshot for applications on $DBNAME > $outputdir/localSnapshot_app_TIMEOUT.$HOST.$timeoutstamp

    db2pd -db $DBNAME -alldbp -application > $outputdir/localDb2pd_appl_TIMEOUT.$HOST.$timeoutstamp

    if [ -s $outputdir/sortServerBreachApphandle.$partition.txt.$tstamp ]; then
        cat $outputdir/sortServerBreachApphandle.$partition.txt.$tstamp | /usr/bin/perl -ne 'if( /\d+-\d+-\d+-\d+\./ ){ @arr = split(/\s+/, $_); print "$arr[4],$arr[5]\n"; }' | while read rec
        do
            apphandle=`echo $rec   | cut -d"," -f1`
            sortMemUsed=`echo $rec | cut -d"," -f2`

            log_it "(TIMEOUT:Server breach): Apphdl: $apphandle, Sort mem used per partition : $sortMemUsed"
            if [ "x$manual" = "x0" ];then
               cmd=`echo "call sysproc.admin_cmd( 'force application( $APPHDLS )' )"`
               log_it "(TIMEOUT:Server breach): Issuing FORCE APPLICATION using the command: $cmd"
               db2 "$cmd"
            elif [ "x$manual" = "x1" ];then
               cmd=`echo "call sysproc.admin_cmd( 'force application( $APPHDLS )' )"`
               log_it "\n(TIMEOUT:Server breach:)Verify the application(s) and then issue the following FORCE APPLICATION command:\n\n$cmd\n"
            fi
        done
    fi

    if [ -s $outputdir/numSubSectionsPerApphandle.$partition.txt.$tstamp ];then

        cat $outputdir/numSubSectionsPerApphandle.$partition.txt.$tstamp | /usr/bin/perl -ne 'if( /\d+-\d+-\d+-\d+\./ ){ @arr = split(/\s+/, $_); print "$arr[4],$arr[5],$arr[6]\n"; }' | while read rec
        do
            apphandle=`echo $rec   | cut -d"," -f1`
            sortMemUsed=`echo $rec | cut -d"," -f2`
            numSubSections=`echo $rec | cut -d"," -f3`

            log_it "(TIMEOUT:Subsect_Appl breach): Apphdl: $apphandle, Sort mem used per partition : $sortMemUsed, Number of sub-sections: $numSubSections( check is for $subsections )"

            if [ "x$manual" = "x0" ];then
               cmd=`echo "call sysproc.admin_cmd( 'force application( $APPHDLS )' )"`
               log_it "(TIMEOUT:Subsect_Appl breach): Issuing FORCE APPLICATION using the command: $cmd"
               db2 "$cmd"
            elif [ "x$manual" = "x1" -a "x$APPHDLS" != "x" ];then
               cmd=`echo "call sysproc.admin_cmd( 'force application( $APPHDLS )' )"`
               log_it "\n(TIMEOUT:Subsect_Appl breach): Verify the application(s) and then issue the following FORCE APPLICATION command:\n\n$cmd\n"
            fi
       done
     fi

    if [ -s $outputdir/sortMemUsedByAppHandle.$partition.txt.$tstamp ];then
       cat $outputdir/sortMemUsedByAppHandle.$partition.txt.$tstamp | /usr/bin/perl -ne 'if( /\d+-\d+-\d+-\d+\./ ){ @arr = split(/\s+/, $_); print "$arr[4],$arr[5]\n"; }' | while read rec
       do
          apphandle=`echo $rec   | cut -d"," -f1`
          sortMemUsed=`echo $rec | cut -d"," -f2`

          log_it "(TIMEOUT:Application breach): Apphdl: $apphandle, Sort mem used per partition : $sortMemUsed"
          if [ "x$manual" = "x0" ];then
             cmd=`echo "call sysproc.admin_cmd( 'force application( $APPHDLS )' )"`
             log_it "(TIMEOUT:Application breach): Issuing FORCE APPLICATION using the command: $cmd"
             db2 "$cmd"
          elif [ "x$manual" = "x1" ];then
             cmd=`echo "call sysproc.admin_cmd( 'force application( $APPHDLS )' )"`
             log_it "\n(TIMEOUT:Application breach:)Verify the application(s) and then issue the following FORCE APPLICATION command:\n\n$cmd\n"
          fi
      done
    fi

    log_it "!!TIMEOUT!! Finished data collection and forcing off the applications"

    exit 0

}

###########################################################
# get_partitions_per_host
# Gets the number of logical partitions per host
##########################################################

get_partitions_per_host()
{
    typeset -i partition
    typeset -i number_of_partitions
    partition=$1

    number_of_partitions=0

    partition_host=`cat $INSTHOME/sqllib/db2nodes.cfg |  grep -v '^ *#'  | awk -v"part=$partition" '{ if( $1 == part ){ print $2; } }'`
    number_of_partitions=`cat $INSTHOME/sqllib/db2nodes.cfg |  grep -v '^ *#' | awk -v"host=$partition_host" '{ if( $2 == host ) tot++; }END{ print tot; }'`

    NUMBEROFPARTITIONS=$number_of_partitions
}

##############################################################################################
# get_version
# Gets the DB2 version its running under. Due to a defect, in versions < 10.1 the memory used
# is displayed in bytes. This functions checks if script is running under v10.1 or higher.
###############################################################################################

function get_version
{
    set +x
    version=`db2level |grep "DB2 v"|awk '{ print $5;}'|awk -F"." '{ char_v=index($1,"v"); print substr($1,char_v+1)" "$2" "$4; }' | sed "s/\",//"`
    DB2MajorVersion=`echo $version | cut -d" " -f1`
    DB2MinorVersion=`echo $version | cut -d" " -f2`
    DB2FixpackVersion=`echo $version | cut -d" " -f3`


    if [[ $DB2MajorVersion -ge 10 ||  ( $DB2MajorVersion -eq 9 && $DB2MinorVersion -gt 7 ) || ( $DB2MajorVersion -eq 9 && $DB2MinorVersion -eq 7 && $DB2FixpackVersion -ge 10 )  ]] ;then

       DB2VERSIONV10ANDHIGHER=1
    fi

    log_it "Version = $DB2MajorVersion $DB2MinorVersion $DB2FixpackVersion, DB2VERSIONV10ANDHIGHER = $DB2VERSIONV10ANDHIGHER"
    set +x
}

##########################################################
## read_arguments
## Read command line arguments
#########################################################

read_arguments()
{
    while getopts d:n:o:m:s:S:p:t:i:e: opt
    do
        case $opt in
            d) DBNAME="$OPTARG";;
            n) PARTITION=$OPTARG;;
            o) OUTPUTDIR=$OPTARG;;
            m) MANUAL=$OPTARG;;
            s) SORTMEM_APPHANDLE=$OPTARG;;
            S) SORTMEM_SERVER=$OPTARG;;
            t) TOPCONSUMERS=$OPTARG;;
            p) PURGETIME=$OPTARG;;
            i) TIMEOUT=$OPTARG;;
            e) SUBSECTIONS=$OPTARG;;
            *) echo "Invalid option used."
               usage;;
        esac
    done
}

###################################################################################################
# isRunning
# Find out if another copy of script is running or not. If yes, let the other copy finish and
# quietly exit out
###################################################################################################
isRunning()
{
    progName=$1
    if [ -d $HOME/.$progName ];then
        return 1
    else
        return 0
    fi
}

####################################################################################################
## findSortConsumers
## This is the main logic of the program where it finds out the highest sort consumers and acts on it
######################################################################################################
findSortConsumers()
{
    typeset -ui sortmem_apphandle
    typeset -ui sortmem_server
    dbname=$1
    partition=$2
    sortmem_apphandle=$3
    sortmem_server=$4
    num_partitions=$5
    topconsumers=$6
    outputdir=$7
    manual=$8
    purgetime=$9
#After argument number 9, shell script has to deref the next args in curly braces
    subsections=${10}
    timeout=${11}


    log_it "Incoming params to findSortConsumers:"
    log_it "dbname = $dbname partition = $partition sortmem_apph = $sortmem_apphandle sortmem_per_partition = $sortmem_server num_partitions = $num_partitions topconsumers = $topconsumers ouptutdir = $outputdir manual = $manual purgetime = $purgetime subsections = $subsections timeout = $timeout"
#Purge the old data first

    log_it "Deleting these files from $outputdir"
    find $outputdir \( -name "sortMemUsedByWLM*" -o -name "sortMemUsedByApp*" -o -name "sortMemUsedPerPartition*" -o -name "sortServerBreachApphandle*" -o -name "numSubSection*" \) -cmin +$purgetime >> $LOGFILE
    find $outputdir \( -name "sortMemUsedByWLM*" -o -name "sortMemUsedByApp*" -o -name "sortMemUsedPerPartition*" -o -name "sortServerBreachApphandle*" -o -name "numSubSection*" \) -cmin +$purgetime -exec rm -f {} \;

#Get the other partitions on the server where the query is being sent to

    tstamp=`date "+%Y%m%d_%H%M%S"`

#Connect to database

    db2 connect to $dbname >> $outputdir/$LOGFILE 2>&1
    rc=$?

    if [ $rc -eq 0 ];then

         #Issue SQL to get the sort memory used per partition. Then extrapolate it to the whole server and then check if
         #trigger is breached or not

         sqlStmt=`echo "select current timestamp as snap_time,
                                  member,
                                  sum(memory_pool_used) as private_sort_used
                             from table(mon_get_memory_pool('PRIVATE', '$dbname', $partition))
                            where memory_pool_type = 'SORT'
                         group by 1,member"`

         log_it "Executing: $sqlStmt"
         db2 "$sqlStmt" > $outputdir/sortMemUsedPerPartition.$partition.txt.$tstamp

         serverSortMemBreach=0
         sortMemUsedPerPartition=0
         cat $outputdir/sortMemUsedPerPartition.$partition.txt.$tstamp | /usr/bin/perl -ne 'if( /\d+-\d+-\d+-\d+\./ ){ @arr = split(/\s+/, $_); chomp($arr[2]);  print "$arr[2]\n"; }' | while read rec
         do
             sortMemUsedPerPartition=$rec
             if [ $sortMemUsedPerPartition -ge $sortmem_server ];then
                 serverSortMemBreach=1
             fi
         done

         if [ "x$sortMemUsedPerPartition" = "x" ];then
             sortMemUsedPerPartition=0
         fi

         if [ $serverSortMemBreach -eq 1 ];then
             totServerCurrSortMem=`echo "$sortMemUsedPerPartition*$num_partitions" | bc`
             totServerAskSortMem=`echo "$sortmem_server*$num_partitions" | bc`

             log_it "!!SERVER THRESHOLD BREACHED!!"
             log_it "Current sort memory used: $totServerCurrSortMem, Threshold set: $totServerAskSortMem"

             sqlStmt=`echo "select current timestamp as snap_time,
                              substr(service_superclass_name, 1, 30),
                              substr(service_Subclass_name, 1, 30),
                              t.member,
                              q.APPLICATION_HANDLE ,
                              sum(memory_pool_used) as private_sort_used
                         from table(mon_get_memory_pool('PRIVATE', '$dbname', $partition)) as t,
                              table(wlm_get_service_class_agents(NULL,NULL,NULL,$partition)) as q
                        where t.edu_id = q.agent_tid
                          and t.member = q.dbpartitionnum
                          and t.memory_pool_type = 'SORT'
                     group by 1,service_superclass_name, service_subclass_name, t.member, q.APPLICATION_HANDLE
                     order by 6 desc
                     fetch first $topconsumers rows only"`

             log_it "Executing: $sqlStmt"
             db2 "$sqlStmt" > $outputdir/sortServerBreachApphandle.$partition.txt.$tstamp


             firstRec=1

             APPHDLS=""
             cat $outputdir/sortServerBreachApphandle.$partition.txt.$tstamp | /usr/bin/perl -ne 'if( /\d+-\d+-\d+-\d+\./ ){ @arr = split(/\s+/, $_); print "$arr[4],$arr[5]\n"; }' | while read rec
             do
                 apphandle=`echo $rec   | cut -d"," -f1`
                 sortMemUsed=`echo $rec | cut -d"," -f2`

                 if [ "x$firstRec" = "x1" ]; then
                    APPHDLS=$apphandle
                    firstRec=0
                 else
                    APPHDLS=`echo "$APPHDLS, $apphandle"`
                 fi
                 log_it "(Server breach): Apphdl: $apphandle, Sort mem used per partition : $sortMemUsed"
                 log_it "(Server breach): Taking a global snapshot for the application $apphandle"
                 pid=$$

                 db2 "get snapshot for application agentid $apphandle global" > $outputdir/$apphandle.globsnap.$partition.txt.$tstamp &
                 alarmpid=$!

                 sleep $timeout

                 kill -0 $alarmpid > /dev/null

                 if [ $? -ne 0 ];then
                     log_it "(Server breach): Successfully returned from global snapshot within $timeout seconds"
                 else
                     kill -s USR1 $pid >> $LOGFILE
                 fi

             done

             if [ "x$manual" = "x0" -a "x$APPHDLS" != "x" ];then
                cmd=`echo "call sysproc.admin_cmd( 'force application( $APPHDLS )' )"`
                log_it "(Server breach): Issuing FORCE APPLICATION using the command: $cmd"
                db2 "$cmd"
             elif [ "x$manual" = "x1" -a "x$APPHDLS" != "x" ];then
                cmd=`echo "call sysproc.admin_cmd( 'force application( $APPHDLS )' )"`
                log_it "\n(Server breach:)Verify the application(s) and then issue the following FORCE APPLICATION command:\n\n$cmd\n"
             fi

         else
            totServerCurrSortMem=`echo "$sortMemUsedPerPartition*$num_partitions" | bc`
            totServerAskSortMem=`echo "$sortmem_server*$num_partitions" | bc`
            log_it "Total server sort memory threshold NOT breached. Current memory used: $totServerCurrSortMem, Threshold set for: $totServerAskSortMem"
         fi


#Issue SQL to get the WLM class having sort consumption of more than sortmem per partition
         sqlStmt=`echo "select current timestamp as snap_time,
                               substr(service_superclass_name, 1, 30),
                               substr(service_Subclass_name, 1, 30),
                               t.member, sum(memory_pool_used) as private_sort_used
                          from table(mon_get_memory_pool('PRIVATE', '$dbname', $partition)) as t,
                               table(wlm_get_service_class_agents(NULL,NULL,NULL,$partition)) as q
                         where t.edu_id = q.agent_tid
                           and t.member = q.dbpartitionnum
                           and t.memory_pool_type = 'SORT'
                      group by 1,service_superclass_name, service_subclass_name, t.member having sum(memory_pool_used) > $sortmem_server"`

         log_it "Executing: $sqlStmt"
         db2 "$sqlStmt" > $outputdir/sortMemUsedByWLMClass.$partition.txt.$tstamp



         if [ $serverSortMemBreach -eq 0 ];then


             if [ "x$subsections" != "x" ];then

               #Issue SQL to get the application handles belonging to the superclass, subclass showing the number of
               #sub-sections and their sort memory usage.

                sqlStmt=`echo "select current timestamp as snap_time,
                                      substr(service_superclass_name, 1, 30),
                                      substr(service_Subclass_name, 1, 30),
                                      t.member,
                                      q.APPLICATION_HANDLE ,
                                      sum(memory_pool_used) as private_sort_used,
                                      count(q.agent_tid) as num_sub_sections
                                 from table(mon_get_memory_pool('PRIVATE', '$dbname', $partition)) as t,
                                      table(wlm_get_service_class_agents(NULL,NULL,NULL,$partition)) as q
                                where t.edu_id = q.agent_tid
                                  and t.member = q.dbpartitionnum
                                  and t.memory_pool_type = 'SORT'
                             group by 1,service_superclass_name, service_subclass_name, t.member, q.APPLICATION_HANDLE
                               having sum(memory_pool_used) > $sortmem_apphandle
                                  and count(q.agent_tid)    >= $subsections
                             order by 6,7 desc "`

                log_it "Executing: $sqlStmt"
                db2 "$sqlStmt" > $outputdir/numSubSectionsPerApphandle.$partition.txt.$tstamp
                firstRec=1

                APPHDLS=""

                #Initialize an array for the apphandles which are sent a force so that its not repeated again
                #during the apphandle sortmem check

                set -A apphandleArr
                arrayCtr=1

                cat $outputdir/numSubSectionsPerApphandle.$partition.txt.$tstamp | /usr/bin/perl -ne 'if( /\d+-\d+-\d+-\d+\./ ){ @arr = split(/\s+/, $_); print "$arr[4],$arr[5],$arr[6]\n"; }' | while read rec
                do
                        apphandle=`echo $rec   | cut -d"," -f1`
                        sortMemUsed=`echo $rec | cut -d"," -f2`
                        numSubSections=`echo $rec | cut -d"," -f3`

                        if [ "x$firstRec" = "x1" ]; then
                            APPHDLS=$apphandle
                            firstRec=0
                        else
                            APPHDLS=`echo "$APPHDLS, $apphandle"`
                        fi

                        apphandleArr[$arrayCtr]=$apphandle
                        ((arrayCtr=$arrayCtr+1))

                        log_it "(Subsect_Appl breach): Apphdl: $apphandle, Sort mem used per partition : $sortMemUsed, Number of sub-sections: $numSubSections( check is for $subsections )"
                        log_it "(Subsect_Appl breach): Taking a local snapshot for the application $apphandle"

                        #Following is a ALARMHANDLER code to check for "hung" snapshot commands

                        pid=$$

                        db2 "get snapshot for application agentid $apphandle " > $outputdir/$apphandle.localsnap.$partition.txt.$tstamp &

                        alarmpid=$!

                        sleep $timeout

                        kill -0 $alarmpid > /dev/null

                        if [ $? -ne 0 ];then
                           log_it "(Subsect_Appl breach): Successfully returned from local snapshot within $timeout seconds"
                        else
                            kill -s USR1 $pid >> $LOGFILE
                        fi

               done

               if [ "x$manual" = "x0" -a "x$APPHDLS" != "x" ];then
                   cmd=`echo "call sysproc.admin_cmd( 'force application( $APPHDLS )' )"`
                   log_it "(Subsect_Appl breach): Issuing FORCE APPLICATION using the command: $cmd"
                   db2 "$cmd"
               elif [ "x$manual" = "x1" -a "x$APPHDLS" != "x" ];then
                   cmd=`echo "call sysproc.admin_cmd( 'force application( $APPHDLS )' )"`
                   log_it "\n(Subsect_Appl breach): Verify the application(s) and then issue the following FORCE APPLICATION command:\n\n$cmd\n"
               fi

               if [ "x$APPHDLS" = "x" ];then
                   log_it "No application handles found consuming more than $sortmem_apphandle or having more than $subsections sub-sections"
               fi

            fi

            #Issue SQL to get the application handles belonging to the superclass, subclass showing the highest sort usage

            sqlStmt=`echo "select current timestamp as snap_time,
                              substr(service_superclass_name, 1, 30),
                              substr(service_Subclass_name, 1, 30),
                              t.member,
                              q.APPLICATION_HANDLE ,
                              sum(memory_pool_used) as private_sort_used
                         from table(mon_get_memory_pool('PRIVATE', '$dbname', $partition)) as t,
                              table(wlm_get_service_class_agents(NULL,NULL,NULL,$partition)) as q
                        where t.edu_id = q.agent_tid
                          and t.member = q.dbpartitionnum
                          and t.memory_pool_type = 'SORT'
                     group by 1,service_superclass_name, service_subclass_name, t.member, q.APPLICATION_HANDLE
                              having sum(memory_pool_used) > $sortmem_apphandle
                     order by 6 desc "`

           log_it "Executing: $sqlStmt"
           db2 "$sqlStmt" > $outputdir/sortMemUsedByAppHandle.$partition.txt.$tstamp

#Get the application handles


           firstRec=1

           APPHDLS=""

           allAppHandlesSentForce=`echo "${apphandleArr[*]}"`

           cat $outputdir/sortMemUsedByAppHandle.$partition.txt.$tstamp | /usr/bin/perl -ne 'if( /\d+-\d+-\d+-\d+\./ ){ @arr = split(/\s+/, $_); print "$arr[4],$arr[5]\n"; }' | while read rec
           do
                apphandle=`echo $rec   | cut -d"," -f1`
                sortMemUsed=`echo $rec | cut -d"," -f2`

                foundInArr=0
                for app in `echo $allAppHandlesSentForce`
                do
                   if [ "x$app" = "x$apphandle" ]; then
                      log_it "(Application Breach): Apphandle $apphandle already has been identified and sent a force .. skipping"
                      foundInArr=1
                   fi
                done

                if [ "x$foundInArr" = "x1" ];then
                   continue
                fi

                if [ "x$firstRec" = "x1" ]; then
                    APPHDLS=$apphandle
                    firstRec=0
                else
                    APPHDLS=`echo "$APPHDLS, $apphandle"`
                fi
                log_it "(Application breach): Apphdl: $apphandle, Sort mem used per partition : $sortMemUsed"
                log_it "(Application breach): Taking a global snapshot for the application $apphandle"

                pid=$$

                db2 "get snapshot for application agentid $apphandle global" > $outputdir/$apphandle.globsnap.$partition.txt.$tstamp &
                alarmpid=$!

                sleep $timeout

                kill -0 $alarmpid > /dev/null

                if [ $? -ne 0 ];then
                    log_it "(Application breach): Successfully returned from global snapshot within $timeout seconds"
                else
                    kill -s USR1 $pid >> $LOGFILE
                fi

           done

           if [ "x$manual" = "x0" -a "x$APPHDLS" != "x" ];then
             cmd=`echo "call sysproc.admin_cmd( 'force application( $APPHDLS )' )"`
             log_it "(Application breach): Issuing FORCE APPLICATION using the command: $cmd"
             db2 "$cmd"
           elif [ "x$manual" = "x1" -a "x$APPHDLS" != "x" ];then
             cmd=`echo "call sysproc.admin_cmd( 'force application( $APPHDLS )' )"`
             log_it "\n(Application breach): Verify the application(s) and then issue the following FORCE APPLICATION command:\n\n$cmd\n"
           fi

           if [ "x$allAppHandlesSentForce" = "x" ];then
             log_it "No application handles found consuming more than $sortmem_apphandle "
             echo "`date`: No application handles found consuming more than $sortmem_apphandle "
           fi
         fi  # end of if condition ( Run application threshold check only if server breach has not happened.)

         log_it "Terminating db connection"
         db2 "terminate" >> $LOGFILE

    else
        log_it "Connection to database $dbname did not succeed"
        echo "`date`: Connection to $dbname did not succeed .. Exiting"
    fi
}

main()
{
    if [ $# -lt 1 ];then
        usage
    fi

    #Find out if another copy is running
    prog=`basename $0`
    isRunning $prog

    if [ $? -ne 0 ];then
       log_it "Another copy of the program $prog is running .. exiting"
       exit 0
    fi

    #Create a hidden lock dir to signify the start of the script

    mkdir -p $HOME/.$prog
    if [ $? -ne 0 ];then
        #Someone got there before exit
        log_it "Another copy of the program $prog is already running .. exiting"
        exit 0
    fi


    #Read the arguments

    read_arguments "${@:-}" || error_exit $? read_argument $prog

    #Validate the arguments

    if [ "x$DBNAME" = "x" ];then
        error_exit 2 dbname_not_entered $prog
    fi

    if [ "x$PARTITION" = "x" ];then
        error_exit 3 node_number_not_entered $prog
    fi

    if [ $PARTITION -lt 0 -a $PARTITION -gt 999 ];then
        echo "`date`: Node number has to be between 0 and 999"
        error_exit 4 invalid_partition_number_entered $prog
    fi

    if [ "x$OUTPUTDIR" != "x." ];then
        mkdir $OUTPUTDIR 2>/dev/null
    fi

    if [ "x$SUBSECTIONS" != "x" ];then
       if [ $SUBSECTIONS -le 0 -a $SUBSECTIONS -gt 999 ];then
           echo "`date`: Subsections has to be between 1 and 999"
           error_ext 5 invalid_subsect_number_entered $prog
       fi
    fi

    if [ "x$TIMEOUT" != "x" ];then
        if [ $TIMEOUT -le 0 -a $TIMEOUT -gt 180 ];then
            echo "`date`: Timeout has to be between 1 and 180"
            error_ext 6 invalid_timeout_value_entered $prog
        fi
    fi

#Due to a defect in versions < 10.1 the value in get_memory_pool is in bytes and not in KB as documented.
#The following is done to address that
#
    get_version
    log_it "DB2VERSIONV10ANDHIGHER = $DB2VERSIONV10ANDHIGHER"

    if [ "x$SORTMEM_APPHANDLE"  != "x" ];then
        if [ $DB2VERSIONV10ANDHIGHER -eq 0 ];then
            SORTMEM_APPHANDLE=`echo "$SORTMEM_APPHANDLE*1024*1024*1024" | bc`
        else
            SORTMEM_APPHANDLE=`echo "$SORTMEM_APPHANDLE*1024*1024" | bc`
        fi
    fi

#SORTMEM_SERVER is the limit set by user for the whole physical server. Default is 1GB per partition.
#Since, in the query in findSortConsumers is run against only 1 partition, I am converting SORTMEM_SERVER to
#a per partition number and then doing the math in the findSortConsumers to check for the trigger
#

    if [ "x$SORTMEM_SERVER" = "x" ];then
        get_partitions_per_host $PARTITION
        if [ "x$NUMBEROFPARTITIONS" = "x" ];then
            error_exit 7 unable_to_find_num_partitions $prog
        else
                SORTMEM_SERVER=$NUMBEROFPARTITIONS
            if [ $DB2VERSIONV10ANDHIGHER -eq 0 ];then
                SORTMEM_PER_PARTITION=`echo "scale=2;($SORTMEM_SERVER*1024*1024*1024)/$NUMBEROFPARTITIONS" | bc`
            else
                SORTMEM_PER_PARTITION=`echo "scale=2;($SORTMEM_SERVER*1024*1024)/$NUMBEROFPARTITIONS" | bc`
            fi
        fi
    else
        get_partitions_per_host $PARTITION
        if [ "x$NUMBEROFPARTITIONS" = "x" ];then
            error_exit 8 unable_to_find_num_partitions $prog
        else
            if [ $DB2VERSIONV10ANDHIGHER -eq  0 ];then
                SORTMEM_PER_PARTITION=`echo "scale=2;($SORTMEM_SERVER*1024*1024*1024)/$NUMBEROFPARTITIONS" | bc`
            else
                SORTMEM_PER_PARTITION=`echo "scale=2;($SORTMEM_SERVER*1024*1024)/$NUMBEROFPARTITIONS" | bc`
            fi
        fi
    fi

    if [ $SORTMEM_APPHANDLE -ge $SORTMEM_PER_PARTITION ];then
        echo "Sort memory per apphandle cannot be greater than or equal to the sort memory  per partition"
        if [ $DB2VERSIONV10ANDHIGHER -eq  0 ];then
                printSortMemServer=`echo "scale=2;$SORTMEM_SERVER*1024*1024*1024" | bc`
            echo "Sort memory per apphandle asked(bytes): $SORTMEM_APPHANDLE, Sort memory per partition (bytes): $SORTMEM_PER_PARTITION, Total sort mem threshold per server(bytes): $printSortMemServer"
        else
                printSortMemServer=`echo "scale=2;$SORTMEM_SERVER*1024*1024" | bc`
                echo "Sort memory per apphandle asked(KB): $SORTMEM_APPHANDLE, Sort memory per partition (KB): $SORTMEM_PER_PARTITION, Total sort mem threshold per server(KB): $printSortMemServer"
        fi
        error_exit 9 sort_mem_apph_ge_sort_mem_server $prog
    fi

    if [ "x$PURGETIME" != "x" ];then
        PURGETIME=`echo "$PURGETIME*60" | bc`
    fi

    log_it "Params: -d $DBNAME -n $PARTITION -s $SORTMEM_APPHANDLE -S $SORTMEM_SERVER -t $TOPCONSUMERS -m $MANUAL -p $PURGETIME -o $OUTPUTDIR"
    log_it "Calling findSortConsumers with the following parms:"
    log_it "dbname = $DBNAME partition = $PARTITION sortmem_apph = $SORTMEM_APPHANDLE sortmem_server = $SORTMEM_PER_PARTITION num_partitions = $NUMBEROFPARTITIONS topconsumers = $TOPCONSUMERS ouptutdir = $OUTPUTDIR manual = $MANUAL purgetime = $PURGETIME subsections = $SUBSECTIONS timeout = $TIMEOUT"

    findSortConsumers $DBNAME $PARTITION $SORTMEM_APPHANDLE $SORTMEM_PER_PARTITION $NUMBEROFPARTITIONS $TOPCONSUMERS $OUTPUTDIR $MANUAL $PURGETIME $SUBSECTIONS $TIMEOUT

    rmdir $HOME/.$prog
}
##Main program logic

main "${@:-}"


