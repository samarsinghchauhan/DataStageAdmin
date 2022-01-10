#!/bin/bash
export Path=`pwd`
ad=`date|awk '{print $2 " " $3}'`
export ad
DATIM=`date '+%y%m%d'`
export DATIM
myid=`whoami|awk '{print $1}'`
export myid
echo "I am logged in as: $myid"
echo ""
echo "Info: script has started to  kill slave processes started at: `date`"
echo ""
pid2kill=`ps -ef |grep slave|grep -v grep |awk 'BEGIN {FS=" "}{print $2 " " $5 " " $6}'|grep -v pts|grep -v "$ad"|cut -d "" -f1|awk 'BEGIN {FS=" "}{print $1}'`
export pid2kill
pidcnt=`ps -ef |grep slave|grep -v grep |awk 'BEGIN {FS=" "}{print $2 " " $5 " " $6}'|grep -v pts|grep -v "$ad"|cut -d "" -f1|awk 'BEGIN {FS=" "}{print $1}'|wc -l`
export pidcnt
echo ""
echo "Number of stale/slave sessions found:$pidcnt"
echo ""
if [ $pidcnt = 0 ]
then
echo "No Stale/Slave sessions older than today is found"
elif [ $pidcnt != 0 ]
then
echo "Stale/Slave sessions older than $ad have been found with pid "$pid2kill""
echo "System has started killing the sessions"
sudo kill -9 $pid2kill
echo "Stale session with PID $pid2kill have been killed :)"
else
echo ""
echo "Caution: Stale/Slave sessions are not owned by logged in user,$myid"
echo "user(:$myid) does not have permissions to kill the sessions/processes"
echo ""
echo "N.B.>>>> OPERATION ABORTED due to insufficient permissions."
fi
echo ""
echo "Info: script to kill slave processes finished at: `date`"
echo ""
echo "********************************************************"
#!/bin/bash
export Path=`pwd`
ad=`date|awk '{print $2 " " $3}'`
export ad
DATIM=`date '+%y%m%d'`
export DATIM
myid=`whoami|awk '{print $1}'`
export myid
echo "I am logged in as: $myid"
echo ""
echo "Info: Now script has started to kill OSH processes started at: `date`"
echo ""
oshkill=`ps -ef |grep osh|grep -v grep |awk 'BEGIN {FS=" "}{print $2 " " $5 " " $6}'|grep -v pts|grep -v "$ad"|cut -d "" -f1|awk 'BEGIN {FS=" "}{print $1}'`
export oshkill
oshcnt=`ps -ef |grep osh|grep -v grep |awk 'BEGIN {FS=" "}{print $2 " " $5 " " $6}'|grep -v pts|grep -v "$ad"|cut -d "" -f1|awk 'BEGIN {FS=" "}{print $1}'|wc -l`
export oshcnt
echo ""
echo "Number of osh sessions found:$oshcnt"
echo ""
if [ $oshcnt = 0 ]
then
echo "No OSH sessions older than today is found"
elif [ $oshcnt != 0 ]
then
echo "OSH sessions older than $ad have been found with pid "$oshkill""
echo "System has started killing the sessions"
sudo kill -9 $oshkill
echo "Stale session with PID $oshkill have been killed :)"
else
echo ""
echo "Caution: OSH sessions are not owned by logged in user,$myid"
echo "user(:$myid) does not have permissions to kill the sessions/processes"
echo ""
echo "N.B.>>>> OPERATION ABORTED due to insufficient permissions."
fi
echo ""
echo "Info: script to kill OSH processes finished at: `date`"
echo ""
echo "********************************************************"
#!/bin/bash
export Path=`pwd`
ad=`date|awk '{print $2 " " $3}'`
export ad
DATIM=`date '+%y%m%d'`
export DATIM
myid=`whoami|awk '{print $1}'`
export myid
echo "I am logged in as: $myid"
echo ""
Phantomkill=`ps -ef |grep phantom|grep -v grep |awk 'BEGIN {FS=" "}{print $2 " " $5 " " $6}'|grep -v pts|grep -v "$ad"|cut -d "" -f1|awk 'BEGIN {FS=" "}{print $1}'`
export Phantomkill
Phantomcnt=`ps -ef |grep phantom|grep -v grep |awk 'BEGIN {FS=" "}{print $2 " " $5 " " $6}'|grep -v pts|grep -v "$ad"|cut -d "" -f1|awk 'BEGIN {FS=" "}{print $1}'|wc -l`
export Phantomcnt
echo ""
echo "Number of Phantom sessions found:$Phantomcnt"
echo ""
if [ $Phantomcnt = 0 ]
then
echo "No Phantom sessions older than today is found"
elif [ $Phantomcnt != 0 ]
then
echo "Phantom sessions older than $ad have been found with pid "$Phantomkill""
echo "System has started killing the sessions"
#sudo kill -9 $Phantomkill
echo "Stale session with PID $Phantomkill have been killed :)"
else
echo ""
echo "Caution: Phantom sessions are not owned by logged in user,$myid"
echo "user(:$myid) does not have permissions to kill the sessions/processes"
echo ""
echo "N.B.>>>> OPERATION ABORTED due to insufficient permissions."
fi
echo ""
echo "Info: script to kill Phantom processes finished at: `date`"
echo ""
echo "********************************************************"

