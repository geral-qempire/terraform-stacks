########################################
# Storage Account (optional)
########################################

module "storage_account" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_storage_account"
  count  = var.enable_storage ? 1 : 0

  name                     = module.naming.resource_names.storage
  location                 = var.location
  resource_group_name      = azurerm_resource_group.this.name
  account_replication_type = local.tier.storage_replication_type
  tags                     = local.common_tags
}

########################################
# Data Lake Storage - HNS enabled (optional)
########################################

module "storage_datalake" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_storage_account"
  count  = var.enable_storage_datalake ? 1 : 0

  name                     = module.naming.resource_names.storage_datalake
  location                 = var.location
  resource_group_name      = azurerm_resource_group.this.name
  account_replication_type = local.tier.storage_replication_type
  is_hns_enabled           = true
  tags                     = local.common_tags
}

########################################
# Key Vault (optional)
########################################

module "key_vault" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_key_vault"
  count  = var.enable_keyvault ? 1 : 0

  name                     = module.naming.resource_names.key_vault
  location                 = var.location
  resource_group_name      = azurerm_resource_group.this.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = local.tier.keyvault_sku
  purge_protection_enabled = local.tier.keyvault_purge_protection
  tags                     = local.common_tags
}

########################################
# AI Services / Cognitive Account (optional)
########################################

resource "azurerm_cognitive_account" "ai_services" {
  count = var.enable_ai_services ? 1 : 0

  name                          = module.naming.resource_names.ai_services
  location                      = var.location
  resource_group_name           = azurerm_resource_group.this.name
  kind                          = "AIServices"
  sku_name                      = "S0"
  custom_subdomain_name         = module.naming.resource_names.ai_services
  public_network_access_enabled = false
  local_auth_enabled            = true

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

########################################
# AI Search (optional)
########################################

module "ai_search" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_ai_search"
  count  = var.enable_ai_search ? 1 : 0

  name                         = module.naming.resource_names.ai_search
  location                     = var.location
  resource_group_name          = azurerm_resource_group.this.name
  sku                          = local.tier.ai_search_sku
  replica_count                = local.tier.ai_search_replica_count
  partition_count              = local.tier.ai_search_partition_count
  local_authentication_enabled = false
  tags                         = local.common_tags
}

########################################
# SQL Database (optional)
########################################

module "sql_database" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_sql_database"
  count  = var.enable_sql_database ? 1 : 0

  server_name           = module.naming.resource_names.sql_server
  database_name         = module.naming.resource_names.sql_database
  location              = var.location
  resource_group_name   = azurerm_resource_group.this.name
  sku_name              = local.tier.sql_sku_name
  max_size_gb           = local.tier.sql_max_size_gb
  azuread_administrator = var.sql_azuread_administrator
  tags                  = local.common_tags
}
