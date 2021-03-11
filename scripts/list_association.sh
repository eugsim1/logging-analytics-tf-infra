#!/bin/bash
export PATH=/home/oracle/terraform-excercises/terraform:/home/oracle/.nvm/versions/node/v15.5.1/bin:/home/oracle/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/usr/local/rvm/bin:/usr/local/go/bin:/home/oracle/gocode/bin:/home/oracle/.local/bin:/home/oracle/bin
/home/oracle/bin/oci log-analytics assoc list-entity-source-assocs \
--profile DBSEC \
--compartment-id ocid1.compartment.oc1..aaaaaaaaqhhyjrkidluilxlgk5xer7sox6x7ngcak7hfey3iuvcv45s5oz7a \
--namespace-name frnj6sfkc1ep | \
jq  '.data' |sed '/null/d' | sed '/life-cycle-state/d' | sed '/time-last-attempted/d' | sed '/entity-name/d' | sed '/log-group-compartment/d' | \
sed '/log-group-name/d' | sed '/source-display-name/d' | \
sed 's/agent-id/agentId/g' | sed 's/entity-id/entityId/g' | sed 's/entity-type-name/entityTypeName/g' | \
sed 's/log-group-id/logGroupId/g' | sed 's/source-name/sourceName/g' | sed 's/source-type-name/sourceTypeName/g' 1> clout_test_cron.json 2>err.txt

export ANALYTICS_COMPARTMENT=ocid1.compartment.oc1..aaaaaaaaqhhyjrkidluilxlgk5xer7sox6x7ngcak7hfey3iuvcv45s5oz7a
export ANALYTICS_LOGID=ocid1.loganalyticsloggroup.oc1.eu-frankfurt-1.amaaaaaaufnzx7iakfepgantk22dx4fay7fmhwsx6mmshrdthwwdkg5a7hua
export ANALYTICS_NAMESPACE=frnj6sfkc1ep
export LOG_GROUP_COMPRTMENT=ocid1.compartment.oc1..aaaaaaaaqhhyjrkidluilxlgk5xer7sox6x7ngcak7hfey3iuvcv45s5oz7a
export LOG_GROUP_COMPRTMENT_ID=ocid1.loganalyticsloggroup.oc1.eu-frankfurt-1.amaaaaaaufnzx7iakfepgantk22dx4fay7fmhwsx6mmshrdthwwdkg5a7hua
export LOG_GROUP_NAME=analytics001
oci log-analytics warning list \
--profile DBSEC \
--compartment-id $ANALYTICS_COMPARTMENT \
--namespace-name $ANALYTICS_NAMESPACE 1> warnings.json
