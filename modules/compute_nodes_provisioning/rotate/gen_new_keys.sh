#!/bin/bash
start=`date +%s.%N`
export DATE=$(date +%d-%m-%Y"-"%H:%M:%S)
ssh-keygen -b 4096 -t rsa -f console-zdm-ssh-key-2021-03-04.key -q -N ""
export NEW_KEY="`cat console-zdm-ssh-key-2021-03-04.key.pub| sed 's/ /*/g'`"
while IFS= read -r line;
do
 ssh -i ../console-zdm-ssh-key-2021-03-04.key oracle@$line  'bash -s' < ./rotate_keys.sh $NEW_KEY $DATE
done<../servers_ip.txt

while IFS= read -r line;
do
 ssh -i console-zdm-ssh-key-2021-03-04.key oracle@$line  'bash -s' 'bash -s' < ./remote_echo.sh  
done<../servers_ip.txt
end=`date +%s`
runtime=$( echo "$end - $start" | bc -l )
echo $runtime

cp ../console-zdm-ssh-key-2021-03-04.key ../console-zdm-ssh-key-2021-03-04.key.${DATE}
cp console-zdm-ssh-key-2021-03-04.key ../console-zdm-ssh-key-2021-03-04.key
while IFS= read -r line;
do
 ssh -i ../console-zdm-ssh-key-2021-03-04.key oracle@$line  'bash -s' 'bash -s' < ./remote_echo.sh  
done<../servers_ip.txt

mv console-zdm-ssh-key-2021-03-04.key console-zdm-ssh-key-2021-03-04.key-ok-${DATE}
mv console-zdm-ssh-key-2021-03-04.key.pub console-zdm-ssh-key-2021-03-04.key-pub-ok-${DATE}
end=`date +%s`



########---count=0
########---while IFS= read -r line;
########---do
########--- echo $line
########--- ssh  -i  ../console-zdm-ssh-key-2021-03-04.key  -o "BatchMode=yes" oracle@$line  'bash -s' < ./remote_echo.sh  
########--- count=`expr $count + 1`
########---done< ../servers_ip.txt
########---printf $count "\n"
########---end=`date +%s`
########---runtime=$( echo "$end - $start" | bc -l )
########---echo $runtime
########---
########---cp console-zdm-ssh-key-2021-03-04.key ../console-zdm-ssh-key-2021-03-04.key
########---
########---
########---
########---