echo "Enter the new password to be kept"
sudo passwd dsadm
sudo pwdadm -c dsadm
sudo passwd xmeta
sudo pwdadm -c xmeta




cd `cat /.dshome`
cd ../../ASBServer/bin/

echo "Enter the new password to be kept for xmeta user"
read -s Pass 
xmeta_chnge=`sudo ./AppServerAdmin.sh -db -user xmeta -password $Pass | grep -i "Propagation of the 'apps' package successfully completed."|awk '{print $1}'`
if [ "$xmeta_chnge" = "Propagation" ]
then
echo "Xmeta User password updated successfully"
else 
echo "Xmeta user password not updated "
fi
echo "**********changing wsadmin password ******************"
echo "Enter the new password to be kept for Wsadmin user"
read -s Pass 
wsadmin_chnge=`sudo ./AppServerAdmin.sh -was -user wsadmin -password $Pass | grep -i "Info MetadataServer daemon script updated with new user information" |awk '{print $1}'`

if [ "$wsadmin_chnge" = "Info" ]

then
echo "wsadmin User password updated successfully"
else 
echo "wsadmin user password not updated "
fi

cd ../../ASBServer/bin/
echo "updating Directory admin with new password"
sudo ./DirectoryAdmin.sh -user -userid wsadmin -password $Pass 
