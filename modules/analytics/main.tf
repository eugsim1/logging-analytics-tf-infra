##https://docs.oracle.com/en-us/iaas/logging-analytics/doc/perform-generic-prerequisite-configuration-tasks.html#GUID-378A927B-4559-4863-AF21-BDB7C4278516

variable "log_analytics_groups" {
  type = list(string)
  default = [
    "Logging-Analytics-Users",
    "Logging-Analytics-Admins",
    "Logging-Analytics-SuperAdmins",
  ]
}

locals {
  begin_dyn_rule = "All {resource.type = 'managementagent', resource.compartment.id = '"
  end_dyn_rule   = "'}"
}


resource "oci_identity_group" "log_identity_group" {
  count          = length(var.log_analytics_groups)
  name           = element(var.log_analytics_groups, count.index)
  description    = "log analytics group"
  compartment_id = var.oci_provider.tenancy_id

  #Optional
  defined_tags = { "Oracle-Tags.ResourceAllocation" = "Logging-Analytics" }
  freeform_tags = {
    "Project"     = "log_analytics"
    "Role"        = "log_analytics for HOL "
    "Comment"     = "log_analytics setup for HOL "
    "Version"     = "0.0.0.0"
    "Responsible" = "Eugene Simos"
  }
  lifecycle {
    ignore_changes = [
      defined_tags,
      freeform_tags,
    ]
  }

}

resource "oci_identity_policy" "log_analytics_policy" {
  depends_on     = [oci_identity_group.log_identity_group]
  name           = "log_analytics_policy"
  description    = "log_analytics_policy"
  compartment_id = var.oci_provider.tenancy_id
  #Optional
  defined_tags = { "Oracle-Tags.ResourceAllocation" = "Logging-Analytics" }
  freeform_tags = {
    "Project"     = "log_analytics"
    "Role"        = "log_analytics for HOL "
    "Comment"     = "log_analytics setup for HOL "
    "Version"     = "0.0.0.0"
    "Responsible" = "Eugene Simos"
  }
  lifecycle {
    ignore_changes = [
      defined_tags,
      freeform_tags,
    ]
  }

  statements = [
    "allow group Logging-Analytics-SuperAdmins to MANAGE loganalytics-features-family in tenancy",
    "allow group Logging-Analytics-SuperAdmins to MANAGE loganalytics-resources-familY in tenancy",
    "allow group Logging-Analytics-SuperAdmins to MANAGE management-dashboard-family in tenancy",
    "allow service loganalytics to READ loganalytics-features-family in tenancy",
    "allow group Logging-Analytics-SuperAdmins to READ compartments in tenancy",
    "allow group Logging-Analytics-SuperAdmins to READ metrics IN tenancy",
    "allow group Logging-Analytics-SuperAdmins TO MANAGE management-agents IN tenancy",
    "allow group Logging-Analytics-SuperAdmins to MANAGE management-agent-install-keys IN tenancy",
    "allow group Logging-Analytics-SuperAdmins to READ users IN tenancy",
    "allow dynamic-group ManagementAgentAdmins to MANAGE management-agents IN tenancy",
    "allow dynamic-group ManagementAgentAdmins to USE METRICS IN tenancy",
    "allow dynamic-group ManagementAgentAdmins to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in tenancy",
    "allow dynamic-group ManagementAgentAdmins to USE loganalytics-collection-warning in tenancy",
    "allow group Logging-Analytics-Admins to use loganalytics-features-family in tenancy",
    "allow group Logging-Analytics-Admins to use loganalytics-resources-family in tenancy",
    "allow group Logging-Analytics-Admins to manage management-dashboard-family in tenancy",
    "allow group Logging-Analytics-Users to read loganalytics-features-family in tenancy",
    "allow group Logging-Analytics-Users to read loganalytics-resources-family in tenancy",
    "allow group Logging-Analytics-Users to use management-dashboard-family in tenancy",
    "allow group Logging-Analytics-SuperAdmins to use cloud-shell in tenancy",
    "allow group Logging-Analytics-Admins to use cloud-shell in tenancy",
    "allow group Logging-Analytics-Users to use cloud-shell in tenancy",
    "allow group Logging-Analytics-SuperAdmins  to use tag-namespaces in tenancy",
    "allow group Logging-Analytics-Admins to use tag-namespaces in tenancy",
    "allow group Logging-Analytics-Users to use tag-namespaces in tenancy",
    "Allow group Logging-Analytics-SuperAdmins to inspect users in tenancy",
    "allow group Logging-Analytics-Admins to inspect users in tenancy",
    "allow group Logging-Analytics-Users to inspect users in tenancy",
    "Allow group Logging-Analytics-SuperAdmins to inspect groups in tenancy",
    "allow group Logging-Analytics-Admins  to inspect groups in tenancy",
    "allow group Logging-Analytics-Users to inspect groups in tenancy",
    "allow service loganalytics to read buckets in tenancy",
    "allow service loganalytics to read objects in tenancy",
    "allow service loganalytics to manage cloudevents-rules in tenancy",
    "allow service loganalytics to inspect compartments in tenancy",
    "allow service loganalytics to use tag-namespaces in tenancy"


  ]
}



resource "oci_identity_idp_group_mapping" "logginc_idp_group_mapping" {
  depends_on = [oci_identity_group.log_identity_group]
  #Required
  group_id             = oci_identity_group.log_identity_group[2].id
  identity_provider_id = "ocid1.saml2idp.oc1..aaaaaaaatvv5gdrnj2j7fflrg2nicbpexx4iklwx2dgnzjghjn4bq2qsbeoa" ##oci_identity_identity_provider.test_identity_provider.id
  idp_group_name       = "OCI_Administrators"                                                               ###var.idp_group_mapping_idp_group_name
}




resource "oci_identity_compartment" "log_analytics_compartment" {
  #Required
  compartment_id = "ocid1.compartment.oc1..aaaaaaaakjdnf7ik2kejcaj73uwx6tsochnlq5olj3vebgbwcf67bjnab3ya"
  description    = "Main Anamytics compartment"
  name           = "LoggingAnalytics" #var.compartment_name

  #Optional
  defined_tags = { "Oracle-Tags.ResourceAllocation" = "Logging-Analytics" }
  freeform_tags = {
    "Project"     = "log_analytics"
    "Role"        = "log_analytics for HOL "
    "Comment"     = "log_analytics setup for HOL "
    "Version"     = "0.0.0.0"
    "Responsible" = "Eugene Simos"
  }
  lifecycle {
    ignore_changes = [
      defined_tags,
      freeform_tags,
    ]
  }
}

resource "oci_identity_compartment" "user_analytics_compartment" {
  #Required
  count          = 10
  compartment_id = oci_identity_compartment.log_analytics_compartment.id
  description    = "User Analytics compartment"
  name           = format("analytics%03s", count.index) #var.compartment_name

  #Optional
  defined_tags = { "Oracle-Tags.ResourceAllocation" = "Logging-Analytics" }
  freeform_tags = {
    "Project"     = "log_analytics"
    "Role"        = "log_analytics for HOL "
    "Comment"     = "log_analytics setup for HOL "
    "Version"     = "0.0.0.0"
    "Responsible" = "Eugene Simos"
  }
  lifecycle {
    ignore_changes = [
      defined_tags,
      freeform_tags,
    ]
  }
}

resource "oci_identity_policy" "loggingAnalytics_policy" {
  depends_on     = [oci_identity_compartment.log_analytics_compartment]
  name           = "LoggingAnalytics"
  description    = "LoggingAnalytics  policy"
  compartment_id = oci_identity_compartment.log_analytics_compartment.id
  #Optional
  defined_tags = { "Oracle-Tags.ResourceAllocation" = "Logging-Analytics" }
  freeform_tags = {
    "Project"     = "log_analytics"
    "Role"        = "log_analytics for HOL "
    "Comment"     = "log_analytics setup for HOL "
    "Version"     = "0.0.0.0"
    "Responsible" = "Eugene Simos"
  }
  lifecycle {
    ignore_changes = [
      defined_tags,
      freeform_tags,
    ]
  }

  statements = [
    "allow group Logging-Analytics-SuperAdmins to manage all-resources IN compartment LoggingAnalytics",
    "allow group Logging-Analytics-Admins  to manage all-resources IN compartment LoggingAnalytics",
    "allow group Logging-Analytics-Users to manage all-resources IN compartment LoggingAnalytics",
    "allow group Logging-Analytics-SuperAdmins to MANAGE management-dashboard-family in compartment LoggingAnalytics",
    "allow group Logging-Analytics-Admins to MANAGE management-dashboard-family in compartment LoggingAnalytics",
    "allow group Logging-Analytics-Users to MANAGE management-dashboard-family in compartment LoggingAnalytics",
    "allow group Logging-Analytics-SuperAdmins to MANAGE loganalytics-resources-family in compartment LoggingAnalytics",
    "allow group Logging-Analytics-Admins to MANAGE loganalytics-resources-family in compartment LoggingAnalytics",
    "allow group Logging-Analytics-Users to MANAGE loganalytics-resources-family in compartment LoggingAnalytics",
  ]
}





resource "oci_identity_user" "analytics_user" {
  #Required
  count          = 10
  compartment_id = var.oci_provider.tenancy_id
  description    = "HOL analytics user" ##var.user_description
  name           = format("analytics%03s", count.index)

  #Optional
  ##defined_tags = {"Operations.CostCenter"= "42"}
  email = format("analytics%03s@no.com", count.index)
  ##freeform_tags = {"Department"= "Finance"}
}


resource "oci_identity_user_group_membership" "Logging-Analytics-Users_group_membership" {
  #Required
  count    = 10
  group_id = oci_identity_group.log_identity_group[0].id
  user_id  = oci_identity_user.analytics_user[count.index].id
}

resource "oci_identity_user_group_membership" "Logging-Analytics-Admins_group_membership" {
  #Required
  count    = 10
  group_id = oci_identity_group.log_identity_group[1].id
  user_id  = oci_identity_user.analytics_user[count.index].id
}

resource "oci_identity_user_group_membership" "Logging-Analytics-SuperAdminsgroup_membership" {
  #Required
  count    = 10
  group_id = oci_identity_group.log_identity_group[2].id
  user_id  = oci_identity_user.analytics_user[count.index].id
}

resource "oci_identity_ui_password" "analytics_user_ui_password" {
  #Required
  count   = 10
  user_id = oci_identity_user.analytics_user[count.index].id
}


resource "local_file" "ssh_priv_key" {
  depends_on = [oci_identity_ui_password.analytics_user_ui_password]
  #Required
  count           = 10 #var.dbcs.is_dbcs_public == "true" ? var.dbcs.instance_count : 0
  content         = <<EOT
  ${format("analytics%03s", count.index)}
  ${oci_identity_ui_password.analytics_user_ui_password[count.index].password}  
  EOT
  file_permission = "0700"
  ##filename        = "config/${element(flatten(list(data.oci_core_vnic.test_vnic.*.public_ip_address)), count.index)}/priv.txt"
  filename = "config/${format("analytics_user%03s", count.index)}"
}




/*
data "oci_objectstorage_namespace" "loganalytics_namespace" {
    compartment_id = var.oci_provider.tenancy_id
}

resource "oci_log_analytics_namespace" "loganalytics_namespace" {
    #Required
    compartment_id = var.oci_provider.tenancy_id
    is_onboarded = "true"
    namespace = data.oci_objectstorage_namespace.loganalytics_namespace.namespace
} 
*/

/*

resource "oci_logging_log_group" "log_analytics_log_group" {
    #Required
    compartment_id = var.oci_provider.compartment_ocid
    display_name = "log_analytics_log_group" #var.log_group_display_name

    #Optional
 
    description = "log_analytics_log_group" #var.log_group_description
 
    #Optional
    defined_tags =  { "Oracle-Tags.ResourceAllocation" = "Logging-Analytics" }
        freeform_tags = {
      "Project"     = "log_analytics"
      "Role"        = "log_analytics for HOL "
      "Comment"     = "log_analytics setup for HOL "
      "Version"     = "0.0.0.0"
      "Responsible" = "Eugene Simos"
    } 
  lifecycle {
    ignore_changes = [
	  defined_tags,      
      freeform_tags,
    ]
  }	
}
*/