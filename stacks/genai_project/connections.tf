########################################
# Project Connections (all AAD / RBAC-based)
########################################

# Connection: Storage Account -> Project (conditional)
module "connection_storage" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_ai_connection"
  count  = var.enable_storage ? 1 : 0

  name             = "connection-storage"
  workspace_id     = module.ai_project.id
  category         = "AzureBlob"
  target           = module.storage_account[0].primary_blob_endpoint
  is_shared_to_all = false

  metadata = {
    AccountName   = module.storage_account[0].name
    ContainerName = "default"
  }

  depends_on = [module.ai_project]
}

# Connection: Data Lake Storage -> Project (conditional)
module "connection_storage_datalake" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_ai_connection"
  count  = var.enable_storage_datalake ? 1 : 0

  name             = "connection-storage-datalake"
  workspace_id     = module.ai_project.id
  category         = "AzureBlob"
  target           = module.storage_datalake[0].primary_blob_endpoint
  is_shared_to_all = false

  metadata = {
    AccountName   = module.storage_datalake[0].name
    ContainerName = "default"
  }

  depends_on = [module.ai_project]
}

# Connection: AI Search -> Project (conditional)
module "connection_ai_search" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_ai_connection"
  count  = var.enable_ai_search ? 1 : 0

  name             = "connection-ai-search"
  workspace_id     = module.ai_project.id
  category         = "CognitiveSearch"
  target           = module.ai_search[0].endpoint
  is_shared_to_all = false

  metadata = {
    ResourceId = module.ai_search[0].id
  }

  depends_on = [module.ai_project]
}

# Connection: SQL Database -> Project (conditional)
module "connection_sql" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_ai_connection"
  count  = var.enable_sql_database ? 1 : 0

  name             = "connection-sql"
  workspace_id     = module.ai_project.id
  category         = "AzureSqlDb"
  target           = "Server=tcp:${module.sql_database[0].server_fqdn},1433;Database=${local.resource_names.sql_database}"
  is_shared_to_all = false

  depends_on = [module.ai_project]
}

########################################
# RBAC: Project identity on connected resources
########################################

# Project -> Storage: Storage Blob Data Contributor (conditional)
resource "azurerm_role_assignment" "project_storage_blob" {
  count = var.enable_storage ? 1 : 0

  scope                = module.storage_account[0].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.ai_project.principal_id
}

# Project -> Data Lake Storage: Storage Blob Data Contributor (conditional)
resource "azurerm_role_assignment" "project_storage_datalake_blob" {
  count = var.enable_storage_datalake ? 1 : 0

  scope                = module.storage_datalake[0].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.ai_project.principal_id
}

# Project -> Key Vault: Key Vault Secrets User (conditional)
resource "azurerm_role_assignment" "project_keyvault_secrets" {
  count = var.enable_keyvault ? 1 : 0

  scope                = module.key_vault[0].id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.ai_project.principal_id
}

# Project -> AI Search: Search Index Data Contributor (conditional)
resource "azurerm_role_assignment" "project_ai_search" {
  count = var.enable_ai_search ? 1 : 0

  scope                = module.ai_search[0].id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = module.ai_project.principal_id
}

# Project -> AI Search: Search Service Contributor (conditional)
resource "azurerm_role_assignment" "project_ai_search_service" {
  count = var.enable_ai_search ? 1 : 0

  scope                = module.ai_search[0].id
  role_definition_name = "Search Service Contributor"
  principal_id         = module.ai_project.principal_id
}

# Project -> SQL Server: Contributor (conditional)
resource "azurerm_role_assignment" "project_sql" {
  count = var.enable_sql_database ? 1 : 0

  scope                = module.sql_database[0].server_id
  role_definition_name = "Contributor"
  principal_id         = module.ai_project.principal_id
}
