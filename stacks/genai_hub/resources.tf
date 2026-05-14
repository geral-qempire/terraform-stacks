########################################
# Data Lake Storage - HNS enabled (optional)
########################################

module "storage_datalake" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_storage_account"
  count  = var.enable_storage_datalake ? 1 : 0

  name                          = module.naming.resource_names.storage_datalake
  location                      = var.location
  resource_group_name           = azurerm_resource_group.this.name
  account_replication_type      = local.tier.storage_replication_type
  is_hns_enabled                = true
  public_network_access_enabled = local.network.public_network_access
  tags                          = local.common_tags
}

########################################
# AI Search (optional)
########################################

module "ai_search" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_ai_search"
  count  = var.enable_ai_search ? 1 : 0

  name                          = module.naming.resource_names.ai_search
  location                      = var.location
  resource_group_name           = azurerm_resource_group.this.name
  sku                           = local.tier.ai_search_sku
  replica_count                 = local.tier.ai_search_replica_count
  partition_count               = local.tier.ai_search_partition_count
  public_network_access_enabled = local.network.public_network_access
  local_authentication_enabled  = false
  tags                          = local.common_tags
}

########################################
# SQL Database (optional)
########################################

module "sql_database" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_sql_database"
  count  = var.enable_sql_database ? 1 : 0

  server_name                   = module.naming.resource_names.sql_server
  database_name                 = module.naming.resource_names.sql_database
  location                      = var.location
  resource_group_name           = azurerm_resource_group.this.name
  sku_name                      = local.tier.sql_sku_name
  max_size_gb                   = local.tier.sql_max_size_gb
  azuread_administrator         = var.sql_azuread_administrator
  public_network_access_enabled = local.network.public_network_access
  tags                          = local.common_tags
}
