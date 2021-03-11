#!/bin/bash
export PATH=/home/oracle/terraform-excercises/terraform:/home/oracle/.nvm/versions/node/v15.5.1/bin:/home/oracle/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/usr/local/rvm/bin:/usr/local/go/bin:/home/oracle/gocode/bin:/home/oracle/.local/bin:/home/oracle/bin
export ANALYTICS_COMPARTMENT=ocid1.compartment.oc1..aaaaaaaaqhhyjrkidluilxlgk5xer7sox6x7ngcak7hfey3iuvcv45s5oz7a
export ANALYTICS_LOGID=ocid1.loganalyticsloggroup.oc1.eu-frankfurt-1.amaaaaaaufnzx7iakfepgantk22dx4fay7fmhwsx6mmshrdthwwdkg5a7hua
export ANALYTICS_NAMESPACE=frnj6sfkc1ep
export LOG_GROUP_COMPRTMENT=ocid1.compartment.oc1..aaaaaaaaqhhyjrkidluilxlgk5xer7sox6x7ngcak7hfey3iuvcv45s5oz7a
export LOG_GROUP_COMPRTMENT_ID=ocid1.loganalyticsloggroup.oc1.eu-frankfurt-1.amaaaaaaufnzx7iakfepgantk22dx4fay7fmhwsx6mmshrdthwwdkg5a7hua
export LOG_GROUP_NAME=analytics001
cd /home/oracle/terraform-excercises/oci-certification/logging-analytics/modules/compute_nodes_provisioning
START1=`date +%s`


DATE=$(date +%d-%m-%Y"-"%H:%M:%S)
printf  "$DATE:get logs from servers\n"
while IFS= read -r line;
do
 ssh -i console-zdm-ssh-key-2021-03-04.key oracle@$line  'bash -s' < ./make_zip_logs.sh >> /dev/null
done<servers_ip.txt

####
### Log to every remote target and get localy the 2 json files ( database , linux)
###
DATE=$(date +%d-%m-%Y"-"%H:%M:%S)
printf  "$DATE:get create local directory and scp scripts\n"
rm -rf *logan_targets.txt
rm -rf config/*
mkdir -p config
while IFS= read -r line;
do
 echo "scp -o StrictHostKeyChecking=no -i console-zdm-ssh-key-2021-03-04.key oracle@$line:/u01/app/oracle/diag/rdbms/orcl19/orcl19/trace/alert_orcl19.log config/$line/alert_orcl19.log" >> config/logan_targets.txt
 echo "scp -o StrictHostKeyChecking=no -i console-zdm-ssh-key-2021-03-04.key oracle@$line:/var/log/yum.log config/$line/yum.log" >> config/logan_targets.txt
 echo "scp -o StrictHostKeyChecking=no -i console-zdm-ssh-key-2021-03-04.key oracle@$line:/tmp/all.zip config/$line/all.zip" >> config/logan_targets.txt
done<servers_ip.txt


###
### i have an issue with my VBOx on the remote ssh and to workaround i m using the root user
### we dont need ro run this as root if the normal user can execute remote ssh
###
###
### i have an issue with my VBOx on the remote ssh and to workaround i m using the root user
### we dont need ro run this as root if the normal user can execute remote ssh
### rm -rf config/*

while IFS= read -r line;
do
 mkdir -p config/$line
done<servers_ip.txt

DATE=$(date +%d-%m-%Y"-"%H:%M:%S)
printf  "$DATE:get logs from servers\n"

sudo su<<EOF
source   config/logan_targets.txt >> /dev/null
chmod -R ugo+rw config/*
chown  -R  oracle:oracle config/
EOF

DATE=$(date +%d-%m-%Y"-"%H:%M:%S)
printf  "$DATE:unzip recreate zip files to upload to analytics\n"
while IFS= read -r line;
do
 unzip -o -j config/$line/all.zip -d config/$line >> /dev/null
 rm -rf config/$line/all.zip
 cd config/$line
 for files in *.zip
 do
 echo $files >> /dev/null
 export directory=`basename $files .zip`
 echo $directory >> /dev/null
 mkdir -p $directory
 unzip -j $files -d  $directory >> /dev/null 2>&1
 rm -rf $files
 zip -j -r  $directory.zip $directory >> /dev/null 2>&1
 done
 cd ../..
done<servers_ip.txt

DATE=$(date +%d-%m-%Y"-"%H:%M:%S)
printf  "$DATE:delete all the previous logs from the loagan compartement\n"



export NB_FILES_LOGAN=`oci log-analytics upload list-upload-files  \
--profile DBSEC \
--namespace-name $NAMESPACE \
--upload-reference "-4128418186429303198" \
--all | jq '.data.items[] | .reference' | sed 's/"//g' > files_logan && wc -l files_logan| sed 's/files_logan//g'`

DATE=$(date +%d-%m-%Y"-"%H:%M:%S)
printf  "$DATE:files before uploads:$NB_FILES_LOGAN\n"

oci log-analytics upload delete \
--profile DBSEC \
--namespace-name $ANALYTICS_NAMESPACE \
--upload-reference "-4128418186429303198" --force >> /dev/null

DATE=$(date +%d-%m-%Y"-"%H:%M:%S)
printf  "$DATE:reload the logs to the loagan compartement\n"
while IFS= read -r line;
do
 cd config/$line
 export ENTITY_ID=`cat agent.txt`

entity_id=`oci log-analytics entity list \
--profile DBSEC \
--compartment-id ocid1.compartment.oc1..aaaaaaaaqhhyjrkidluilxlgk5xer7sox6x7ngcak7hfey3iuvcv45s5oz7a \
--namespace frnj6sfkc1ep \
--lifecycle-state ACTIVE \
--name dbcs_${line} | jq '.data.items[] | .id' | sed 's/"//g'`

oci log-analytics upload upload-log-file \
--profile DBSEC \
--file alert_log.zip \
--filename alert_log.zip \
--log-source-name DBAlertLogSource \
--namespace-name $ANALYTICS_NAMESPACE \
--opc-meta-loggrpid $LOG_GROUP_COMPRTMENT_ID \
--entity-id $entity_id \
--upload-name logginganalytics-analytics001 >> /dev/null
DATE=$(date +%d-%m-%Y"-"%H:%M:%S)
printf  "$DATE:${line}:reload alert_log.zip\n"


oci log-analytics upload upload-log-file \
--profile DBSEC \
--file DBAlertXMLLogSource.zip \
--filename dbalertxmllogsource.zip \
--log-source-name DBAlertXMLLogSource \
--namespace-name $ANALYTICS_NAMESPACE \
--opc-meta-loggrpid $LOG_GROUP_COMPRTMENT_ID \
--entity-id $entity_id \
--upload-name logginganalytics-analytics001 >> /dev/null
DATE=$(date +%d-%m-%Y"-"%H:%M:%S)
printf  "$DATE:${line}:reload dbalertxmllogsource.zip\n"

oci log-analytics upload upload-log-file \
--profile DBSEC \
--file incident.zip \
--filename incident.zip \
--log-source-name DBIncidentDumpSource \
--namespace-name $ANALYTICS_NAMESPACE \
--opc-meta-loggrpid $LOG_GROUP_COMPRTMENT_ID \
--entity-id $entity_id \
--upload-name logginganalytics-analytics001 >> /dev/null
DATE=$(date +%d-%m-%Y"-"%H:%M:%S)
printf  "$DATE:${line}:reload incident.zip\n"

oci log-analytics upload upload-log-file \
--profile DBSEC \
--file TNSAlertLogSource.zip \
--filename tnsalertlogsource.zip \
--log-source-name TNSAlertLogSource \
--namespace-name $ANALYTICS_NAMESPACE \
--opc-meta-loggrpid $LOG_GROUP_COMPRTMENT_ID \
--upload-name logginganalytics-analytics001 >> /dev/null
DATE=$(date +%d-%m-%Y"-"%H:%M:%S)
printf  "$DATE:${line}:reload tnsalertlogsource.zip\n"

oci log-analytics upload upload-log-file \
--profile DBSEC \
--file trace.zip \
--filename trace.zip \
--log-source-name DBTraceLogSource \
--namespace-name $ANALYTICS_NAMESPACE \
--opc-meta-loggrpid $LOG_GROUP_COMPRTMENT_ID \
--entity-id $entity_id \
--upload-name logginganalytics-analytics001 >> /dev/null
DATE=$(date +%d-%m-%Y"-"%H:%M:%S)
printf  "$DATE:${line}:reload trace.zip\n"

entity_id=`oci log-analytics entity list \
--profile DBSEC \
--compartment-id ocid1.compartment.oc1..aaaaaaaaqhhyjrkidluilxlgk5xer7sox6x7ngcak7hfey3iuvcv45s5oz7a \
--namespace frnj6sfkc1ep \
--lifecycle-state ACTIVE \
--name linux_${line} | jq '.data.items[] | .id' | sed 's/"//g'`

oci log-analytics upload upload-log-file \
--profile DBSEC \
--file yum.log \
--filename yum.log \
--log-source-name LinuxYUMLogSource \
--namespace-name $ANALYTICS_NAMESPACE \
--opc-meta-loggrpid $LOG_GROUP_COMPRTMENT_ID \
--entity-id $entity_id \
--upload-name logginganalytics-analytics001 >> /dev/null
DATE=$(date +%d-%m-%Y"-"%H:%M:%S)
printf  "$DATE:${line}:yum.log\n"


cd  ../..
done<servers_ip.txt

export NEW_FILES_LOGAN=`oci log-analytics upload list-upload-files  \
--profile DBSEC \
--namespace-name $NAMESPACE \
--upload-reference "-4128418186429303198" \
--all | jq '.data.items[] | .reference' | sed 's/"//g' > new_files && wc -l new_files | sed 's/new_files//g'`

DATE=$(date +%d-%m-%Y"-"%H:%M:%S)
printf  "$DATE:files after uploads:$NEW_FILES_LOGAN\n"
printf  "$DATE:new file uploads:" `expr $NEW_FILES_LOGAN - $NB_FILES_LOGAN` "\n"
##`expr $count + 1`
end=`date +%s`
runtime=$( echo "$end - $start" | bc -l )

echo Execution time was $runtime seconds.

##


########---oci log-analytics source list-sources \
########-----profile DBSEC \
########-----compartment-id ocid1.loganalyticsloggroup.oc1.eu-frankfurt-1.amaaaaaaufnzx7iakfepgantk22dx4fay7fmhwsx6mmshrdthwwdkg5a7hua \
########-----namespace-name $ANALYTICS_NAMESPACE \
########-----all