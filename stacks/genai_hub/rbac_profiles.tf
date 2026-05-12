########################################
# RBAC Profiles - Reader & Contributor
########################################

locals {
  reader_principals      = toset(var.reader_group_ids)
  contributor_principals = toset(var.contributor_group_ids)

  # Optional resource IDs (empty list when disabled)
  datalake_ids   = var.enable_storage_datalake ? [module.storage_datalake[0].id] : []
  ai_search_ids  = var.enable_ai_search ? [module.ai_search[0].id] : []
  sql_server_ids = var.enable_sql_database ? [module.sql_database[0].server_id] : []
}

########################################
# Reader Profile
########################################

# Resource Group: Reader
resource "azurerm_role_assignment" "reader_rg" {
  for_each = local.reader_principals

  scope                = azurerm_resource_group.this.id
  role_definition_name = "Reader"
  principal_id         = each.value
  principal_type       = "Group"
}

# AI Foundry Hub: Azure AI Developer (read models, run experiments, view endpoints)
resource "azurerm_role_assignment" "reader_ai_hub" {
  for_each = local.reader_principals

  scope                = module.ai_hub.id
  role_definition_name = "Azure AI Developer"
  principal_id         = each.value
  principal_type       = "Group"
}

# Storage Account: Storage Blob Data Reader
resource "azurerm_role_assignment" "reader_storage_blob" {
  for_each = local.reader_principals

  scope                = module.storage_account.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = each.value
  principal_type       = "Group"
}

# Key Vault: Key Vault Reader + Key Vault Secrets User
resource "azurerm_role_assignment" "reader_keyvault" {
  for_each = local.reader_principals

  scope                = module.key_vault.id
  role_definition_name = "Key Vault Reader"
  principal_id         = each.value
  principal_type       = "Group"
}

resource "azurerm_role_assignment" "reader_keyvault_secrets" {
  for_each = local.reader_principals

  scope                = module.key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = each.value
  principal_type       = "Group"
}

# AI Services: Cognitive Services User (invoke models, read deployments)
resource "azurerm_role_assignment" "reader_ai_services" {
  for_each = local.reader_principals

  scope                = azurerm_cognitive_account.ai_services.id
  role_definition_name = "Cognitive Services User"
  principal_id         = each.value
  principal_type       = "Group"
}

# Data Lake Storage: Storage Blob Data Reader (conditional)
resource "azurerm_role_assignment" "reader_datalake_blob" {
  for_each = var.enable_storage_datalake ? local.reader_principals : []

  scope                = module.storage_datalake[0].id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = each.value
  principal_type       = "Group"
}

# AI Search: Search Index Data Reader (conditional)
resource "azurerm_role_assignment" "reader_ai_search" {
  for_each = var.enable_ai_search ? local.reader_principals : []

  scope                = module.ai_search[0].id
  role_definition_name = "Search Index Data Reader"
  principal_id         = each.value
  principal_type       = "Group"
}

# SQL Server: Reader (conditional)
resource "azurerm_role_assignment" "reader_sql" {
  for_each = var.enable_sql_database ? local.reader_principals : []

  scope                = module.sql_database[0].server_id
  role_definition_name = "Reader"
  principal_id         = each.value
  principal_type       = "Group"
}

########################################
# Contributor Profile
########################################

# Resource Group: Contributor
resource "azurerm_role_assignment" "contributor_rg" {
  for_each = local.contributor_principals

  scope                = azurerm_resource_group.this.id
  role_definition_name = "Contributor"
  principal_id         = each.value
  principal_type       = "Group"
}

# AI Foundry Hub: Azure AI Administrator (full workspace management)
resource "azurerm_role_assignment" "contributor_ai_hub" {
  for_each = local.contributor_principals

  scope                = module.ai_hub.id
  role_definition_name = "Azure AI Administrator"
  principal_id         = each.value
  principal_type       = "Group"
}

# Storage Account: Storage Blob Data Contributor
resource "azurerm_role_assignment" "contributor_storage_blob" {
  for_each = local.contributor_principals

  scope                = module.storage_account.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = each.value
  principal_type       = "Group"
}

# Key Vault: Key Vault Contributor + Key Vault Secrets Officer
resource "azurerm_role_assignment" "contributor_keyvault" {
  for_each = local.contributor_principals

  scope                = module.key_vault.id
  role_definition_name = "Key Vault Contributor"
  principal_id         = each.value
  principal_type       = "Group"
}

resource "azurerm_role_assignment" "contributor_keyvault_secrets" {
  for_each = local.contributor_principals

  scope                = module.key_vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = each.value
  principal_type       = "Group"
}

# AI Services: Cognitive Services Contributor (manage deployments, models, keys)
resource "azurerm_role_assignment" "contributor_ai_services" {
  for_each = local.contributor_principals

  scope                = azurerm_cognitive_account.ai_services.id
  role_definition_name = "Cognitive Services Contributor"
  principal_id         = each.value
  principal_type       = "Group"
}

# Data Lake Storage: Storage Blob Data Contributor (conditional)
resource "azurerm_role_assignment" "contributor_datalake_blob" {
  for_each = var.enable_storage_datalake ? local.contributor_principals : []

  scope                = module.storage_datalake[0].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = each.value
  principal_type       = "Group"
}

# AI Search: Search Index Data Contributor + Search Service Contributor (conditional)
resource "azurerm_role_assignment" "contributor_ai_search_data" {
  for_each = var.enable_ai_search ? local.contributor_principals : []

  scope                = module.ai_search[0].id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = each.value
  principal_type       = "Group"
}

resource "azurerm_role_assignment" "contributor_ai_search_service" {
  for_each = var.enable_ai_search ? local.contributor_principals : []

  scope                = module.ai_search[0].id
  role_definition_name = "Search Service Contributor"
  principal_id         = each.value
  principal_type       = "Group"
}

# SQL Server: SQL DB Contributor (conditional)
resource "azurerm_role_assignment" "contributor_sql" {
  for_each = var.enable_sql_database ? local.contributor_principals : []

  scope                = module.sql_database[0].server_id
  role_definition_name = "SQL DB Contributor"
  principal_id         = each.value
  principal_type       = "Group"
}
