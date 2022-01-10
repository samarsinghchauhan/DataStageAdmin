#!/bin/bash

. ${HOME}/.profile

echo "=================================================================================="
echo "=                      DS SERVICES START/STOP TOOL                               ="
echo "=================================================================================="
echo "=================================================================================="
echo "=PLS ENTER THE DESIRED OPTION                                                    ="
echo "=================================================================================="
echo "=                       MENU                                                     ="
echo "=                                                                                ="
echo "=1. Killing salve,osh,dscs and phantom process                                   ="
echo "=2. Stopping DataStage Services                                                  ="
echo "=3. Password Change Activity                                                     ="
echo "=4. Starting DataStage Services                                                  ="  
echo "=================================================================================="
echo "=================================================================================="
echo "Enter Choice:"
read choice

if [ $choice -eq 1 ]
then
sh Process_kill.sh
else if [ $choice -eq 2 ]
     then
     sh StopDS1.sh  

else if [ $choice -eq 3 ]
          then
          sh Pass_ch.sh

else if [ $choice -eq 4 ]
                         then
                         sh StartDS1.sh

else
echo "INVALID CHOICE...."
fi
                      fi
                   fi
            
         fi

