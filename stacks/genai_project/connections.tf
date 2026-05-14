########################################
# Project Connections
########################################

# Connection: AI Services -> Project (RBAC, conditional)
module "connection_ai_services" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_ai_connection"
  count  = var.enable_ai_services ? 1 : 0

  name             = "${var.project_name}-ai-services"
  workspace_id     = module.ai_project.id
  category         = "CognitiveService"
  is_shared_to_all = false
  locks            = [module.ai_project.id]
  target           = azurerm_cognitive_account.ai_services[0].endpoint

  metadata = {
    Kind       = "AIServices"
    ResourceId = azurerm_cognitive_account.ai_services[0].id
  }

  depends_on = [module.ai_project]
}

# Connection: Azure OpenAI -> Project (API key, conditional)
module "connection_aoai" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_ai_connection"
  count  = var.enable_ai_services ? 1 : 0

  name             = "${module.naming.resource_names.ai_services}_aoai"
  workspace_id     = module.ai_project.id
  category         = "AzureOpenAI"
  auth_type        = "ApiKey"
  credentials_key  = azurerm_cognitive_account.ai_services[0].primary_access_key
  is_shared_to_all = false
  locks            = [module.ai_project.id]
  target           = azurerm_cognitive_account.ai_services[0].endpoint

  metadata = {
    ApiType    = "Azure"
    Kind       = "AIServices"
    ResourceId = azurerm_cognitive_account.ai_services[0].id
  }

  depends_on = [module.ai_project]
}

# Connection: Cognitive Services default -> Project (API key, conditional)
module "connection_cognitive_default" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_ai_connection"
  count  = var.enable_ai_services ? 1 : 0

  name             = module.naming.resource_names.ai_services
  workspace_id     = module.ai_project.id
  category         = "CognitiveService"
  auth_type        = "ApiKey"
  credentials_key  = azurerm_cognitive_account.ai_services[0].primary_access_key
  is_shared_to_all = false
  locks            = [module.ai_project.id]
  target           = azurerm_cognitive_account.ai_services[0].endpoint

  metadata = {
    ApiType    = "Azure"
    Kind       = "AIServices"
    ResourceId = azurerm_cognitive_account.ai_services[0].id
  }

  depends_on = [module.ai_project]
}

# Connection: Storage Account -> Project (conditional)
module "connection_storage" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_ai_connection"
  count  = var.enable_storage ? 1 : 0

  name             = "${var.project_name}-storage"
  workspace_id     = module.ai_project.id
  category         = "AzureBlob"
  target           = module.storage_account[0].primary_blob_endpoint
  is_shared_to_all = false
  locks            = [module.ai_project.id]

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

  name             = "${var.project_name}-storage-datalake"
  workspace_id     = module.ai_project.id
  category         = "AzureBlob"
  target           = module.storage_datalake[0].primary_blob_endpoint
  is_shared_to_all = false
  locks            = [module.ai_project.id]

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

  name             = "${var.project_name}-ai-search"
  workspace_id     = module.ai_project.id
  category         = "CognitiveSearch"
  target           = module.ai_search[0].endpoint
  is_shared_to_all = false
  locks            = [module.ai_project.id]

  metadata = {
    ResourceId = module.ai_search[0].id
  }

  depends_on = [module.ai_project]
}

# Connection: SQL Database -> Project (conditional)
module "connection_sql" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_ai_connection"
  count  = var.enable_sql_database ? 1 : 0

  name             = "${var.project_name}-sql"
  workspace_id     = module.ai_project.id
  category         = "AzureSqlDb"
  target           = "Server=tcp:${module.sql_database[0].server_fqdn},1433;Database=${module.naming.resource_names.sql_database}"
  is_shared_to_all = false
  locks            = [module.ai_project.id]

  depends_on = [module.ai_project]
}

########################################
# RBAC: Project identity on connected resources
########################################

# Project -> AI Services: Cognitive Services OpenAI Contributor (conditional)
resource "azurerm_role_assignment" "project_ai_services_openai" {
  count = var.enable_ai_services ? 1 : 0

  scope                = azurerm_cognitive_account.ai_services[0].id
  role_definition_name = "Cognitive Services OpenAI Contributor"
  principal_id         = module.ai_project.principal_id
}

# Project -> AI Services: Cognitive Services Contributor (conditional)
resource "azurerm_role_assignment" "project_ai_services_contributor" {
  count = var.enable_ai_services ? 1 : 0

  scope                = azurerm_cognitive_account.ai_services[0].id
  role_definition_name = "Cognitive Services Contributor"
  principal_id         = module.ai_project.principal_id
}

# Project -> AI Services: Cognitive Services User (conditional)
resource "azurerm_role_assignment" "project_ai_services_user" {
  count = var.enable_ai_services ? 1 : 0

  scope                = azurerm_cognitive_account.ai_services[0].id
  role_definition_name = "Cognitive Services User"
  principal_id         = module.ai_project.principal_id
}

# AI Services -> Storage: Storage Blob Data Contributor (conditional, both must be enabled)
resource "azurerm_role_assignment" "ai_services_storage" {
  count = var.enable_ai_services && var.enable_storage ? 1 : 0

  scope                = module.storage_account[0].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_cognitive_account.ai_services[0].identity[0].principal_id
}

# AI Services -> AI Search: Search Index Data Contributor (conditional)
resource "azurerm_role_assignment" "ai_services_search" {
  count = var.enable_ai_services && var.enable_ai_search ? 1 : 0

  scope                = module.ai_search[0].id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = azurerm_cognitive_account.ai_services[0].identity[0].principal_id
}

# AI Services -> AI Search: Search Service Contributor (conditional)
resource "azurerm_role_assignment" "ai_services_search_service" {
  count = var.enable_ai_services && var.enable_ai_search ? 1 : 0

  scope                = module.ai_search[0].id
  role_definition_name = "Search Service Contributor"
  principal_id         = azurerm_cognitive_account.ai_services[0].identity[0].principal_id
}

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
