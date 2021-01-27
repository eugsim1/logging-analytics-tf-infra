
output "test_logging_namespaces" {
  value = module.log_analytics.test_logging_namespaces
}

output "logging_management_agents" {
  value = module.log_analytics.logging_management_agents
}

output "logging_management_agent_install_keys" {
  value = module.log_analytics.logging_management_agent_install_keys
}

output "logging_management_agent_plugins" {
  value = module.log_analytics.logging_management_agent_plugins
}

output "logging_management_agent_images" {
  value = module.log_analytics.logging_management_agent_images
}

/*
output "logging_management_agent_available_histories"   {
value = module.log_analytics.logging_management_agent_available_histories
}
*/

output "logging_log_groups" {
  value = module.log_analytics.logging_log_groups
}