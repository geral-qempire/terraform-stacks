########################################
# RBAC Profiles - Reader & Contributor
########################################

locals {
  reader_principals      = toset(var.reader_group_ids)
  contributor_principals = toset(var.contributor_group_ids)
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

# AI Project: Azure AI Developer
resource "azurerm_role_assignment" "reader_ai_project" {
  for_each = local.reader_principals

  scope                = module.ai_project.id
  role_definition_name = "Azure AI Developer"
  principal_id         = each.value
  principal_type       = "Group"
}

# Storage Account: Storage Blob Data Reader (conditional)
resource "azurerm_role_assignment" "reader_storage_blob" {
  for_each = var.enable_storage ? local.reader_principals : []

  scope                = module.storage_account[0].id
  role_definition_name = "Storage Blob Data Reader"
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

# Key Vault: Key Vault Reader + Key Vault Secrets User (conditional)
resource "azurerm_role_assignment" "reader_keyvault" {
  for_each = var.enable_keyvault ? local.reader_principals : []

  scope                = module.key_vault[0].id
  role_definition_name = "Key Vault Reader"
  principal_id         = each.value
  principal_type       = "Group"
}

resource "azurerm_role_assignment" "reader_keyvault_secrets" {
  for_each = var.enable_keyvault ? local.reader_principals : []

  scope                = module.key_vault[0].id
  role_definition_name = "Key Vault Secrets User"
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

# AI Project: Azure AI Administrator
resource "azurerm_role_assignment" "contributor_ai_project" {
  for_each = local.contributor_principals

  scope                = module.ai_project.id
  role_definition_name = "Azure AI Administrator"
  principal_id         = each.value
  principal_type       = "Group"
}

# Storage Account: Storage Blob Data Contributor (conditional)
resource "azurerm_role_assignment" "contributor_storage_blob" {
  for_each = var.enable_storage ? local.contributor_principals : []

  scope                = module.storage_account[0].id
  role_definition_name = "Storage Blob Data Contributor"
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

# Key Vault: Key Vault Contributor + Key Vault Secrets Officer (conditional)
resource "azurerm_role_assignment" "contributor_keyvault" {
  for_each = var.enable_keyvault ? local.contributor_principals : []

  scope                = module.key_vault[0].id
  role_definition_name = "Key Vault Contributor"
  principal_id         = each.value
  principal_type       = "Group"
}

resource "azurerm_role_assignment" "contributor_keyvault_secrets" {
  for_each = var.enable_keyvault ? local.contributor_principals : []

  scope                = module.key_vault[0].id
  role_definition_name = "Key Vault Secrets Officer"
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
