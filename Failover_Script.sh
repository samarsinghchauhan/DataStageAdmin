#!/usr/bin/bash
#!/bin/sh
TT=`date +"%Y"`-`date +"%m"`-`date +"%d"`
export TT
F_Date=`date +%b" "%d`
Pre_DT=`perl -MPOSIX -le 'print strftime( "%b %d", localtime(time() - 24*60*60*1))'`
####Pre_DT=`TZ=GMT+24 date +%b" "%d`
###########Pre_DT="May 30"
DIR1="/home/dsadm/DS_Admin/PDOA_Fail_Over"
export DIR1
cd $DIR1
rm *.list* *.txt* *.apt*
echo "Old Files Deleted"
cd /opt_ibm/IBM/InformationServerP/sqllib
cp db2nodes.cfg db2nodes.cfg_$TT
cp db2nodes.cfg $DIR1
cd $DIR1
cp db2nodes.cfg db2nodes.cfg_$TT
File1=`ssh svdg0404 ls -lrt /db2home/bcuaix/sqllib/db2nodes.cfg | grep "$F_Date"|awk '{print $9}'|cut -d "/" -f5`
File_Name=`echo $File1|grep -v ^$|wc -l`
File2=`ssh svdg0404 ls -lrt /db2home/bcuaix/sqllib/db2nodes.cfg | grep "$Pre_DT"|awk '{print $9}'|cut -d "/" -f5`
File2_Name=`echo $File2|grep -v ^$|wc -l`
if [ $File_Name -eq 1  -o $File2_Name -eq 1 ]
then
scp svdg0404:/db2home/bcuaix/sqllib/db2nodes.cfg /home/dsadm/DS_Admin/PDOA_Fail_Over
scp svdg0404:/db2home/bcuaix/sqllib/db2nodes.cfg /opt_ibm/IBM/InformationServerP/sqllib 
echo "Latest File Found and Trrasfer to PATH /opt_ibm/IBM/InformationServerP/sqllib"
else
echo "Latest File Not Found ***FAILOVER NOT HAPPEN***"
fi
DIR="/opt_ibm/IBM/InformationServerP/Server/Configurations"
cd $DIR
mkdir Config_Backup_$TT
cp *.apt $DIR1
cd $DIR1
cp db2nodes.cfg /opt_ibm/IBM/InformationServerP/sqllib
cat db2nodes.cfg_$TT|awk '{print $2}'|uniq > Existing_Active_Server.list
cat db2nodes.cfg|awk '{print $2}'|uniq > New_Active_Server.list
diff Existing_Active_Server.list New_Active_Server.list > New_Node_Server.list
cat New_Node_Server.list|awk '{print $2}' > New_Node_Server1.list
sed '/^$/d' New_Node_Server1.list > New_Node_Server_tmp.list
mv New_Node_Server_tmp.list Node_Server.txt
cat Node_Server.txt
perl -ne 'chomp; push @x,$_; END {print join " ", @x; print "\n"}' Node_Server.txt > p2.txt
cat p2.txt |awk '{print$1"\n"$3"\n"$5"\n"$7}' > a.txt
cat p2.txt |awk '{print$2"\n"$4"\n"$6"\n"$8}' > b.txt
sed '/^$/d' a.txt >a_tmp.txt && mv a_tmp.txt a.txt
sed '/^$/d' b.txt >b_tmp.txt && mv b_tmp.txt b.txt
paste a.txt b.txt>cc.txt
ls -rlt *.apt | awk '{print $9}' > aptconfglist.txt
for i in `cat aptconfglist.txt`
do
cp $i $i.bkp
while read line
do
aa=`echo $line |awk '{print $1}'`
bb=`echo $line |awk '{print $2}'`
sed "s/$aa/$bb/g" "$i" > ${i}_NEW.txt && mv ${i}_NEW.txt "$i"
####sed "s/$bb/$aa/g" "$i" > ${i}_NEW.txt && mv ${i}_NEW.txt "$i"
done<cc.txt
done
#####done < $DIR1/aptconfglist.txt
mv $DIR1/*.bkp $DIR/Config_Backup_$TT
cp $DIR1/*.apt $DIR
