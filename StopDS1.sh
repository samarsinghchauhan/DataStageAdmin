#***********************************************************************************
echo "*****System is Stopping DSENGINE.......****************"

pidslvcnt=`ps -ef |grep slave|grep -v grep |awk 'BEGIN {FS=" "}{print $2 " " $5 " " $6}'|grep -v pts|grep -v "$ad"|cut -d "" -f1|awk 'BEGIN {FS=" "}{print $1}'|wc -l`
export pidslvcnt
pidphtcnt=`ps -ef |grep phantom|grep -v grep |awk 'BEGIN {FS=" "}{print $2 " " $5 " " $6}'|grep -v pts|grep -v "$ad"|cut -d "" -f1|awk 'BEGIN {FS=" "}{print $1}'|wc -l`
export pidphtcnt
pidoshcnt=`ps -ef |grep osh|grep -v grep |awk 'BEGIN {FS=" "}{print $2 " " $5 " " $6}'|grep -v pts|grep -v "$ad"|cut -d "" -f1|awk 'BEGIN {FS=" "}{print $1}'|wc -l`
export pidoshcnt
Liscnt=`netstat -a |grep dsrpc|wc -l`
export Liscnt
Conest=`netstat -a |grep dsrpc|grep -v grep|grep -v LISTEN|awk '{print $5}'|cut -d "." -f1-4|wc -l`
export Conest
Dsrpccnt=`ps -ef |grep dsrpcd|grep -v grep|wc -l`
export Dsrpccnt
srvcnt=`ps -ef |grep server1|grep -v grep|wc -l`
export srvcnt
Asbncnt=`ps -ef |grep ASBNode|grep -v grep|grep RunAgent|wc -l`
export Asbncnt
if [ $Dsrpccnt -eq 0 ]
then
echo "DSRPC is not running"
elif [ $Conest -eq 0 ] && [ $Liscnt -eq 1 ] && [ $pidslvcnt -eq 0 ] && [ $pidphtcnt -eq 0 ] && [ $pidoshcnt -eq 0 ] ; 
then
echo "DSEngine is Running and Listening"
echo ""
echo "Script has initiated the command to stop the DSEngine"
echo ""
#echo "******Output msg of ./uv -admin -stop command*******"
cd  `cat /.dshome`
. ./dsenv
#cd $DSHOME/bin
sudo bin/uv  -admin -stop
#echo "******Output msg of ./uv -admin -stop command*******"
echo "****************************************************"
echo ""
echo "DSEngine has been stopped"
fi
echo "********************************************************"
#***********************************************************************************
echo "*****Now System has started to stop ASBNODE****************"
Liscnt=`netstat -a |grep dsrpc|wc -l`
export Liscnt
Conest=`netstat -a |grep dsrpc|grep -v grep|grep -v LISTEN|awk '{print $5}'|cut -d "." -f1-4|wc -l`
export Conest
Dsrpccnt=`ps -ef |grep dsrpcd|grep -v grep|wc -l`
export Dsrpccnt
srvcnt=`ps -ef |grep server1|grep -v grep|wc -l`
export srvcnt
Asbncnt=`ps -ef |grep ASBNode|grep -v grep|grep RunAgent|wc -l`
export Asbncnt

if [ $Asbncnt  -eq 0 ]
then
echo "ASBNode is not running"
elif [ $Liscnt -eq 0 ] && [ $Dsrpccnt -eq 0 ] ; then
echo " *****ASBNODE is Ruunning***** "
echo ""
echo "Script has initiated the command to stop ASBNODE"
echo ""
echo "******Output msg of ./NodeAgents.sh stop command*******"
#cd $DSHOME
cd `cat /.dshome`
cd ../../ASBNode/bin/
sudo ./NodeAgents.sh stop
echo "****************************************************"
echo ""
echo "ASBNode has been stopped"
fi
echo "********************************************************"

#***********************************************************************************
echo "*****Now System has started to stop WAS****************"
Liscnt=`netstat -a |grep dsrpc|wc -l`
export Liscnt
Conest=`netstat -a |grep dsrpc|grep -v grep|grep -v LISTEN|awk '{print $5}'|cut -d "." -f1-4|wc -l`
export Conest
Dsrpccnt=`ps -ef |grep dsrpcd|grep -v grep|wc -l`
export Dsrpccnt
srvcnt=`ps -ef |grep server1|grep -v grep|wc -l`
export srvcnt
Asbncnt=`ps -ef |grep ASBNode|grep -v grep|grep RunAgent|wc -l`
export Asbncnt

if [ $srvcnt -eq 0 ]
then
echo "WAS is not running"
elif [ $srvcnt  -eq 1 ] && [ $Asbncnt  -eq 0 ] ; then
echo " *****WAS is Ruunning***** "
echo ""
echo "Script has initiated the command to stop Server1"
echo ""
echo "******Output msg of ./MetadataServer.sh stop command*******"
#cd $DSHOME
cd `cat /.dshome`
cd ../../ASBServer/bin/
sudo ./MetadataServer.sh stop
echo "****************************************************"
echo ""
echo "WAS has been stopped"
fi

