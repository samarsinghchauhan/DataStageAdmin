##THIS SCRIPT CHECKS FOR THE SIZE OF RT_LOG FILES AND PUT THE ENTRIES IN THE FILE "DS_LOG_THRESHOLD" IF IT EXCEEDS 100MB######################
workdt=`date +"%Y%m%d%H%M%S"`
workdir=/home/dsadm/RT_LOG_CHK/
logdir=/home/dsadm/RT_LOG_CHK/logdir
######################### Removing old files ############################################
###find ${logdir} -name "*LOG_THRESHOLD*" -mmin +15 -exec rm -f {} \;
#########################################################################################
for x in `cat ${workdir}/project_list`
do
projname=`echo $x|cut -d":" -f1`
projloc=`echo $x|cut -d":" -f2`
uflag=`echo $x|cut -d":" -f3`

if [ $uflag = "y" ]
then

##if [ -s ${logdir}/DS_LOG_THRESHOLD_${projname} ]; then
       ##rm  ${logdir}/DS_LOG_THRESHOLD_${projname}
##fi

cd $projloc
du -k | grep RT_LOG | awk '{print $1 " " $2}' > ${logdir}/ds_logfiles_${projname}
while read line
do
        filesize=`echo $line | awk '{print $1}'`
        filename=`echo $line | awk '{print $2}'|awk -F "\/" ' { print $NF }'`

        if [ $filesize -gt 1048576 ]; then
                echo $filesize
                echo "Size of the File :  ${projloc}/${filename}_exceeds_threshold:${filesize}" >> ${logdir}/DS_LOG_THRESHOLD_${projname}
        ##chmod 700 ${logdir}/DS_LOG_THRESHOLD_${projname}
        fi
done < ${logdir}/ds_logfiles_${projname}
fi
done
