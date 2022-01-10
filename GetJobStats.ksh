{\rtf1\ansi\ansicpg1252\cocoartf2636
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 ArialMT;}
{\colortbl;\red255\green255\blue255;\red255\green255\blue255;\red0\green0\blue0;}
{\*\expandedcolortbl;;\cssrgb\c100000\c100000\c100000;\cssrgb\c0\c0\c0;}
\paperw11900\paperh16840\margl1440\margr1440\vieww26680\viewh16800\viewkind0
\deftab720
\pard\pardeftab720\partightenfactor0

\f0\fs20 \cf0 \cb2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec3 #!/bin/ksh\
#********************************************************************************************************************************\
#**\'a0 \'a0 \'a0Script\'a0Name\'a0 \'a0 : \cb2 \outl0\strokewidth0 GetJobStats.ksh\'a0 \cb2 \outl0\strokewidth0 \strokec3 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0**\
#**\'a0 \'a0 \'a0Purpose\'a0 \'a0 \'a0 \'a0 : Save Start Time, End time and\'a0 Elapsed time for all Jobs in the given Sequencer\'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0**\
#**\'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 : to JOB_LOG_DETAIL_DS table.\'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0**\
#**\'a0 \'a0 \'a0Author\'a0 \'a0 \'a0 \'a0 \'a0: Samar S Chauhan\'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0**\
#**\'a0 \'a0 \'a0Parameters\'a0 \'a0 \'a0:\'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0**\
#**\'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 **\
#**\'a0 \'a0 \'a0Change Log\'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0**\
#**\'a0 \'a0 \'a0-----------------------------------------------------------------------------------------------------------------------**\
#**\'a0 \'a0 \'a0Date\'a0 \'a0 \'a0 \'a0 \'a0 | Updated By\'a0 \'a0 \'a0 \'a0 | Changes\'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 **\
#**\'a0 \'a0 \'a0-----------------------------------------------------------------------------------------------------------------------**\
#**\'a0 \'a0 \'a020-Sept-2011\'a0 | Samar Chauhan\'a0 \'a0 \'a0|\'a0 First Version\'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 **\
#**\'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0|\'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0|\'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 **\
#**\'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0|\'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0|\'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 **\
#********************************************************************************************************************************\
#**\'a0 \'a0 \'a0Define functions used in the\'a0Script\
#**\
#********************************************************************************************************************************\
date2stamp ()\
\{\
\'a0 \'a0 date -u --date "$1" +%s\
\}\
date2stampnextday ()\
\{\
\'a0 \'a0 date --date="tomorrow$1" +%s\
\}\
dateDiff ()\
\{\
\'a0 \'a0 dte1=$(date2stamp $1)\
\'a0 \'a0 dte2=$(date2stamp $2)\
\
\'a0 \'a0 if [[ $dte1 -gt $dte2 ]];then\
\'a0 \'a0 \'a0 \'a0 dte2=$(date2stampnextday $2)\
\'a0 \'a0 fi\
\'a0 \'a0 diffSec=$((dte2-dte1))\
\'a0 \'a0 if ((diffSec < 0)); then abs=-1; else abs=1; fi\
\'a0 \'a0 echo $((diffSec*abs))\
\}\
#********************************************************************************************************************************\
RUN_DIR=`dirname $0`\
# Calling the configuration\'a0script\
if [ -x $RUN_DIR/Configurations.cfg ];then\
. $RUN_DIR/Configurations.cfg\
else\
\'a0 \'a0 echo "Configuration\'a0script\'a0Configurations.cfg not present or does not have execute permissions."> /dev/null\
\'a0 \'a0 exit 1\
fi\
# Calling the functions\'a0script\
. $RUN_DIR/functions.ksh\
\
# Run the DS-Env File\
. $\{DSHOME\}/dsenv\
\
# Execute Profile\
.\'a0 /home/dsadm/.profile\
\
#Execute Database Connection file\
. /home/dsadm/bin/DB2Connect > /dev/null\
\
#********************************************************************************************************************************\
# Main\'a0Script\'a0Starts here\
#********************************************************************************************************************************\
JobId=$1\
LEG=$2\
Period=$3\
MasterJob=$4\
LoadType=$5\
Level=$6\
DSProject=$\{DS_PROJ\}\
\
echo "DSPROJ=$\{DS_PROJ\}"\
\
# If level is not passed then its top most level i.e. level=0\
if [ -z $Level ];then\
\'a0 \'a0Level=0\
fi\
\
#************************************************************************************************************************\
# Define Job Log\
procname="GetJobStats"\
# Create temp directory if not present\
mkdir -p /tmp/$procname\
joblog=/tmp/$procname/"$MasterJob".log\
\
#********************************************************************************************************************************\
#reset files\
> $joblog.tmp\
\
# Get Start, End, Elapsed time of give job\
$HOME/bin/dsjob -report $DSProject $MasterJob > $joblog.$$ 2>/dev/null\
StartTime=`cat $joblog.$$ |grep start|cut -f2 -d '='|cut -f2 -d ' '`\
EndTime=`cat $joblog.$$ |grep end |cut -f2 -d '='|cut -f2 -d ' '`\
ElapsedTime=`cat $joblog.$$ |grep elapsed|cut -f2 -d '='`\
\
echo $JobId,$LEG,$Period,$MasterJob,$StartTime,$EndTime,$ElapsedTime,$LoadType,$Level\
\
. $HOME/bin/DB2Connect > /dev/null\
db2 "insert into datastore.job_log_detail_ds\
\'a0 \'a0 \'a0(JOB_ID,COUNTRY,PERIOD,JOB_NAME,JOB_TYPE,JOB_START_TIME,JOB_END_TIME,ELAPSED_TIME,LEVEL_NUMBER,REC_LOAD_DT,REC_UPDT_DT)\
\'a0 \'a0 \'a0values($JobId,'$LEG',$Period,'$MasterJob','$LoadType','$StartTime','$EndTime','$ElapsedTime',$Level,current_timestamp,current_timestamp)"\
\
Level=`expr $Level + 1`\
\
# Get the ds log file\
$HOME/bin/dsjob -logdetail $DSProject $MasterJob > $joblog 2>/dev/null\
\
#Find total number of records in file\
TotalRecords=`wc -l $joblog|cut -f1 -d ' '`\
#echo TotalRecords=$TotalRecords\
\
#Find 'Summary of sequence run'\
\
Start=`cat $joblog|grep -n 'Summary of sequence run'|tail -1|cut -f1 -d ':'`\
#echo Start=$Start\
\
End=`cat $joblog|grep -n 'Sequence finished OK'|tail -1|cut -f1 -d ':'`\
#echo End=$End\
\
#First Cut\
let section1=$((TotalRecords - Start - 1))\
#echo section1=$section1\
cat $joblog|tail -$section1 > $joblog.1\
\
let section2=$((End - Start - 2 ))\
#echo section2=$section2\
cat $joblog.1|head -$section2|tr -s "\'a0 " " " > $joblog.2\
\
#cat $joblog.2\
\
#get master list of job activities\
cat $joblog.2|cut -f4 -d ':'|cut -f2 -d ' ' > $joblog.joblist\
\
#for each of the activity find start and end time\
for JobActivity in `cat $joblog.joblist`\
do\
\
\'a0 \'a0 \'a0JobType=`grep -w "$JobActivity" $joblog.2|grep -v reply|cut -f4 -d ' '|sort -u|cut -f1 -d ')'|cut -c1-2`\
\'a0 \'a0 \'a0JobName=`grep -w "$JobActivity" $joblog.2|grep -v reply|cut -f4 -d ' '|sort -u|cut -f1 -d ')'`\
\
\'a0 \'a0 \'a0start_temp=`cat $joblog.2|grep -w $JobActivity|head -1|tail -1|cut -f1 -d ' '|sed 's/:$//g'`\
\'a0 \'a0 \'a0start=`echo $start_temp|tr -d " "`\
\
\'a0 \'a0 \'a0end_temp=`cat $joblog.2|grep -w $JobActivity|head -2|tail -1|cut -f1 -d ' '|sed 's/:$//g'`\
\'a0 \'a0 \'a0end=`echo $end_temp|tr -d " "`\
\
\'a0 \'a0 \'a0cnt=`cat $joblog.tmp|grep -w $JobActivity|wc -l|cut -f1 -d ' '`\
\'a0 \'a0 \'a0if [ $cnt -ne 0 ];then\
\'a0 \'a0 \'a0 \'a0 continue\
\'a0 \'a0 \'a0fi\
\'a0 \'a0 \'a0elapsedtimeinseconds=`dateDiff "$start" "$end"`\
\'a0 \'a0 \'a0#echo $elapsedtimeinseconds\
\
\'a0 \'a0 \'a0#convert sec to h:m:s\
\'a0 \'a0 \'a0((hour=$elapsedtimeinseconds/3600))\
\'a0 \'a0 \'a0((mins=($elapsedtimeinseconds-hour*3600)/60))\
\'a0 \'a0 \'a0((sec=$elapsedtimeinseconds-((hour*3600) + (mins*60))))\
\'a0 \'a0 \'a0elapsedtime=`printf "%02d:%02d:%02d\\n" "$hour" "$mins" "$sec"`\
\
\
\'a0 \'a0 \'a0echo $JobActivity,$start,$end,$elapsedtime,$LoadType,$Level >> $joblog.tmp\
\
\
\'a0 \'a0 if [ "$JobType" = "SQ" ];then\
\'a0 \'a0 \'a0 \'a0 \'a0 \'a0 #Call the\'a0script\'a0again\
\
\'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 $\{SCRIPT_DIR\}/GetJobstats.ksh $JobId $LEG $Period $JobName $LoadType $Level\
\'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 rc=$?\
\
\'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 if [ $rc -ne 0 ];then\
\'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 echo "Command failed"\
\'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 exit 1\
\'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 else\
\'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 cat /tmp/$procname/$JobName.log >> $joblog.tmp\
\'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 #cat /tmp/$procname/$JobName.log\
\'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 fi\
\'a0 \'a0 else\
\'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0echo $JobActivity,$start,$end,$elapsedtime,$LoadType,$Level\
\'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0. $HOME/bin/DB2Connect >/dev/null\
\'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0db2 "insert into datastore.job_log_detail_ds\
\'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 (JOB_ID,LEGAL_ENTITY_GRP_CODE,MONTH,JOB_NAME,JOB_TYPE,JOB_START_TIME,JOB_END_TIME,ELAPSED_TIME,LEVEL_NUMBER,REC_LOAD_DT,REC_UPDT_DT)\
\'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 \'a0 values($JobId,'$Country,$Month,\'92$JobActivity','$LoadType','$start','$end','$elapsedtime',$Level,current_timestamp,current_timestamp)"\
\
\'a0 \'a0 fi\
\
\
done\
#echo "---Inside $MasterJob---"\
#rm -f $joblog.1 $joblog.2 $joblog.joblist\
\
#cat $joblog.tmp\
exit 0}