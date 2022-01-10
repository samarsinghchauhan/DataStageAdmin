#!/bin/sh

DSHOME=/software/IBM/InformationServer/Server/DSEngine
export APT_ORCHHOME=/software/IBM/InformationServer/PXEngine

#Prepare DataStage Environment
. $DSHOME/dsenv
export APT_CONFIG_FILE=/software/IBM/InformationServer/Server/Configurations/default.apt

file="/home/dsadm/Script/dssetlist.txt"

while read line
do
      echo "$line"
        cd /data02/prepaid/apps/SCPDB/Outgoing/"$line";
##      pwd >> /home/dsadm/pramod/dslist.txt;
##      find . -name "*.ds" -mmin +360 | xargs ls -lrt;
##      find . -name "*.ds" -mmin +360 -exec orchadmin rm {} \;
      find . -name "*.ds" -mtime +1 -exec orchadmin rm {} \; 
      echo " Cleared the datasets for day -1 "
done <"$file"

echo " ###### Completed ######## "
