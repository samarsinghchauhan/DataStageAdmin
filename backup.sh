ts=`date +%Y-%m-%d`
pwd
DIR="/home/dsadm/DS_Admin"
while read project
do
cd `cat /.dshome`
cd ../../Clients/istools/cli/
z=`echo $project"_"$ts`
x=`hostname`
y=`echo "\"$x/$project/*/*.*\"`
Excmd=`./istool export -domain $x:9080 -username $1 -password $2 -archive "/data2/DSAdmin/BACKUPS/144_Backup/$z.isx" -datastage " $y " | grep -i "Exported" | awk '{print $1}'`

if [ "$Excmd" = "Exported" ]
then
echo "Export completed successfully"
else
echo " Export failed"
fi
done < $DIR/all_projects.txt

