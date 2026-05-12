########################################
# Project outputs
########################################

output "resource_group_name" {
  description = "Name of the project resource group."
  value       = azurerm_resource_group.this.name
}

output "resource_group_id" {
  description = "Resource ID of the project resource group."
  value       = azurerm_resource_group.this.id
}

output "project_id" {
  description = "Resource ID of the AI Project workspace."
  value       = module.ai_project.id
}

output "project_name" {
  description = "Name of the AI Project workspace."
  value       = module.ai_project.name
}

output "project_principal_id" {
  description = "Principal ID of the AI Project managed identity."
  value       = module.ai_project.principal_id
}

output "storage_account_id" {
  description = "Resource ID of the project storage account (null if disabled)."
  value       = var.enable_storage ? module.storage_account[0].id : null
}

output "key_vault_id" {
  description = "Resource ID of the project key vault (null if disabled)."
  value       = var.enable_keyvault ? module.key_vault[0].id : null
}

output "storage_datalake_id" {
  description = "Resource ID of the project Data Lake storage account (null if disabled)."
  value       = var.enable_storage_datalake ? module.storage_datalake[0].id : null
}

output "ai_search_id" {
  description = "Resource ID of the project AI Search service (null if disabled)."
  value       = var.enable_ai_search ? module.ai_search[0].id : null
}

output "sql_server_id" {
  description = "Resource ID of the project SQL server (null if disabled)."
  value       = var.enable_sql_database ? module.sql_database[0].server_id : null
}

output "sql_server_fqdn" {
  description = "FQDN of the project SQL server (null if disabled)."
  value       = var.enable_sql_database ? module.sql_database[0].server_fqdn : null
}
