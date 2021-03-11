#!/bin/bash
export PATH=/home/oracle/terraform-excercises/terraform:/home/oracle/.nvm/versions/node/v15.5.1/bin:/home/oracle/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/usr/local/rvm/bin:/usr/local/go/bin:/home/oracle/gocode/bin:/home/oracle/.local/bin:/home/oracle/bin
export NAMESPACE=frnj6sfkc1ep

oci log-analytics upload list-upload-files  \
--profile DBSEC \
--namespace-name $NAMESPACE \
--upload-reference "-4128418186429303198" \
--status SUCCESSFUL \
--all | jq '.data.items[] | .reference' | sed 's/"//g' > files_uploaded_now
wc -l  files_uploaded_now > files_logan_now.txt
