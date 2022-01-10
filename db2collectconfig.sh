############################################################################################################################################
#Script Name      : db2collectconfig.sh                                                                                                    #
#Author           : Pratik Paingankar                                                                                                      #
#Version          : v1.0                                                                                                                   #
#Usage            : Change the FS variable in the script to the path where backup needs to be taken.                                       #
#                   eg in below script .FS=/db2_backup/.                                                                                   #
#Execution        : If the script is named db2collection.sh , run it as sh db2collection.sh.                                               #
#Output           : The scripts creates a folder @ $FS path with the date for which config is collected.                                   #
#Data Collected   : dbm cfg , df -gt , registry variables , db2level , OS environment variables ,                                          #
#                   hosts and services files , db directory ,node directory , tablespace list and details                                  #
#                   db cfg and complete look of the database.                                                                              #
#Constraints (IMP): The script establishes a connection to each db hence the name of the db and its alias should match.                    #
#                   Script does not apply to multi-partitioned databases.                                                                  #
#To be used for   : Primarily before fixpack installation and activities causing a major change in the db configuration.                   #
############################################################################################################################################


if [ -f $HOME/sqllib/db2profile ];then
  . $HOME/sqllib/db2profile
fi
FS=/db2backups/OnlineBackup/DB2_COLLECT/
TS=`date +"%d"`.`date +"%h"`.`date +"%H"`.`date +"%M"`
`mkdir $FS/$TS`
`chmod 777 $FS/$TS`
q=`hostname`
db2 get instance |awk '{print $7}'>temp
z=`sed -n '2,$p' temp`
db2 get dbm cfg > $FS/$TS/dbmcfg_$z.$TS.out
df -gt >  $FS/$TS/df-gt_$q.$TS.out
db2set -all > $FS/$TS/regvar_$z.$TS.out;
db2level > $FS/$TS/dblevel_$z.$TS.out;
env > $FS/$TS/envvar_$q.$TS.out;
cat /etc/hosts > $FS/$TS/hosts_$q.$TS.out;
cat /etc/services > $FS/$TS/services_$q.$TS.out;
db2 list db directory > $FS/$TS/db2directory.out
db2 list node directory > $FS/$TS/nodedirectory.out
db2 list db directory |grep -ip Indirect |grep -ivp toolsdb |awk '/Database alias/{print $NF}' > list
a=`cat list`
echo "$a"
for i in $a
do
db2 "connect to $i";
db2 list tablespaces show detail > $FS/$TS/tablespaces_$i.$TS.out;
db2 get db cfg > $FS/$TS/dbcfg_$i.$TS.out;
db2pd -d $i -tablespaces > $FS/$TS/container_$i.$TS.out;
db2look -d $i -a -x -e -l -f -o $FS/$TS/dblook_$i.$TS.out;
db2 connect reset;
done
`chmod 777 $FS/$TS/*.$TS.out`
