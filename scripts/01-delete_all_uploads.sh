#####
##### This script delete all uploads from a tenancy
#####
#####
export NAMESPACE=frnj6sfkc1ep
DATE=$(date +%d-%m-%Y"-"%H:%M:%S)
echo "$DATE:Start of the clean up process" >> cleanup.txt


oci log-analytics upload list \
--profile DBSEC \
--namespace-name $NAMESPACE | jq -r .data.items[].reference > upload_list.txt


	
if [[ ! -f  "upload_list.txt" ]]
then
	 echo "No upload list for the $COMPARTMENT_NAME"
else
	DATE=$(date +%d-%m-%Y"-"%H:%M:%S)
	echo "$DATE:Upload_ref=>upload_list.txt" >> cleanup.txt
	while IFS= read -r line; do
	
    oci log-analytics upload list-upload-files \
	--profile DBSEC \
	--namespace-name $NAMESPACE \
	--upload-reference $line \
	--all  | jq '.data.items[] | "\(.reference):\(.status) "' | sed 's/"//g' > files_uploaded_now
    echo `wc -l files_uploaded_now | sed s/files_uploaded_now//g` will be deleted
	
	oci log-analytics upload delete \
	--profile DBSEC \
	--namespace-name $NAMESPACE \
	--upload-reference $line \
	--force
	done < upload_list.txt
fi

export NAMESPACE=frnj6sfkc1ep
oci log-analytics upload list-upload-files  \
--profile DBSEC \
--namespace-name $NAMESPACE \
--upload-reference "-4128418186429303198" \
--status SUCCESSFUL \
--all | jq '.data.items[] | .reference' | sed 's/"//g' > files_uploaded 
wc -l files_uploaded 

while IFS= read -r line;
do
oci log-analytics upload delete-upload-file \
--profile DBSEC \
--upload-reference "-4128418186429303198" \
--file-reference $line \
--namespace-name $NAMESPACE \
--force
done<files_uploaded


export NAMESPACE=frnj6sfkc1ep
oci log-analytics upload list-upload-files  \
--profile DBSEC \
--namespace-name $NAMESPACE \
--upload-reference "-4128418186429303198" \
--all | jq '.data.items[] | "\(.reference):\(.status) "' | sed 's/"//g' > files_uploaded_now
wc -l files_uploaded_now
