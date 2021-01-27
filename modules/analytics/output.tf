
output "test_logging_namespaces" {
  value = data.oci_log_analytics_namespaces.test_logging_namespaces
}

output "logging_management_agents" {
  value = data.oci_management_agent_management_agents.logging_management_agents
}

output "logging_management_agent_install_keys" {
  value = data.oci_management_agent_management_agent_install_keys.logging_management_agent_install_keys
}

output "logging_management_agent_plugins" {
  value = data.oci_management_agent_management_agent_plugins.logging_management_agent_plugins
}

output "logging_management_agent_images" {
  value = data.oci_management_agent_management_agent_images.logging_management_agent_images
}

/*
output "logging_management_agent_available_histories"   {
value = data.oci_management_agent_management_agent_available_histories.logging_management_agent_available_histories
}
*/

output "logging_log_groups" {
  value = data.oci_logging_log_groups.logging_log_groups
}


output "log_analytics_compartment_id" {
  value = oci_identity_compartment.log_analytics_compartment.id
}