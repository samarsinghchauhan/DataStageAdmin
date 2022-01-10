export Path=`pwd`
ad=`date|awk '{print $2 " " $3}'`
export ad
DATIM=`date '+%y%m%d'`
export DATIM
echo "Info: script has started to  kill osh processes started at: `date`"
echo ""
pid2kill=`ps -ef |grep osh|grep -v grep|egrep 'Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec' |awk 'BEGIN {FS=" "}{print $2 " " $5 " " $6}'|grep -v pts|grep -v "$ad"|cut -d "" -f1|awk 'BEGIN {FS=" "}{print $1}'`
export pid2kill
pidcnt=`ps -ef |grep osh|grep -v grep |egrep 'Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec' |awk 'BEGIN {FS=" "}{print $2 " " $5 " " $6}'|grep -v pts|grep -v "$ad"|cut -d "" -f1|awk 'BEGIN {FS=" "}{print $1}'|wc -l`
export pidcnt
echo ""
echo "Number of stale/osh sessions found:$pidcnt"
echo ""
if [ $pidcnt = 0 ]
then
echo "No Stale/osh sessions older than today is found"
elif [ $pidcnt != 0 ]
then
echo "OSH sessions older than $ad have been found with pid "$pid2kill""
echo "System has started killing the sessions"
sudo kill -9 $pid2kill
echo "Stale session with PID $pid2kill have been killed :)"
else
echo ""
echo "N.B.>>>> OPERATION ABORTED due to insufficient permissions."
fi
echo ""
echo "Info: script to kill osh processes finished at: `date`"
echo ""
echo "********************************************************"
