#!/bin/bash
source /home/oracle/.bash_profile
export HOSTNAME=`hostname`


rm -rf /tmp/*.zip
sudo su<<EOF
cat /opt/oracle/mgmt_agent/agent_inst/config/security/resource/agent.ocid | sed 's/agent=//g'> /tmp/agent.txt
chown oracle:oinstall /tmp/agent.txt
EOF

zip -r /tmp/trace.zip /u01/app/oracle/diag/rdbms/orcl19/orcl19/trace/*.trc >> /dev/null
zip -r /tmp/alert_log.zip         /u01/app/oracle/diag/rdbms/orcl19/orcl19/trace/alert*.log >> /dev/null
zip -r /tmp/incident.zip          /u01/app/oracle/diag/rdbms/orcl19/orcl19/incident >> /dev/null
zip -r /tmp/TNSAlertLogSource.zip        /u01/app/oracle/diag/tnslsnr/$HOSTNAME/listener/alert/log.xml >> /dev/null
zip -r /tmp/DBAlertXMLLogSource.zip  /u01/app/oracle/diag/rdbms/orcl19/orcl19/alert/log*.xml >> /dev/null
zip -r /tmp/all.zip /tmp/trace.zip /tmp/agent.txt /tmp/alert_log.zip /tmp/incident.zip /tmp/TNSAlertLogSource.zip /tmp/DBAlertXMLLogSource.zip  >> /dev/null



