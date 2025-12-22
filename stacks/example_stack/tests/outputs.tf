output "resource_group_name" {
  description = "Generated resource group name."
  value       = module.stacks_resource_group_stack.resource_group_name
}

output "resource_group_id" {
  description = "Resource ID of the deployed resource group."
  value       = module.stacks_resource_group_stack.resource_group_id
}

output "resource_group_location" {
  description = "Azure region where the resource group resides."
  value       = module.stacks_resource_group_stack.resource_group_location
}

output "resource_group_subscription_id" {
  description = "Subscription ID hosting the resource group."
  value       = module.stacks_resource_group_stack.resource_group_subscription_id
}

output "resource_group_tags" {
  description = "Final tag set applied to the resource group."
  value       = module.stacks_resource_group_stack.resource_group_tags
}

output "generated_name_seed" {
  description = "Base name returned by the az_name_generator module."
  value       = module.stacks_resource_group_stack.generated_name_seed
}

output "rbac_write_assignment_ids" {
  description = "Role assignment IDs for the write profile."
  value       = module.stacks_resource_group_stack.rbac_write_assignment_ids
}

output "rbac_read_assignment_ids" {
  description = "Role assignment IDs for the read profile."
  value       = module.stacks_resource_group_stack.rbac_read_assignment_ids
}

output "rbac_alert_assignment_ids" {
  description = "Role assignment IDs for the alert profile."
  value       = module.stacks_resource_group_stack.rbac_alert_assignment_ids
}
