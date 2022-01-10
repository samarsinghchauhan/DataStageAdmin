#!/usr/bin/ksh

. /db2home/bcuaix/sqllib/db2profile
####TS="`date +"%Y"`-`date +"%h"`-`date +"%d"`-`date +"%H"`.`date +"%M"`"
BS_DIR=/stage/Script_DBA/OS_Performance
rm $BS_DIR/os_perf.csv

db2 "connect to bisas" > /dev/null
db2 -x "select current timestamp from sysibm.sysdummy1" > $BS_DIR/tmp3.txt
db2 "terminate" > /dev/null
echo "`cat $BS_DIR/tmp3.txt`"
for svr in `cat $BS_DIR/server.txt`
do

      ssh $svr vmstat 1 5 |tail -1|awk '{print $1","$14","$15","$16","$17","$6","$7}' > $BS_DIR/tmp1.txt

      echo "$svr" > $BS_DIR/tmp2.txt
      echo "`cat $BS_DIR/tmp3.txt`" > $BS_DIR/tmp3.txt

echo $svr++++++++++++++++++++++++++++++
cat $BS_DIR/tmp1.txt
cat $BS_DIR/tmp2.txt
cat $BS_DIR/tmp3.txt
echo "$BS_DIR/tmp1.txt===>>>>>>>>====="

echo "$BS_DIR/tmp2.txt===>>>>>>>>====="

        paste -d"," $BS_DIR/tmp3.txt $BS_DIR/tmp2.txt $BS_DIR/tmp1.txt >> $BS_DIR/os_perf.csv
done

echo "######### import to os_performance table ######## "

sh $BS_DIR/import_os_perf.sh > $BS_DIR/import_os_perf.out

__________________________________________________________________________________
import_os_perf.sh
#!/usr/bin/ksh

. /db2home/bcuaix/sqllib/db2profile
DIR=/stage/Script_DBA/OS_Performance
date

db2 -v "connect to bisas"

db2 -v "import from $DIR/os_perf.csv of del insert into PMON.OS_PERFOMANCE"

db2 -v "runstats on table PMON.OS_PERFOMANCE on all columns and detailed indexes all"

db2 -v "terminate"

