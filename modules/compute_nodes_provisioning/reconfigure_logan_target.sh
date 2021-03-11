#!/bin/bash
export DATE=$(date +%d-%m-%Y"-"%H:%M:%S)
sudo su <<EOF
systemctl stop mgmt_agent.service
zip -r /tmp/log-$DATE.zip /opt/oracle/mgmt_agent/agent_inst/zip/ /opt/oracle/mgmt_agent/agent_inst/state/  /opt/oracle/mgmt_agent/agent_inst/log/
more /opt/oracle/mgmt_agent/agent_inst/state/laStorage/warning_os_file.json | grep '.patternText' | jq '.warnings[].data.patternText  ' | sed 's/"//g' > agent_issues.txt
chmod -R go+rx /u01/app/oracle/diag/rdbms/orcl19/orcl19/trace/*.*
              /u01/app/oracle/diag/rdbms/orcl19/orcl19/trace/alert*.log
chmod -R go+rx /var/log/audit/*.*
while IFS= read -r line;
do
 #ls -la $line
 echo $basename $line
 echo ${file##*/}
 #chmod go+r $line
done<agent_issues.txt
rm -rf /opt/oracle/mgmt_agent/agent_inst/state/* /opt/oracle/mgmt_agent/agent_inst/log/*
mkdir -p /opt/oracle/mgmt_agent/agent_inst/state
mkdir -p /opt/oracle/mgmt_agent/agent_inst/log
chown -R mgmt_agent:mgmt_agent /opt/oracle/mgmt_agent/agent_inst
systemctl restart mgmt_agent.service
systemctl status mgmt_agent.service
EOF


###usermod -aG root mgmt_agent
### workarounf
