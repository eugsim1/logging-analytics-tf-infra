**USE ANSIBLE automation TO DEPLOY Logging Analytics Agents to any host**

This directory contains files/scripts used to provision Oci compute nodes - can be also other linux on premices nodes - with the OCI Logging Analytics Agent

For the purpose of the demo, an OCI compartment is configured with a terraform script to provide the Agent Configuration, and generate a local shell script.

The details of the dynamic generation of this script is given to this terraform repo :
  https://github.com/eugsim1/logging-analytics-tf-infra in the module agent.

This shell script is generated from the `resource "local_file" "AGENT_key"` section of the agent.tf script.

The script installs :
1- JDK 1.8 in the target host

2- Downloads the agent rpm

3-Installs the agent with a sudo oracle user

The same script has also the capability to clean remove an installed OCI Logging Analytics Agent

This script is provisioned by Ansible



To run these scripts  we need to install Ansible to a linux host, 

If you need to deploy your Agent to your OCI Compute Nodes/ Databases we probably need also to install the OCI CLI command and execute some scripts to collect your target Linux servers, and provide also the private keys as and extra argument to the ansible configuration file

For a demo purpose a simple OCI CLI example is provided called `provision_agent_servers.sh`

```
#### this script creates the ansible hosts files for the agent provisionings
#### collect IP from compute instances
#### get the ocids

cd  /home/oracle/terraform-excercises/oci-certification/logging-analytics/modules/compute_nodes_provisioning
oci compute instance list \
--profile DBSEC \
--compartment-id ocid1.compartment.oc1..aaaaaaaaoctz26zocbcicfpxxmxbmmzyxa4kbweepqkeg6akuwqjuehw4bta |  jq -r '.data[] | .id' > compute_instances_ocids.txt

### create a <ansible hosts file>
### from the vnics of a compartement

### we excpect tha the private key is called wls-wdt-testkey  and it will be on the same directory as the <ansible host file> otherwise the printf should be modified

rm -rf ansible_hosts.txt
echo "[servers]" > ansible_hosts.txt
input="compute_instances_ocids.txt"
while IFS= read -r line
do
echo "comp =>$name compute node ocid=>$line"
Public_ip=oci compute instance list-vnics \
--profile DBSEC \
--compartment-id ocid1.compartment.oc1..aaaaaaaaoctz26zocbcicfpxxmxbmmzyxa4kbweepqkeg6akuwqjuehw4bta \
--instance-id  $line |  jq -r '.data[] |"\(."public-ip")" '`
printf "%s ansible_user=opc ansible_ssh_private_key_file=wls-wdt-testkey\n" $Public_ip >> ansible_hosts.txt
done < "$input" 
```





The private keys are generated per session demo, as well as the servers, there is no possibility to try this scripts beyond the scope of a targeted demo.

the private keys, the public IP , and any other information here are generated and already deleted no chance to access any server to Oracle OCI layout

**Create Database entities and sources in the LogAnalytics tenancy**

The script [get_database_info_tologan.sh](https://github.com/eugsim1/logging-analytics-tf-infra/tree/master/modules/compute_nodes_provisioning) can be used to create the entities and associate the sources to Oracle Databases.
In this case the agent should be already deployed on the target servers.

It has 2 parts Creation of the entities and association with sources, and removal of the entities and the associations
You need to provide the IP of your databases, and the private key to be used to perform and introspection of the compute nodes.
You need to maintain jsnon files  which are related to the association between entities and Oracle predefined sources.

You need to update the sed section if you modify update some database back end files.

the script is configured to run on a tenancy/compartment/loggroup where the LogAnalytics is already setup

If not you can create the infra by using scripts from this repository



update the below exports to your settings

```
export ANALYTICS_COMPARTMENT=ocid1.compartment.oc1..aaaaaaaaqhhyjrkidluilxlgk5xer7sox6x7ngcak7hfey3iuvcv45s5oz7a
export ANALYTICS_LOGID=ocid1.loganalyticsloggroup.oc1.eu-frankfurt-1.amaaaaaaufnzx7iakfepgantk22dx4fay7fmhwsx6mmshrdthwwdkg5a7hua
export ANALYTICS_NAMESPACE=frnj6sfkc1ep
export LOG_GROUP_COMPRTMENT=ocid1.compartment.oc1..aaaaaaaaqhhyjrkidluilxlgk5xer7sox6x7ngcak7hfey3iuvcv45s5oz7a
export LOG_GROUP_COMPRTMENT_ID=ocid1.loganalyticsloggroup.oc1.eu-frankfurt-1.amaaaaaaufnzx7iakfepgantk22dx4fay7fmhwsx6mmshrdthwwdkg5a7hua
export LOG_GROUP_NAME=analytics001
cd /home/oracle/terraform-excercises/oci-certification/logging-analytics/modules/compute_nodes_provisioning
```

Run this section to create the templates for the entities and the associations

```
while IFS= read -r line;
do
 ssh -i console-zdm-ssh-key-2021-03-04.key oracle@$line  'bash -s' < ./database_config_for_analytics.sh
done<servers_ip.txt
```

The server_ip.txt is a simple text file with the ip of your targets :

```
130.XXX.XXX.XXX
130.XXX.XXX.XXX
```

The script database_config_for_analytics.sh create the database templates

```
#!/bin/bash
rm -rf database.txt
source /home/oracle/.bash_profile


cat <<EOT>report.sql
set headsep off
set term off
set feed off
set serveroutput off
set echo off
set pagesize 0
set trimspool on
set linesize 300
COLUMN name FORMAT A25
COLUMN value FORMAT A120
COLUMN   value_col_plus_show_param        FORMAT   a50  HEADING VALUE
spool database.txt
show parameter AUDIT_FILE_DEST;
show parameter DIAGNOSTIC_DEST;
select 'sid ' || sys_context('userenv','instance_name') from dual;
select 'service_name ' || name from v\$services;
SELECT name, value FROM v\$diag_info;
EOT

sqlplus / as sysdba<<EOF
@report.sql
EOF
sed 's/string//g' -i database.txt
sed '/Active Problem Count/d' -i database.txt
sed '/Active Incident Count/d' -i database.txt
sed '/Health Monitor/d' -i database.txt
sed '/Diag Enabled/d' -i database.txt
sed '/Default Trace File/d' -i database.txt
sed '/Diag Incident/d' -i database.txt
sed '/Diag Cdump/d' -i database.txt
sed '/Diag Trace/d' -i database.txt
sed '/Diag Alert/d' -i database.txt
sed '/SYS/d' -i database.txt
sed '/XDB/d' -i database.txt
sed '/pdb/d' -i database.txt
sed '/ADR Base/d' -i database.txt
sed 's/ADR Home/adr_home/g' -i database.txt

sed '$d' -i database.txt

export hostname_ip=`curl ifconfig.co`
export sid=`grep sid database.txt | sed 's/sid//g' | sed 's/ //g'`
export AUDIT_FILE_DEST=`grep audit_file_dest database.txt | sed 's/audit_file_dest//g' | sed 's/ //g'`
export DIAGNOSTIC_DEST=`grep diagnostic_dest database.txt | sed 's/diagnostic_dest//g' | sed 's/ //g'`
export adr_home=`grep adr_home database.txt | sed 's/adr_home//g' | sed 's/ //g'`
export ORACLE_HOME=`grep ORACLE_HOME database.txt | sed 's/ORACLE_HOME//g' | sed 's/ //g'`
export service_name=`grep service_name database.txt | sed 's/service_name//g' | sed 's/ //g'`


sudo su<<EOF
cat /opt/oracle/mgmt_agent/agent_inst/config/security/resource/agent.ocid | sed 's/agent=//g'> agent.txt
chown oracle:oinstall agent.txt
EOF

cat <<EOF>database_entity.json
{
	"agentId": "`cat agent.txt`",
	"compartmentId": "\$ANALYTICS_COMPARTMENT",
	"entityTypeName": "Oracle Database Instance",
	"namespace": "\$ANALYTICS_NAMESPACE",
EOF

cat <<-EOF>>database_entity.json
	"hostname": "$hostname_ip",
	"name": "dbcs_$hostname_ip",
EOF


cat <<-EOF>>database_entity.json
"properties": {
	"AUDIT_FILE_DEST": "$AUDIT_FILE_DEST",
	"DIAGNOSTIC_DEST": "$DIAGNOSTIC_DEST",
	"adr_home": "$adr_home",
	"audit_dest": "$DIAGNOSTIC_DEST/admin/$sid/adump",
	"host_name" : "$hostname_ip",
	"oracle_home": "$ORACLE_HOME",
	"port": "1521",
	"service_name": "$service_name",
	"sid": "$sid"
	}
}
EOF

cat database_entity.json

cat<<-EOF>linux_entity.json
{
  "agentId": "`cat agent.txt`",
  "compartmentId": "\$ANALYTICS_COMPARTMENT",
  "entityTypeName": "omc_host_linux",
  "freeformTags": {
    "Creator": "Eugene Simos",
    "Project": "analytics HOL"
  },
  "hostname": "$hostname_ip",
  "name": "linux_$hostname_ip",
  "namespace": "\$ANALYTICS_NAMESPACE",
  "timezoneRegion": "Europe/Helsinki"
}
EOF
```

```
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
```

Above is a generate script to get the templates from the target servers

the files that you will need are database*.json entity*.json

Run the following script to get the templates on your local server
As i m having a problem with scp i use the account root , but normally the script should run with a non root user

```
sudo su<<EOF
rm -rf config/*
source logan_targets.txt
chmod ugo+rw config/*
chown oracle:oracle config/*
EOF
```

Then create the entities and the associations :

```
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
```

One of the configuration files is having this template structure which can be modified , i using standard source definitions but you can add yours

```
{
  "compartmentId": "$ANALYTICS_COMPARTMENT",
  "isFromRepublish": true,
   "namespaceName": "$ANALYTICS_NAMESPACE",
  "items": [ 
    { 
	  "agentId": "$AGENT_ID",
      "entityId": "$ENTITY_ID",
      "entityName": "$NAME_ENTITY",
      "entityTypeName": "omc_oracle_db_instance",
      "host": "$HOSTNAME",
      "logGroupId": "$LOG_GROUP_ID",
      "sourceName": "DBAlertLogSource",
      "sourceTypeName": "os_file"
    },
    { 
	  "agentId": "$AGENT_ID",
      "entityId": "$ENTITY_ID",
      "entityName": "$NAME_ENTITY",
      "entityTypeName": "omc_oracle_db_instance",
      "host": "$HOSTNAME",
      "logGroupId": "$LOG_GROUP_ID",
      "sourceName": "DBAuditXMLLogSource",
      "sourceTypeName": "os_file"
    },
   { 
	  "agentId": "$AGENT_ID",
      "entityId": "$ENTITY_ID",
      "entityName": "$NAME_ENTITY",
      "entityTypeName": "omc_oracle_db_instance",
      "host": "$HOSTNAME",
      "logGroupId": "$LOG_GROUP_ID",
      "sourceName": "DBIncidentDumpSource",
      "sourceTypeName": "os_file"
    },
{ 
	  "agentId": "$AGENT_ID",
      "entityId": "$ENTITY_ID",
      "entityName": "$NAME_ENTITY",
      "entityTypeName": "omc_oracle_db_instance",
      "host": "$HOSTNAME",
      "logGroupId": "$LOG_GROUP_ID",
      "sourceName": "DBTraceLogSource",
      "sourceTypeName": "os_file"
    },
	   { 
	  "agentId": "$AGENT_ID",
      "entityId": "$ENTITY_ID",
      "entityName": "$NAME_ENTITY",
      "entityTypeName": "omc_oracle_db_instance",
      "host": "$HOSTNAME",
      "logGroupId": "$LOG_GROUP_ID",
      "sourceName": "DBAlertXMLLogSource",
      "sourceTypeName": "os_file"
    }		
	]
}
```

The entity association json

```
 {
   "compartmentId": "$ANALYTICS_COMPARTMENT",
  "isFromRepublish": true,
   "namespaceName": "$ANALYTICS_NAMESPACE",
    "items": [
      {   

        "agent-id": "$AGENT_ID",
        "entity-id": "$ENTITY_ID",
        "entity-name": "$NAME_ENTITY",  
        "entity-type-name": "omc_host_linux",                   
        "log-group-compartment": "$LOG_GROUP_COMPRTMENT",
        "log-group-id": "$LOG_GROUP_ID",
        "log-group-name": "$LOG_GROUP_NAME",        
        "source-display-name": "Ksplice Logs",
        "source-name": "KspliceLogSource",
        "source-type-name": "os_file"        
      },
      {
        
        "agent-id": "$AGENT_ID",
        "entity-id": "$ENTITY_ID",
        "entity-name": "$NAME_ENTITY",
    
        "entity-type-name": "omc_host_linux",       
        "log-group-compartment": "$LOG_GROUP_COMPRTMENT",
        "log-group-id": "$LOG_GROUP_ID",
        "log-group-name": "$LOG_GROUP_NAME",
        "source-display-name": "Linux Audit Logs",
        "source-name": "AuditLogSource",
        "source-type-name": "os_file"    
      },
      {
        
        "agent-id": "$AGENT_ID",
        "entity-id": "$ENTITY_ID",
        "entity-name": "$NAME_ENTITY",
        
        "entity-type-name": "omc_host_linux",       
       "log-group-compartment": "$LOG_GROUP_COMPRTMENT",
        "log-group-id": "$LOG_GROUP_ID",
        "log-group-name": "$LOG_GROUP_NAME",
        "source-display-name": "Linux Cron Logs",
        "source-name": "LinuxCronLogSource",
        "source-type-name": "os_file"
      },
      {
        
        "agent-id": "$AGENT_ID",
        "entity-id": "$ENTITY_ID",
        "entity-name": "$NAME_ENTITY",
        
        "entity-type-name": "omc_host_linux",
        "log-group-compartment": "$LOG_GROUP_COMPRTMENT",
        "log-group-id": "$LOG_GROUP_ID",
        "log-group-name": "$LOG_GROUP_NAME",
        "source-display-name": "Linux Secure Logs",
        "source-name": "LinuxSecureLogSource",
        "source-type-name": "os_file"
      },
      {
        "agent-id": "$AGENT_ID",
        "entity-id": "$ENTITY_ID",
        "entity-name": "$NAME_ENTITY",
        
        "entity-type-name": "omc_host_linux",
        "log-group-compartment": "$LOG_GROUP_COMPRTMENT",
        "log-group-id": "$LOG_GROUP_ID",
        "log-group-name": "$LOG_GROUP_NAME",
        "source-display-name": "Linux Syslog Logs",
        "source-name": "LinuxSyslogSource",
        "source-type-name": "os_file"
      },
      {
        "agent-id": "$AGENT_ID",
        "entity-id": "$ENTITY_ID",
        "entity-name": "$NAME_ENTITY",
     
        "entity-type-name": "omc_host_linux",
        "log-group-compartment": "$LOG_GROUP_COMPRTMENT",
        "log-group-id": "$LOG_GROUP_ID",
        "log-group-name": "$LOG_GROUP_NAME",
        "source-display-name": "Linux YUM Logs",
        "source-name": "LinuxYUMLogSource",
        "source-type-name": "os_file"
      }
    ]

  }
```

