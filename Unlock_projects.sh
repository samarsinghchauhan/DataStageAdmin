#!/bin/sh
#!/bin/bash
myid=`who am i|awk '{print $6}'`
TIME=`date|awk '{print $4}'`
TIME1=`date|awk '{print $2 $3}'`
DIR=/home/dsadm/DS_Admin
cd `cat /.dshome`
. ./dsenv
#`cat /.dshome`/../Projects |grep ^d |awk '{print $NF} > ${DIR}/all_projects.txt
for project in `cat ${DIR}/all_projects.txt`
do

`cat /.dshome`/bin/uvsh << EOF
LOGTO ${project}
UNLOCK ALL
UNLOCK ALL
UNLOCK ALL
UNLOCK ALL
UNLOCK ALL
UNLOCK ALL
Q
EOF

done
echo "This scripts has been executed On $TIME1 at $TIME through $myid" >> $DIR/Unlock_projects.txt
