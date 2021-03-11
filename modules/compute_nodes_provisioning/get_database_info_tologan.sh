### Eugene Simos EMEA Presales Security Team
### How to use the script
### Update the export with your own settings
### create an OCI profile for the OCI cli ( --profile DBSEC should target your own setting look into the docs oci cli --profile)
###
###  create a file with the target DataBases IP
###  replace the cd  .... with your own directories
###  there are few things "harcoded" as the port of the DB look into the json files and modify them if needed
###

export ANALYTICS_COMPARTMENT=ocid1.compartment.oc1..aaaaaaaaqhhyjrkidluilxlgk5xer7sox6x7ngcak7hfey3iuvcv45s5oz7a
export ANALYTICS_LOGID=ocid1.loganalyticsloggroup.oc1.eu-frankfurt-1.amaaaaaaufnzx7iakfepgantk22dx4fay7fmhwsx6mmshrdthwwdkg5a7hua
export ANALYTICS_NAMESPACE=frnj6sfkc1ep
export LOG_GROUP_COMPRTMENT=ocid1.compartment.oc1..aaaaaaaaqhhyjrkidluilxlgk5xer7sox6x7ngcak7hfey3iuvcv45s5oz7a
export LOG_GROUP_COMPRTMENT_ID=ocid1.loganalyticsloggroup.oc1.eu-frankfurt-1.amaaaaaaufnzx7iakfepgantk22dx4fay7fmhwsx6mmshrdthwwdkg5a7hua
export LOG_GROUP_NAME=analytics001
cd /home/oracle/terraform-excercises/oci-certification/logging-analytics/modules/compute_nodes_provisioning

### read from the servers_ip.txt the ip of your targets
### in our case we deal with database server 
### so first step execute the database_config_for_analytics.sh to get the settings for the database entity
### the script created per databas e2 json files one for the database entity and one for the linux host


while IFS= read -r line;
do
 ssh -i console-zdm-ssh-key-2021-03-04.key oracle@$line  'bash -s' < ./database_config_for_analytics.sh
done<servers_ip.txt

####
### Log to every remote target and get localy the 2 json files ( database , linux)
###
rm -rf logan_targets.txt
rm -rf config
mkdir -p config
while IFS= read -r line;
do
 echo "scp -o StrictHostKeyChecking=no -i console-zdm-ssh-key-2021-03-04.key oracle@$line:/home/oracle/database_entity.json config/database_entity-$line.json" >> logan_targets.txt
 echo "scp -o StrictHostKeyChecking=no -i console-zdm-ssh-key-2021-03-04.key oracle@$line:/home/oracle/linux_entity.json config/linux_entity-$line.json" >> logan_targets.txt
 echo "scp -o StrictHostKeyChecking=no -i console-zdm-ssh-key-2021-03-04.key oracle@$line:/u01/app/oracle/diag/rdbms/orcl19/orcl19/trace/alert_orcl19.log config/alert_orcl19_$line.log" >> logan_targets.txt
 echo "scp -o StrictHostKeyChecking=no -i console-zdm-ssh-key-2021-03-04.key oracle@$line:/var/log/yum.log config/yum_$line.log" >> logan_targets.txt
 echo "scp -o StrictHostKeyChecking=no -i console-zdm-ssh-key-2021-03-04.key oracle@$line:/tmp/all.zip config/all_$line.zip" >> logan_targets.txt
done<servers_ip.txt
cat logan_targets.txt

###
### i have an issue with my VBOx on the remote ssh and to workaround i m using the root user
### we dont need ro run this as root if the normal user can execute remote ssh
###
sudo su<<EOF
rm -rf config/*
source logan_targets.txt
chmod ugo+rw config/*
chown oracle:oracle config/*
EOF

for file in config/all*.zip 
do
 export directory=`basename $file .zip`
 export entity_ip="`echo dbcs_$directory | sed 's/all_//g'`"
 mkdir -p config/$entity_ip
 unzip -o -j $file -d config/$entity_ip
done


###
### every json file has tags that they hav eto be replaced with the correct settings to create the entities (linux)
###
rm -rf linux_entities_id.txt
for files in config/linux*
do
  sed "s/\$ANALYTICS_COMPARTMENT/$ANALYTICS_COMPARTMENT/g" -i $files
  sed "s/\$ANALYTICS_NAMESPACE/$ANALYTICS_NAMESPACE/g" -i $files
  oci log-analytics entity create  \
  --profile DBSEC \
  --from-json file://$files | jq ' .data  | "\(."management-agent-id") \(.id) \(.name)"'| sed 's/"//g' >> linux_entities_id.txt
done

####
####  same here create the databse entities
###
rm -rf database_entities_id.txt
for files in config/database*
do
  sed "s/\$ANALYTICS_COMPARTMENT/$ANALYTICS_COMPARTMENT/g" -i $files
  sed "s/\$ANALYTICS_NAMESPACE/$ANALYTICS_NAMESPACE/g" -i $files
  oci log-analytics entity create  \
  --profile DBSEC \
  --from-json file://$files |  jq ' .data  | "\(."management-agent-id") \(.id) \(.name) \(.hostname)"'| sed 's/"//g' >> database_entities_id.txt
done

### create the associations Linux
### when the entities are created we pass a script to associate all linux log from the logan sources 
###
while IFS= read -r line;
do
 export AGENT_ID=`echo $line |  awk -F ' ' '{print $1}'`
 export ENTITY_ID=`echo $line |  awk -F ' ' '{print $2}'`
 export NAME_ENTITY=`echo $line |  awk -F ' ' '{print $3}'`

 cat entiy_linux_association.json | sed "s/\$ANALYTICS_COMPARTMENT/$ANALYTICS_COMPARTMENT/g" | \
 sed "s/\$ANALYTICS_NAMESPACE/$ANALYTICS_NAMESPACE/g" | \
 sed "s/\$AGENT_ID/$AGENT_ID/g" | \
 sed "s/\$ENTITY_ID/$ENTITY_ID/g" | \
 sed "s/\$LOG_GROUP_COMPRTMENT/$LOG_GROUP_COMPRTMENT/g" | \
 sed "s/\$LOG_GROUP_ID/$ANALYTICS_LOGID/g" | \
 sed "s/\$NAME_ENTITY/$NAME_ENTITY/g" | \
 sed "s/\$LOG_GROUP_NAME/$LOG_GROUP_NAME/g" | sed 's/_ID//g' > config/entity_linux_association-$NAME_ENTITY.json
done<linux_entities_id.txt

for files in config/entity_linux_association*
do
 oci log-analytics assoc upsert-assocs \
--profile DBSEC \
--from-json file://$files
done



### create the associations database
### same path here
### for every database entity we create 2 associations ( we coudld do this in one execution but i prefer to keep simple json files)
while IFS= read -r line;
do
 export AGENT_ID=`echo $line |  awk -F ' ' '{print $1}'`
 export ENTITY_ID=`echo $line |  awk -F ' ' '{print $2}'`
 export NAME_ENTITY=`echo $line |  awk -F ' ' '{print $3}'`
  export HOSTNAME=`echo $line |  awk -F ' ' '{print $4}'`
 cat dbcs_alert_log.json | sed "s/\$ANALYTICS_COMPARTMENT/$ANALYTICS_COMPARTMENT/g" | \
 sed "s/\$ANALYTICS_NAMESPACE/$ANALYTICS_NAMESPACE/g" | \
 sed "s/\$AGENT_ID/$AGENT_ID/g" | \
 sed "s/\$ENTITY_ID/$ENTITY_ID/g" | \
 sed "s/\$LOG_GROUP_COMPRTMENT/$LOG_GROUP_COMPRTMENT/g" | \
 sed "s/\$LOG_GROUP_ID/$ANALYTICS_LOGID/g" | \
 sed "s/\$HOSTNAME/$HOSTNAME/g" | \
  sed "s/\$NAME_ENTITY/$NAME_ENTITY/g" | \
 sed "s/\$LOG_GROUP_NAME/$LOG_GROUP_NAME/g"  > config/entity_database_alert_log-$NAME_ENTITY.json
done<database_entities_id.txt

for files in config/entity_database_alert_log*
do
 oci log-analytics assoc upsert-assocs \
--profile DBSEC \
--from-json file://$files
done

cd /home/oracle/terraform-excercises/oci-certification/logging-analytics/modules/compute_nodes_provisioning
while IFS= read -r line;
do
 export AGENT_ID=`echo $line |  awk -F ' ' '{print $1}'`
 export ENTITY_ID=`echo $line |  awk -F ' ' '{print $2}'`
 export NAME_ENTITY=`echo $line |  awk -F ' ' '{print $3}'`
  export HOSTNAME=`echo $line |  awk -F ' ' '{print $4}'`
 cat dbcs_auditLogsource_log.json | sed "s/\$ANALYTICS_COMPARTMENT/$ANALYTICS_COMPARTMENT/g" | \
 sed "s/\$ANALYTICS_NAMESPACE/$ANALYTICS_NAMESPACE/g" | \
 sed "s/\$AGENT_ID/$AGENT_ID/g" | \
 sed "s/\$ENTITY_ID/$ENTITY_ID/g" | \
 sed "s/\$LOG_GROUP_COMPRTMENT/$LOG_GROUP_COMPRTMENT/g" | \
 sed "s/\$LOG_GROUP_ID/$ANALYTICS_LOGID/g" | \
 sed "s/\$HOSTNAME/$HOSTNAME/g" | \
  sed "s/\$NAME_ENTITY/$NAME_ENTITY/g" | \
 sed "s/\$LOG_GROUP_NAME/$LOG_GROUP_NAME/g"  > config/entity_database_auditLogsource-$NAME_ENTITY.json
done<database_entities_id.txt

for files in config/entity_database_auditLogsource*
do
 oci log-analytics assoc upsert-assocs \
--profile DBSEC \
--from-json file://$files
done


##### at this point 
##### we shoud have per linux 6 logs / entity
##### per database            2 logs /entity


#### tear down everythging => delete associations / delete entities

#### create json to delete associations
oci log-analytics assoc list-entity-source-assocs \
--profile DBSEC \
--compartment-id $ANALYTICS_COMPARTMENT \
--namespace-name $ANALYTICS_NAMESPACE | \
jq  '.data' |sed '/null/d' | sed '/life-cycle-state/d' | sed '/time-last-attempted/d' | sed '/entity-name/d' | sed '/log-group-compartment/d' | \
sed '/log-group-name/d' | sed '/source-display-name/d' | \
sed 's/agent-id/agentId/g' | sed 's/entity-id/entityId/g' | sed 's/entity-type-name/entityTypeName/g' | \
sed 's/log-group-id/logGroupId/g' | sed 's/source-name/sourceName/g' | sed 's/source-type-name/sourceTypeName/g' | \
sed '/sourceTypeName/s/,//g' > del_assoc.json

oci log-analytics assoc delete-assocs \
--profile DBSEC \
--compartment-id $ANALYTICS_COMPARTMENT \
--namespace-name  "$ANALYTICS_NAMESPACE"  \
--from-json file://del_assoc.json

### no associations here ...
### get the entities
oci log-analytics entity list \
--profile DBSEC \
--compartment-id $ANALYTICS_COMPARTMENT \
--namespace-name  "$ANALYTICS_NAMESPACE" | jq '.data.items[] | .id' | sed 's/"//g' > list_entities_id.txt

### delete the entities
while IFS= read -r line;
do
oci log-analytics entity delete \
--profile DBSEC \
--namespace-name $ANALYTICS_NAMESPACE \
--entity-id $line \
--force
done < list_entities_id.txt

#### check if eveything is gone
### get the association after deletion
oci log-analytics assoc list-entity-source-assocs \
--profile DBSEC \
--compartment-id $ANALYTICS_COMPARTMENT \
--namespace-name $ANALYTICS_NAMESPACE | jq  '.data.items[] | "\(."agent-id"):\(."entity-id"):\(."entity-type-name"):\(."log-group-id"):\(."source-name"):\(."source-type-name")"' | sed 's/"//g' > assoc.txt
cat assoc.txt


oci log-analytics entity list \
--profile DBSEC \
--compartment-id $ANALYTICS_COMPARTMENT \
--namespace-name $ANALYTICS_NAMESPACE --all \
--lifecycle-state ACTIVE






