#!/bin/bash
source /home/oracle/.bash_profile
export HOSTNAME=`hostname`
export DATE=$2

export NEWKEY="$1"
echo $NEWKEY > /tmp/authorized_keys
sed 's/*/ /g' -i /tmp/authorized_keys

sudo su<<EOF
mv /home/oracle/.ssh/authorized_keys /home/oracle/.ssh/authorized_keys-back-${DATE}
mv /home/opc/.ssh/authorized_keys /home/opc/.ssh/authorized_keys-back-${DATE}
cp /tmp/authorized_keys /home/oracle/.ssh/authorized_keys
cp /tmp/authorized_keys /home/opc/.ssh/authorized_keys
chmod go-rw /home/oracle/.ssh/authorized_keys
chmod go-rw /home/opc/.ssh/authorized_keys
chown -R oracle:oinstall /home/oracle
chown -R opc:opc /home/opc
EOF