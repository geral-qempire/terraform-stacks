output "resource_group_name" {
  description = "Generated resource group name."
  value       = azurerm_resource_group.this.name
}

output "resource_group_id" {
  description = "Resource ID of the deployed resource group."
  value       = azurerm_resource_group.this.id
}

output "resource_group_location" {
  description = "Azure region where the resource group resides."
  value       = azurerm_resource_group.this.location
}

output "resource_group_subscription_id" {
  description = "Subscription ID hosting the resource group."
  value       = var.infra_subscription_id
}

output "resource_group_tags" {
  description = "Final tag set applied to the resource group."
  value       = azurerm_resource_group.this.tags
}

output "generated_name_seed" {
  description = "Base name returned by the az_name_generator module."
  value       = module.resource_group_name.name
}

output "rbac_write_assignment_ids" {
  description = "Role assignment IDs for the write profile."
  value       = try(module.rbac_write_profile[0].role_assignment_ids, {})
}

output "rbac_read_assignment_ids" {
  description = "Role assignment IDs for the read profile."
  value       = try(module.rbac_read_profile[0].role_assignment_ids, {})
}

output "rbac_alert_assignment_ids" {
  description = "Role assignment IDs for the alert profile."
  value       = try(module.rbac_alert_profile[0].role_assignment_ids, {})
}


