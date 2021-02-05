export LOGGING_ANALYTICS_COMPARTEMT=LoggingAnalytics

oci iam compartment list \
--profile DBSEC \
--access-level  ANY \
--compartment-id "ocid1.compartment.oc1..aaaaaaaawgvgmednqnee4zbxv4o66kbt25cdzexcnpxib6llhvbyrbftpzaa" \
--lifecycle-state ACTIVE | jq -r ' .data[] | .name ' > compartemnts_name.txt


## if there no compartemnts_name.txt   dont go furhter
if [  -s compartemnts_name.txt ]
then 
  input="compartemnts_name.txt"
  while IFS= read -r line
  do
    ./clean_log_analytics_compartement.sh $line
  done < "$input"
fi

./clean_log_analytics_compartement.sh $LOGGING_ANALYTICS_COMPARTEMT

rm -rf  compartemnts_name.txt