#!/usr/bin/bash

TIME=`date|awk '{print $4}'`
TIME1=`date|awk '{print $2 $3}'`
Hostname=`hostname`
ts=`date +%Y-%m-%d`

echo "================================================================================================================="  >> /ETLDATA01/Jobs_logs/Phantom_Count_$ts.txt
####Memory=`svmon -G`
OSH=`ps -ef|grep osh|wc -l`
PHANTOM=`ps -ef|grep phantom|wc -l`
echo "Total Phantom count on $TIME1 at $TIME on $Hostname is:$PHANTOM" >> /ETLDATA01/Jobs_logs/Phantom_Count_$ts.txt
echo "Total Osh count on $TIME1 at $TIME on $Hostname is:$OSH" >> /ETLDATA01/Jobs_logs/Phantom_Count_$ts.txt


echo "=================================================================================================================="  >> /ETLDATA01/Jobs_logs/Phantom_Count_$ts.txt

echo "LIST OF JOBS RUNNING ON $TIME1 AT $TIME ON $Hostname" >> /ETLDATA01/Jobs_logs/Phantom_Count_$ts.txt
echo "                                                                                                                  "  >> /ETLDATA01/Jobs_logs/Phantom_Count_$ts.txt

ps -ef | grep DSD >> /ETLDATA01/Jobs_logs/Phantom_Count_$ts.txt
echo "================================================================================================================="  >> /ETLDATA01/Jobs_logs/Phantom_Count_$ts.txt
svmon -G >> /ETLDATA01/Jobs_logs/Phantom_Count_$ts.txt
