### https://blogs.oracle.com/managementcloud/how-to-ingest-oci-vcn-flow-logs-into-oci-logging-analytics
### steps for vnc log ingestion
###
 
resource "oci_logging_log_group" "vnc_log_group" {
    #Required
    compartment_id = var.logging.compartment_id #oci_identity_compartment.log_analytics_compartment.id
    display_name = var.logging.oci_logging_log_group_display_name ##  "logging-analytics-demo" ##var.log_group_display_name

    #Optional
#####  defined_tags =  var.logging.defined_tags ###{ "Oracle-Tags.ResourceAllocation" = "Logging-Analytics" }
  freeform_tags = var.logging.freeform_tags
  
##### --   {
##### --     "Project"     = "log_analytics"
##### --     "Role"        = "log_analytics for HOL "
##### --     "Comment"     = "log_analytics setup for HOL "
##### --     "Version"     = "0.0.0.0"
##### --     "Responsible" = "Eugene Simos"
##### --   }
}
 
resource oci_logging_log vcn_lbpubreg_all {
  configuration {
    compartment_id = var.logging.compartment_id #oci_identity_compartment.log_analytics_compartment.id
    source {
      category    = var.logging.oci_logging_log_category # "all"
      resource    = var.logging.oci_logging_log_resource #"ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaarq5bmkxsjr5arva26sd3kqokm2iv5axec2cytlrydskbnkwhkbaq"
      service     = var.logging.oci_logging_log_service #"flowlogs"
      source_type = var.logging.oci_logging_log_source_type # "OCISERVICE"
    }
  }
#####  defined_tags =  var.logging.defined_tags ###{ "Oracle-Tags.ResourceAllocation" = "Logging-Analytics" }
  display_name = var.logging.oci_logging_log_display_name ### "lbpubreg_all"
  freeform_tags = var.logging.freeform_tags
  
##### --   {
##### --     "Project"     = "log_analytics"
##### --     "Role"        = "log_analytics for HOL "
##### --     "Comment"     = "log_analytics setup for HOL "
##### --     "Version"     = "0.0.0.0"
##### --     "Responsible" = "Eugene Simos"
##### --   }
  is_enabled         = "true"
  log_group_id       = oci_logging_log_group.vnc_log_group.id
  log_type           = var.logging.oci_logging_log_log_type #"SERVICE"
  retention_duration = var.logging.oci_logging_log_retention_duration #"30"
}


