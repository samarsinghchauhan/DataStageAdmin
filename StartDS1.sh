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
echo "*****Now System has started to start WAS****************"
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
if [ $srvcnt = 1 ]
then
echo "WAS is allready running"
elif [ $srvcnt = 0 ] && [ $Asbncnt = 0 ] ; then
echo " *****WAS is Not Ruunning***** "
echo ""
echo "Script has initiated the command to start Server1"
echo ""
echo "******Output msg of ./MetadataServer.sh run command*******"
cd `cat /.dshome`
cd ../../ASBServer/bin/
sudo ./MetadataServer.sh run
echo "****************************************************"
echo ""
echo "WAS has been started"
fi
echo "********************************************************"
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
echo "*****Now System has started to start ASBNODE****************"
if [ $Asbncnt = 1 ]
then
echo "ASBNode is allready running"
elif [ $Liscnt = 0 ] && [ $Dsrpccnt = 0 ] && [ $srvcnt = 1 ] ; then
echo " *****ASBNODE is Not Ruunning***** "
echo ""
echo "Script has initiated the command to start ASBNODE"
echo ""
echo "******Output msg of ./NodeAgents.sh start command*******"
cd `cat /.dshome`
cd ../../ASBNode/bin/
sudo ./NodeAgents.sh start
echo "****************************************************"
echo ""
echo "ASBNode has been started"
fi
echo "********************************************************"
pidslvcnt=`ps -ef |grep slave|grep -v grep |awk 'BEGIN {FS=" "}{print $2 " " $5 " " $6}'|grep -v pts|grep -v "$ad"|cut -d "" -f1|awk 'BEGIN {FS=" "}{print $1}'|wc -l`
export pidslvcnt
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
echo "*****Now System has started to start DSENGINE****************"
if [ $Dsrpccnt = 1 ]
then
echo "DSRPC is allready running"
elif [ $Asbncnt = 1 ] && [ $Liscnt = 0 ] && [ $pidslvcnt = 0 ] && [ $srvcnt = 1 ] ; then
echo "DSEngine is Not Ruunning and Listening"
echo ""
echo "Script has initiated the command to start the DSEngine"
echo ""
echo "******Output msg of ./uv -admin -start command*******"
cd `cat /.dshome`
. ./dsenv
#cd $DSHOME/bin
sudo bin/uv  -admin -start
echo "****************************************************"
echo ""
echo "DSEngine has been started"
fi

