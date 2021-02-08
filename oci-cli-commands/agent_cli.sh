export AGENT_COMPARTMENT_OCID=ocid1.compartment.oc1..aaaaaaaado7k3yxvwtwwdfuhi4imtwkv2km5opjx6wspihqg3jr325in3rvq
oci management-agent agent list \
--profile DBSEC \
--compartment-id $AGENT_COMPARTMENT_OCID


oci management-agent plugin list \
--profile DBSEC \
--compartment-id $AGENT_COMPARTMENT_OCID


oci management-agent install-key list  \
--profile DBSEC \
--compartment-id $AGENT_COMPARTMENT_OCID



oci compute instance list \
--profile DBSEC \
--compartment-id ocid1.compartment.oc1..aaaaaaaaoctz26zocbcicfpxxmxbmmzyxa4kbweepqkeg6akuwqjuehw4bta |  jq -r '.data[] | .id' > compute_instances_ocids.txt

oci compute instance list-vnics \
--profile DBSEC \
--compartment-id ocid1.compartment.oc1..aaaaaaaaoctz26zocbcicfpxxmxbmmzyxa4kbweepqkeg6akuwqjuehw4bta \
--instance-id  $line 

rm -rf ansible_hosts.txt
input="compute_instances_ocids.txt"
while IFS= read -r line
do
echo "comp =>$name compute node ocid=>$line"
Public_ip=`oci compute instance list-vnics \
--profile DBSEC \
--compartment-id ocid1.compartment.oc1..aaaaaaaaoctz26zocbcicfpxxmxbmmzyxa4kbweepqkeg6akuwqjuehw4bta \
--instance-id  $line |  jq -r '.data[] |"\(."public-ip")" '`
printf "%s ansible_user=opc ansible_ssh_private_key_file=wls-wdt-testkey\n" $Public_ip >> ansible_hosts.txt
done < "$input" 

oci compute instance list-vnics \
--profile DBSEC \
--compartment-id ocid1.compartment.oc1..aaaaaaaaoctz26zocbcicfpxxmxbmmzyxa4kbweepqkeg6akuwqjuehw4bta \
--instance-id ocid1.instance.oc1.eu-frankfurt-1.antheljrufnzx7ickdgyitreeoiatijyo3sqvojjrs5vxl7cnoouyl2enr7a