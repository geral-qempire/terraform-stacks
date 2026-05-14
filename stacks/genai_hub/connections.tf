########################################
# Hub Connections
########################################

# Connection: AI Services -> Hub (RBAC)
module "connection_ai_services" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_ai_connection"

  name         = "connection-ai-services"
  workspace_id = module.ai_hub.id
  category     = "CognitiveService"
  target       = azurerm_cognitive_account.ai_services.endpoint

  metadata = {
    Kind       = "AIServices"
    ResourceId = azurerm_cognitive_account.ai_services.id
  }

  depends_on = [module.ai_hub]
}

# Connection: Azure OpenAI -> Hub (API key, required for model deployments in Foundry)
module "connection_aoai" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_ai_connection"

  name         = "${module.naming.resource_names.ai_services}_aoai"
  workspace_id = module.ai_hub.id
  category     = "AzureOpenAI"
  auth_type    = "ApiKey"
  credentials_key = azurerm_cognitive_account.ai_services.primary_access_key
  target       = azurerm_cognitive_account.ai_services.endpoint

  metadata = {
    ApiType    = "Azure"
    Kind       = "AIServices"
    ResourceId = azurerm_cognitive_account.ai_services.id
  }

  depends_on = [module.ai_hub]
}

# Connection: Cognitive Services default -> Hub (API key, required for Foundry UI)
module "connection_cognitive_default" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_ai_connection"

  name         = module.naming.resource_names.ai_services
  workspace_id = module.ai_hub.id
  category     = "CognitiveService"
  auth_type    = "ApiKey"
  credentials_key = azurerm_cognitive_account.ai_services.primary_access_key
  target       = azurerm_cognitive_account.ai_services.endpoint

  metadata = {
    ApiType    = "Azure"
    Kind       = "AIServices"
    ResourceId = azurerm_cognitive_account.ai_services.id
  }

  depends_on = [module.ai_hub]
}

# Connection: Storage Account -> Hub
module "connection_storage" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_ai_connection"

  name         = "connection-storage"
  workspace_id = module.ai_hub.id
  category     = "AzureBlob"
  target       = module.storage_account.primary_blob_endpoint

  metadata = {
    AccountName   = module.storage_account.name
    ContainerName = "default"
  }

  depends_on = [module.ai_hub]
}

# Connection: Data Lake Storage -> Hub (conditional)
module "connection_storage_datalake" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_ai_connection"
  count  = var.enable_storage_datalake ? 1 : 0

  name         = "connection-storage-datalake"
  workspace_id = module.ai_hub.id
  category     = "AzureBlob"
  target       = module.storage_datalake[0].primary_blob_endpoint

  metadata = {
    AccountName   = module.storage_datalake[0].name
    ContainerName = "default"
  }

  depends_on = [module.ai_hub]
}

# Connection: AI Search -> Hub (conditional)
module "connection_ai_search" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_ai_connection"
  count  = var.enable_ai_search ? 1 : 0

  name         = "connection-ai-search"
  workspace_id = module.ai_hub.id
  category     = "CognitiveSearch"
  target       = module.ai_search[0].endpoint

  metadata = {
    ResourceId = module.ai_search[0].id
  }

  depends_on = [module.ai_hub]
}

# Connection: SQL Database -> Hub (conditional)
module "connection_sql" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_ai_connection"
  count  = var.enable_sql_database ? 1 : 0

  name         = "connection-sql"
  workspace_id = module.ai_hub.id
  category     = "AzureSqlDb"
  target       = "Server=tcp:${module.sql_database[0].server_fqdn},1433;Database=${module.naming.resource_names.sql_database}"

  depends_on = [module.ai_hub]
}

########################################
# RBAC: Hub identity on connected resources
########################################

# Hub -> Key Vault: Key Vault Secrets User
resource "azurerm_role_assignment" "hub_keyvault_secrets" {
  scope                = module.key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.ai_hub.principal_id
}

# Hub -> AI Services: Cognitive Services OpenAI Contributor
resource "azurerm_role_assignment" "hub_ai_services_openai" {
  scope                = azurerm_cognitive_account.ai_services.id
  role_definition_name = "Cognitive Services OpenAI Contributor"
  principal_id         = module.ai_hub.principal_id
}

# Hub -> AI Services: Cognitive Services Contributor (manage deployments, models)
resource "azurerm_role_assignment" "hub_ai_services_contributor" {
  scope                = azurerm_cognitive_account.ai_services.id
  role_definition_name = "Cognitive Services Contributor"
  principal_id         = module.ai_hub.principal_id
}

# Hub -> AI Services: Cognitive Services User (invoke endpoints)
resource "azurerm_role_assignment" "hub_ai_services_user" {
  scope                = azurerm_cognitive_account.ai_services.id
  role_definition_name = "Cognitive Services User"
  principal_id         = module.ai_hub.principal_id
}

# Hub -> AI Search: Search Index Data Contributor (conditional)
resource "azurerm_role_assignment" "hub_ai_search" {
  count = var.enable_ai_search ? 1 : 0

  scope                = module.ai_search[0].id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = module.ai_hub.principal_id
}

# Hub -> Data Lake Storage: Storage Blob Data Contributor (conditional)
resource "azurerm_role_assignment" "hub_storage_datalake_blob" {
  count = var.enable_storage_datalake ? 1 : 0

  scope                = module.storage_datalake[0].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.ai_hub.principal_id
}

# Hub -> SQL: Contributor (conditional)
resource "azurerm_role_assignment" "hub_sql" {
  count = var.enable_sql_database ? 1 : 0

  scope                = module.sql_database[0].server_id
  role_definition_name = "Contributor"
  principal_id         = module.ai_hub.principal_id
}

# AI Services -> Storage: Storage Blob Data Contributor
resource "azurerm_role_assignment" "ai_services_storage" {
  scope                = module.storage_account.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_cognitive_account.ai_services.identity[0].principal_id
}

# AI Services -> AI Search: Search Index Data Contributor (conditional)
resource "azurerm_role_assignment" "ai_services_search" {
  count = var.enable_ai_search ? 1 : 0

  scope                = module.ai_search[0].id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = azurerm_cognitive_account.ai_services.identity[0].principal_id
}

# AI Services -> AI Search: Search Service Contributor (conditional)
resource "azurerm_role_assignment" "ai_services_search_service" {
  count = var.enable_ai_search ? 1 : 0

  scope                = module.ai_search[0].id
  role_definition_name = "Search Service Contributor"
  principal_id         = azurerm_cognitive_account.ai_services.identity[0].principal_id
}
