data "oci_identity_identity_providers" "test_identity_providers" {
  #Required
  compartment_id = var.oci_provider.tenancy_id
  protocol       = "SAML2" ##"var.identity_provider_protocol

  /*    
	#Optional
    name = var.identity_provider_name
    state = var.identity_provider_state
*/
}


####### --oci iam identity-provider get \
####### ----profile DBSEC \
####### ----identity-provider-id  "ocid1.saml2idp.oc1..aaaaaaaatvv5gdrnj2j7fflrg2nicbpexx4iklwx2dgnzjghjn4bq2qsbeoa"
####### --{
####### --  "data": {
####### --    "compartment-id": "ocid1.tenancy.oc1..aaaaaaaanpuxsacx2rn22ycwc7ugp3sqzfvfhvyrrkmd7eanmvqd6bg7innq",
####### --    "defined-tags": {},
####### --    "description": "Oracle identity cloud service added during account creation",
####### --    "freeform-attributes": {
####### --      "externalAppId": "ebab178d1db94403ad8589a44f4c400d",
####### --      "externalClientId": "ocid1tenancyoc1aaaaaaaanpuxsacx2rn22ycwc7ugp3sqzfvfhvyrrkmd7eanmvqd6bg7innq_APPID",
####### --      "externalClientSecret": "fb68d6f4-d388-4726-b030-5c906990297a",
####### --      "federationVersion": "2"
####### --    },
####### --    "freeform-tags": {},
####### --    "id": "ocid1.saml2idp.oc1..aaaaaaaatvv5gdrnj2j7fflrg2nicbpexx4iklwx2dgnzjghjn4bq2qsbeoa",
####### --    "inactive-status": null,
####### --    "lifecycle-state": "ACTIVE",
####### --    "metadata-url": "https://idcs-7c63b819b4fe4ebba512ad483dd06f9a.identity.oraclecloud.com",
####### --    "name": "OracleIdentityCloudService",
####### --    "product-type": "IDCS",
####### --    "protocol": "SAML2",
####### --    "redirect-url": "https://idcs-7c63b819b4fe4ebba512ad483dd06f9a.identity.oraclecloud.com/fed/v1/idp/sso",
####### --    "signing-certificate": null,
####### --    "time-created": "2020-05-10T20:13:42.107000+00:00"
####### --  },
####### --
####### --



data "oci_log_analytics_namespaces" "test_logging_namespaces" {
  compartment_id = var.oci_provider.tenancy_id
}


data "oci_management_agent_management_agents" "logging_management_agents" {
  #Required
  compartment_id = var.oci_provider.compartment_ocid
}



data "oci_management_agent_management_agent_install_keys" "logging_management_agent_install_keys" {
  #Required
  compartment_id = var.oci_provider.compartment_ocid
}


data "oci_management_agent_management_agent_plugins" "logging_management_agent_plugins" {
  #Required
  compartment_id = var.oci_provider.compartment_ocid
}


data "oci_management_agent_management_agent_images" "logging_management_agent_images" {
  #Required
  compartment_id = var.oci_provider.compartment_ocid
}

data "oci_logging_log_groups" "logging_log_groups" {
  #Required
  compartment_id = var.oci_provider.compartment_ocid

  /*  #Optional
  display_name                 = "exampleLogGroup"
  is_compartment_id_in_subtree = "false"
*/
}


/*
data "oci_management_agent_management_agent_available_histories" "logging_management_agent_available_histories" {
  #Required
  management_agent_id = var.managed_agent_id

  #Optional
  time_availability_status_ended_greater_than      = "2020-01-15T01:01:01.000Z"
  time_availability_status_started_less_than       = "2020-09-28T01:01:01.000Z"
}
*/