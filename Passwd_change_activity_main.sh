#!/usr/bin/ksh

echo "=================================================================================="
echo "=                      DS SERVICES START/STOP TOOL                               ="
echo "=================================================================================="
echo "=                           Ranjeet Kumar                                     ="                                 
echo "=================================================================================="
echo "=PLS ENTER THE DESIRED OPTION                                                    ="
echo "=================================================================================="
echo "=                                   MENU                                         ="
echo "=================================================================================="
echo "=1. Killing salve,osh,dscs and phantom process                                   ="
echo "=2. Stopping DataStage Services                                                  ="
echo "=3. Change DS application users passwords at OS level                            ="
echo "=====>>>>>>> Stop DB2 before choosing the option 4 <<<<<<<<<<<<<<<<<<            =" 
echo "=4. Password Change Activity - Update new passwords in application level         ="
echo "=====>>>>>>> Start DB2 before choosing the option 5 <<<<<<<<<<<<<<<<<<           ="
echo "=5. Password Change Activity - Update new passwords in DS console level          ="
echo "=6. Starting DataStage Services                                                  ="
echo "=7. Clearing RT_LOG, RT_STATUS, and PH files                                     ="
echo "=================================================================================="

pass=$1;
if [ $pass ]
then
echo "";
else
echo "Please enter the dsadm user current password:";
read x;
pass=$x;
fi

DSHOME=`cat /.dshome`;
echo "DSHOME path : $DSHOME ";
cd $DSHOME;
cd ../../ASBNode/bin;
ASBN=`pwd`;
echo " ASBNode path : $ASBN ";
cd ../../ASBServer/bin;
ASBS=`pwd`;
echo " ASBServer path : $ASBS ";

dsrpc_count=`ps -ef |grep dsrpcd|grep -v grep|wc -l`;
if [ $dsrpc_count -ne 0 ]
then
cd $DSHOME;
. ./dsenv;
ds_projs=`$DSHOME/bin/dsjob -lprojects`;
echo "DataStage Projects are:\n $ds_projs \n";
else
echo "";
fi

Clear_RT_LOG()
{
dsrpc_count=`ps -ef |grep dsrpcd|grep -v grep|wc -l`;
if [ $dsrpc_count -ne 0 ]
then

echo "Clearing the RT_LOG for all projects \n";
for project in $ds_projs
do

echo "Clearing the RT_LOG for the project : $project \n";
cd `cat /.dshome`;
. ./dsenv
cd ../Projects/$project
rt_log=`du -m RT_LOG* | awk '{print "CLEAR.FILE "  $2}'`
`cat /.dshome`/bin/uvsh << EOF
LOGTO ${project}
UNLOCK ALL
`echo "$rt_log"`

Q
EOF
done
else
echo " DataStage services are not running to clear RT_LOG files ";
fi
}

Clear_RT_STATUS()
{
dsrpc_count=`ps -ef |grep dsrpcd|grep -v grep|wc -l`;
if [ $dsrpc_count -ne 0 ]
then
echo "Clearing the RT_STATUS for all projects \n";
for project in $ds_projs
do

echo "Clearing the RT_STATUS for the project : $project \n";
cd `cat /.dshome`;
. ./dsenv
cd ../Projects/$project
rt_status=`du -m RT_STATUS* | awk '{print "CLEAR.FILE "  $2}'`;
`cat /.dshome`/bin/uvsh << EOF
LOGTO ${project}
UNLOCK ALL
`echo "$rt_status";`

Q
EOF
done
else
echo " DataStage services are not running to clear RT_STATUS files ";
fi
}

Clear_PH()
{
dsrpc_count=`ps -ef |grep dsrpcd|grep -v grep|wc -l`;
if [ $dsrpc_count -ne 0 ]
then
echo "Clearing the PH files for all projects \n";
cd `cat /.dshome`
. ./dsenv

for project in $ds_projs
do
`cat /.dshome`/bin/uvsh << EOF
LOGTO ${project}
CLEAR.FILE &PH&
UNLOCK ALL
Q
EOF
done
else
echo " DataStage services are not running to clear RT_STATUS files ";
fi
}

Kill_Proc()
{
echo "Clearing the dscs process \n";
dscs_count=`ps -ef | grep dscs |grep -v grep | wc -l`;
dscs_list=`ps -ef | grep dscs | grep -v grep | awk '{print $2}'|tr "\n" " "`;
echo "dscs process list: $dscs_count";
if [ $dscs_count -gt 0 ]
then
echo "$pass" | sudo -S kill -9 $dscs_list
echo "Cleared the all dscs process \n";
else
echo "dscs processes are not found to clear \n";
fi

sleep 15;
echo "Clearing the slave process \n";
slave_count=`ps -ef | grep slave | grep -v grep | wc -l`;
slave_list=`ps -ef | grep slave | grep -v grep | awk '{print $2}'|tr "\n" " "`;
echo "slave process list: $slave_count";
if [ $slave_count -gt 0 ]
then
echo "$pass" | sudo -S kill -9 $slave_list
echo "Cleared the all slave process \n";
else
echo "slave processes are not found to clear \n";
fi

sleep 15;
echo "Clearing the osh process \n";
osh_count=`ps -ef | grep osh | grep -v grep | wc -l`;
osh_list=`ps -ef | grep osh | grep -v grep | awk '{print $2}'|tr "\n" " "`;
echo "osh process list: $osh_count";
if [ $osh_count -gt 0 ]
then
echo "$pass" | sudo -S kill -9 $osh_list
echo "Cleared the all osh process \n";
else
echo " osh processes are not found to clear \n";
fi

sleep 15;
echo "Clearing the phantom process \n";
ph_count=`ps -ef | grep phantom | grep -v grep | wc -l`;
ph_list=`ps -ef | grep phantom | grep -v grep | awk '{print $2}'|tr "\n" " "`;
echo "phantom process list: $ph_count";
if [ $ph_count -gt 0 ]
then
echo "$pass" | sudo -S kill -9 $ph_list
echo "Cleared the all phantom process \n";
else
echo " phantom processes are not found to clear \n";
fi
}

Stop_DSEngine()
{
dsrpc_count=`ps -ef |grep dsrpcd|grep -v grep|wc -l`;
if [ $dsrpc_count -eq 0 ]
then
echo " DataStage Engine is not running \n";
else
echo "Stopping the DataStage Engine \n";
cd `cat /.dshome`;
. ./dsenv
echo "$pass" | sudo -S $DSHOME/bin/uv -admin -stop
echo " DataStage Engine has been stopped. \n";
fi
}

Start_DSEngine()
{
dsrpc_count=`ps -ef |grep dsrpcd|grep -v grep|wc -l`;
if [ $dsrpc_count -ne 0 ]
then
echo " DataStage Engine is running \n";
else
echo "Starting the DataStage Engine \n";
cd `cat /.dshome`;
. ./dsenv
echo "$pass" | sudo -S $DSHOME/bin/uv -admin -start
echo " DataStage Engine has been started. \n";
fi
}


Stop_ASBNode()
{
asbnode_count=`ps -ef |grep ASB|grep -v grep|wc -l`;
if [ $asbnode_count -eq 0 ]
then
echo " ASBNode is not running \n";
else
echo "Stoping the ASBNode \n";
echo "$pass" | sudo -S $ASBN/NodeAgents.sh stop
echo " ASBNode has been stopped. \n";
fi
}

Start_ASBNode()
{
asbnode_count=`ps -ef |grep ASB|grep -v grep|wc -l`;
if [ $asbnode_count -ne 0 ]
then
echo " ASBNode is running \n";
else
echo "Starting the ASBNode \n";
echo "$pass" | sudo -S $ASBN/NodeAgents.sh start
echo " ASBNode has been started. \n";
fi
}


Stop_WAS()
{
was_count=`ps -ef |grep server1|grep -v grep|wc -l`;
if [ was_count -eq 0 ]
then
echo " WAS is not running \n";
else
echo "Stopping the WAS \n";
echo "$pass" | sudo -S $ASBS/MetadataServer.sh stop
echo " WAS has been stopped. \n";
fi
}

Start_WAS()
{
was_count=`ps -ef |grep server1|grep -v grep|wc -l`;
if [ was_count -ne 0 ]
then
echo " WAS is running \n";
else
echo "Starting the WAS \n";
echo "$pass" | sudo -S $ASBS/MetadataServer.sh run
echo " WAS has been started. \n";
fi
}

Stop_DB2()
{
db2user_count=`echo "$pass" | sudo -S -l | grep db2inst1 | grep -v grep | wc -l`;
if [ $db2user_count -eq 0 ]
then
echo "Command sudo su to db2_user is not in sudo list, Please stop the DB2 manually \n";
else
db2proc_count=`ps -ef | grep db2sysc | grep -v grep | wc -l`;
if [ $db2proc_count -eq 0 ]
then
echo " DB2 is not running \n";
else
echo "Stopping the DB2 xmeta \n";
echo "$pass" | sudo -S su - db2inst1;
db2 list db directory;
db2 list applications;
#db2 deactivate db xmeta;
#db2stop;
return;
fi
fi
}

Start_DB2()
{
db2user_count=`echo "$pass" | sudo -S -l | grep db2inst1 | grep -v grep | wc -l`;
if [ $db2user_count -eq 0 ]
then
echo "Command sudo su to db2user is not in sudo list, Please start the DB2 manually \n";
else
db2proc_count=`ps -ef | grep db2sysc | grep -v grep | wc -l`;
if [ $db2proc_count -ne 0 ]
then
echo " DB2 is running \n";
else
echo "Starting the DB2 xmeta \n";
echo "$pass" | sudo -S su - db2inst1;
#db2start;
#db2 activate db xmeta;
return;
fi
fi
}

Update_pass_App()
{
dsrpc_count=`ps -ef |grep dsrpcd|grep -v grep|wc -l`;
asbnode_count=`ps -ef |grep ASB|grep -v grep|wc -l`;
was_count=`ps -ef |grep server1|grep -v grep|wc -l`;
db2proc_count=`ps -ef | grep db2sysc | grep -v grep | wc -l`;

if [ $db2proc_count -eq 0 ]
then
echo " Updating the xmeta user at application level \n";
echo "$pass" | sudo -S $ASBS/AppServerAdmin.sh -db -user xmeta -password $pass
echo " Xmeta user updation has been completed \n";
echo " Updating the wsadmin user at application level \n";
echo "$pass" | sudo -S $ASBS/AppServerAdmin.sh -was -user wsadmin -password $pass
echo " Wsadmin user updation has been completed \n";
else
echo " One of the DataStage services are up and running, please stop the all services before updation users at application level. \n"
fi
}

Update_pass_Console()
{
dsrpc_count=`ps -ef |grep dsrpcd|grep -v grep|wc -l`;
asbnode_count=`ps -ef |grep ASB|grep -v grep|wc -l`;
was_count=`ps -ef |grep server1|grep -v grep|wc -l`;
db2proc_count=`ps -ef | grep db2sysc | grep -v grep | wc -l`;

if [ $db2proc_count -ne 0 ]
then
echo " Updating the wsadmin user at console level \n";
echo "$pass" | sudo -S $ASBS/DirectoryAdmin.sh -user -userid wsadmin -password $pass
echo "$pass" | sudo -S $ASBS/DirectoryAdmin.sh -user -userid isadmin -password $pass -admin
echo " wsadmin user updation has been completed at console level \n";
else
echo "Please check the services - DSEngine, ASBNode, and WAS applications status should be Stopped, And DB2 services are up running BEFORE updation wsadmin user at console level. \n"
fi
}

Change_OS_Pass()
{
echo "Changing the OS Users password \n";

pass_count=`echo "$pass" | sudo -S -l | grep passwd | grep -v grep | wc -l`;

if [ $pass_count -ne 0 ]
then

echo "Changing the password for xmeta user \n";
echo "Please enter the pass password for xmeta user \n";
echo "$pass" | sudo -S passwd xmeta
echo "$pass" | sudo -S pwdadm -c xmeta
echo "Changed the xmeta user password at OS level \n";

isadmin_count=`lsuser isadmin | wc -l`;
if [ $isadmin_count -ge 1 ]
then
echo "Changing the password for isadmin user \n";
echo "Please enter the pass password for isadmin user \n";
echo "$pass" | sudo -S passwd isadmin;
echo "$pass" | sudo -S pwdadm -c isadmin;
echo "Changed the isadmin user password at OS level \n";
else
echo "User isadmin is not present at OS level \n";
fi

wsadmin_count=`lsuser wsadmin | wc -l`;
if [ $wsadmin_count -ge 1 ]
then
echo "Changing the password for wsadmin user \n";
echo "Please enter the pass password for wsadmin user \n";
echo "$pass" | sudo passwd wsadmin
echo "$pass" | sudo -S pwdadm -c wsadmin
echo "Changed the wsadmin user password at OS level \n";
else
echo "User wsadmin is not present at OS level \n";
fi

echo "Changing the password for dsadm user \n";
echo "Please enter the pass password for dsadm user \n";
#echo -n "$pass" | sudo -S passwd dsadm
#echo -n "$pass" | sudo -S pwdadm -c dsadm
echo "Changed the dsadm user password at OS level \n";

else
echo "Sudo command passwd not in sudo list, Please change the password for OS users manually \n";
echo "Is it changed the password manually at OS level \n";
exit;
fi
}


DS_Main()
{
echo " Main program started \n";
}

echo "Enter Choice:"
read choice

if [ $choice -eq 1 ]
then
Kill_Proc;

else if [ $choice -eq 2 ]
then
Stop_DSEngine;
sleep 20;
Stop_ASBNode;
sleep 20;
Stop_WAS;
##Stop_DB2;
echo " Please stop DB2 manually ";

else if [ $choice -eq 3 ]
then
Change_OS_Pass;
echo "Please verify logins and if not working, change the OS Level passwords manually";

else if [ $choice -eq 4 ]
then
Update_pass_App;

else if [ $choice -eq 5 ]
then
echo "Please start DB2 manually Before you choose this option";
##Start_DB2;
sleep 30;
Update_pass_Console;

else if [ $choice -eq 6 ]
then
echo "Please check db2 process, if not up, start db2 manually"; 
sleep 20;
Start_WAS;
sleep 20;
Start_ASBNode;
sleep 20;
Start_DSEngine;

else if [ $choice -eq 7 ]
then
echo "Clearing the RT_LOG, RT_STATUS, AND PH files";
Clear_RT_LOG;
sleep 20;
Clear_RT_STATUS;
sleep 20;
Clear_PH;
else
echo "INVALID CHOICE...."
fi
fi
fi
fi
fi
fi
fi

echo " Main program Completed\n";

