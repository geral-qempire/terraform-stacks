########################################
# Hub outputs
########################################

output "resource_group_name" {
  description = "Name of the hub resource group."
  value       = azurerm_resource_group.this.name
}

output "resource_group_id" {
  description = "Resource ID of the hub resource group."
  value       = azurerm_resource_group.this.id
}

output "hub_id" {
  description = "Resource ID of the AI Hub workspace."
  value       = module.ai_hub.id
}

output "hub_name" {
  description = "Name of the AI Hub workspace."
  value       = module.ai_hub.name
}

output "hub_principal_id" {
  description = "Principal ID of the AI Hub managed identity."
  value       = module.ai_hub.principal_id
}

output "hub_workspace_id" {
  description = "Immutable workspace ID (GUID) of the AI Hub."
  value       = module.ai_hub.workspace_id
}

output "storage_account_id" {
  description = "Resource ID of the hub storage account."
  value       = module.storage_account.id
}

output "key_vault_id" {
  description = "Resource ID of the hub key vault."
  value       = module.key_vault.id
}

output "ai_services_id" {
  description = "Resource ID of the AI Services (Cognitive Services) account."
  value       = azurerm_cognitive_account.ai_services.id
}

output "ai_services_endpoint" {
  description = "Endpoint URL of the AI Services account."
  value       = azurerm_cognitive_account.ai_services.endpoint
}

output "storage_datalake_id" {
  description = "Resource ID of the hub Data Lake storage account (null if disabled)."
  value       = var.enable_storage_datalake ? module.storage_datalake[0].id : null
}

output "ai_search_id" {
  description = "Resource ID of the AI Search service (null if disabled)."
  value       = var.enable_ai_search ? module.ai_search[0].id : null
}

output "sql_server_id" {
  description = "Resource ID of the SQL server (null if disabled)."
  value       = var.enable_sql_database ? module.sql_database[0].server_id : null
}

output "sql_server_fqdn" {
  description = "FQDN of the SQL server (null if disabled)."
  value       = var.enable_sql_database ? module.sql_database[0].server_fqdn : null
}

output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.this.id
}

output "application_insights_id" {
  description = "Resource ID of the Application Insights instance."
  value       = azurerm_application_insights.this.id
}
