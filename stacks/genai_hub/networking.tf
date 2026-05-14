########################################
# Private endpoint networking
# Active when network_security != "public"
########################################

locals {
  enable_pe = local.network.enable_private_endpoints

  dns_zone_names = {
    blob          = "privatelink.blob.core.windows.net"
    file          = "privatelink.file.core.windows.net"
    table         = "privatelink.table.core.windows.net"
    queue         = "privatelink.queue.core.windows.net"
    dfs           = "privatelink.dfs.core.windows.net"
    vault         = "privatelink.vaultcore.azure.net"
    account       = "privatelink.cognitiveservices.azure.com"
    searchService = "privatelink.search.windows.net"
    sqlServer     = "privatelink.database.windows.net"
    amlworkspace  = "privatelink.api.azureml.ms"
  }

  needed_dns_zones = local.enable_pe ? toset(distinct(concat(
    var.storage_pe_subresources,
    ["vault", "account", "amlworkspace"],
    var.enable_storage_datalake ? var.storage_datalake_pe_subresources : [],
    var.enable_ai_search ? ["searchService"] : [],
    var.enable_sql_database ? ["sqlServer"] : [],
  ))) : toset([])

  auto_create_dns_zones = setsubtract(local.needed_dns_zones, toset(keys(var.private_dns_zone_ids)))

  resolved_subnet_id = local.enable_pe ? (
    var.subnet_id != null ? var.subnet_id : azurerm_subnet.pe[0].id
  ) : null

  resolved_vnet_id = local.enable_pe ? (
    var.vnet_id != null ? var.vnet_id : azurerm_virtual_network.this[0].id
  ) : null
}

########################################
# VNet + Subnet (auto-created if not provided)
########################################

resource "azurerm_virtual_network" "this" {
  count = local.enable_pe && var.subnet_id == null ? 1 : 0

  name                = module.naming.resource_names.vnet
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = var.vnet_address_space
  tags                = local.common_tags
}

resource "azurerm_subnet" "pe" {
  count = local.enable_pe && var.subnet_id == null ? 1 : 0

  name                 = module.naming.resource_names.subnet_pe
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this[0].name
  address_prefixes     = var.subnet_address_prefixes
}

########################################
# Private DNS Zones (auto-created if not in var.private_dns_zone_ids)
########################################

module "dns_zones" {
  source   = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_private_dns_zone"
  for_each = local.auto_create_dns_zones

  name                = local.dns_zone_names[each.key]
  resource_group_name = azurerm_resource_group.this.name
  vnet_id             = local.resolved_vnet_id
  tags                = local.common_tags
}

locals {
  resolved_dns_zone_ids = merge(
    var.private_dns_zone_ids,
    { for k, v in module.dns_zones : k => v.id }
  )
}

########################################
# Private Endpoints
########################################

module "pe_storage" {
  source   = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_private_endpoint"
  for_each = local.enable_pe ? toset(var.storage_pe_subresources) : toset([])

  name                           = "pe-hub-storage-${each.key}"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.this.name
  subnet_id                      = local.resolved_subnet_id
  private_connection_resource_id = module.storage_account.id
  subresource_names              = [each.key]
  private_dns_zone_ids           = lookup(local.resolved_dns_zone_ids, each.key, null) != null ? [local.resolved_dns_zone_ids[each.key]] : []
  tags                           = local.common_tags
}

module "pe_keyvault" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_private_endpoint"
  count  = local.enable_pe ? 1 : 0

  name                           = "pe-hub-keyvault"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.this.name
  subnet_id                      = local.resolved_subnet_id
  private_connection_resource_id = module.key_vault.id
  subresource_names              = ["vault"]
  private_dns_zone_ids           = lookup(local.resolved_dns_zone_ids, "vault", null) != null ? [local.resolved_dns_zone_ids["vault"]] : []
  tags                           = local.common_tags
}

module "pe_ai_services" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_private_endpoint"
  count  = local.enable_pe ? 1 : 0

  name                           = "pe-hub-ai-services"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.this.name
  subnet_id                      = local.resolved_subnet_id
  private_connection_resource_id = azurerm_cognitive_account.ai_services.id
  subresource_names              = ["account"]
  private_dns_zone_ids           = lookup(local.resolved_dns_zone_ids, "account", null) != null ? [local.resolved_dns_zone_ids["account"]] : []
  tags                           = local.common_tags
}

module "pe_ai_hub" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_private_endpoint"
  count  = local.enable_pe ? 1 : 0

  name                           = "pe-hub-workspace"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.this.name
  subnet_id                      = local.resolved_subnet_id
  private_connection_resource_id = module.ai_hub.id
  subresource_names              = ["amlworkspace"]
  private_dns_zone_ids           = lookup(local.resolved_dns_zone_ids, "amlworkspace", null) != null ? [local.resolved_dns_zone_ids["amlworkspace"]] : []
  tags                           = local.common_tags
}

module "pe_storage_datalake" {
  source   = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_private_endpoint"
  for_each = local.enable_pe && var.enable_storage_datalake ? toset(var.storage_datalake_pe_subresources) : toset([])

  name                           = "pe-hub-datalake-${each.key}"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.this.name
  subnet_id                      = local.resolved_subnet_id
  private_connection_resource_id = module.storage_datalake[0].id
  subresource_names              = [each.key]
  private_dns_zone_ids           = lookup(local.resolved_dns_zone_ids, each.key, null) != null ? [local.resolved_dns_zone_ids[each.key]] : []
  tags                           = local.common_tags
}

module "pe_ai_search" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_private_endpoint"
  count  = local.enable_pe && var.enable_ai_search ? 1 : 0

  name                           = "pe-hub-ai-search"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.this.name
  subnet_id                      = local.resolved_subnet_id
  private_connection_resource_id = module.ai_search[0].id
  subresource_names              = ["searchService"]
  private_dns_zone_ids           = lookup(local.resolved_dns_zone_ids, "searchService", null) != null ? [local.resolved_dns_zone_ids["searchService"]] : []
  tags                           = local.common_tags
}

module "pe_sql_server" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_private_endpoint"
  count  = local.enable_pe && var.enable_sql_database ? 1 : 0

  name                           = "pe-hub-sql-server"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.this.name
  subnet_id                      = local.resolved_subnet_id
  private_connection_resource_id = module.sql_database[0].server_id
  subresource_names              = ["sqlServer"]
  private_dns_zone_ids           = lookup(local.resolved_dns_zone_ids, "sqlServer", null) != null ? [local.resolved_dns_zone_ids["sqlServer"]] : []
  tags                           = local.common_tags
}

########################################
# Outbound rules (inbound_outbound_safe only)
########################################

# The AI Foundry Hub automatically creates PE outbound rules (__SYS_PE_*)
# for its linked resources (storage_account_id, key_vault_id) and any
# connections added to the workspace.

locals {
  pe_outbound_rules = local.network.enable_outbound_rules ? merge(
    var.enable_storage_datalake ? {
      "pe-datalake-blob" = {
        service_resource_id = module.storage_datalake[0].id
        subresource_target  = "blob"
      }
      "pe-datalake-dfs" = {
        service_resource_id = module.storage_datalake[0].id
        subresource_target  = "dfs"
      }
    } : {},
    var.enable_ai_search ? {
      "pe-ai-search" = {
        service_resource_id = module.ai_search[0].id
        subresource_target  = "searchService"
      }
    } : {},
    var.enable_sql_database ? {
      "pe-sql-server" = {
        service_resource_id = module.sql_database[0].server_id
        subresource_target  = "sqlServer"
      }
    } : {}
  ) : {}
}

module "outbound_rules" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_ai_outbound_rules"
  count  = local.network.enable_outbound_rules ? 1 : 0

  workspace_id = module.ai_hub.id
  fqdn_rules   = var.outbound_fqdn_rules

  private_endpoint_rules = local.pe_outbound_rules

  depends_on = [module.ai_hub]
}
