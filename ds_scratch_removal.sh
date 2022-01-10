
#!/bin/sh

cd /ETLDATA01/Scratch/Scratch12;
echo `pwd`;
find . -name "ora.*" -mtime +3 -print | xargs rm -rf
echo " Completed .....";
