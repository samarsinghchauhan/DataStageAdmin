
#!/bin/sh

cd /ETLDATA01/Scratch/Scratch12

##find . -name "*.log" -mtime +30 | xargs ls -lrt > /ETLDATA01/Scratch/Scratch12/Scratch12_list.txt

find . -name "ora.*" -mtime +7 -print > /ETLDATA01/Scratch/Scratch12/list.txt;

file="/ETLDATA01/Scratch/Scratch12/list.txt"

while read line
do
      rm -rf "$line"

done <"$file"

echo " ###### Completed ######## "
