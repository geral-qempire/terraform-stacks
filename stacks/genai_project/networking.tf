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
  }

  needed_dns_zones = local.enable_pe ? toset(distinct(concat(
    var.enable_storage ? var.storage_pe_subresources : [],
    var.enable_storage_datalake ? var.storage_datalake_pe_subresources : [],
    var.enable_keyvault ? ["vault"] : [],
    var.enable_ai_services ? ["account"] : [],
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
  for_each = local.enable_pe && var.enable_storage ? toset(var.storage_pe_subresources) : toset([])

  name                           = "pe-proj-storage-${each.key}"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.this.name
  subnet_id                      = local.resolved_subnet_id
  private_connection_resource_id = module.storage_account[0].id
  subresource_names              = [each.key]
  private_dns_zone_ids           = lookup(local.resolved_dns_zone_ids, each.key, null) != null ? [local.resolved_dns_zone_ids[each.key]] : []
  tags                           = local.common_tags
}

module "pe_storage_datalake" {
  source   = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_private_endpoint"
  for_each = local.enable_pe && var.enable_storage_datalake ? toset(var.storage_datalake_pe_subresources) : toset([])

  name                           = "pe-proj-datalake-${each.key}"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.this.name
  subnet_id                      = local.resolved_subnet_id
  private_connection_resource_id = module.storage_datalake[0].id
  subresource_names              = [each.key]
  private_dns_zone_ids           = lookup(local.resolved_dns_zone_ids, each.key, null) != null ? [local.resolved_dns_zone_ids[each.key]] : []
  tags                           = local.common_tags
}

module "pe_keyvault" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_private_endpoint"
  count  = local.enable_pe && var.enable_keyvault ? 1 : 0

  name                           = "pe-proj-keyvault"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.this.name
  subnet_id                      = local.resolved_subnet_id
  private_connection_resource_id = module.key_vault[0].id
  subresource_names              = ["vault"]
  private_dns_zone_ids           = lookup(local.resolved_dns_zone_ids, "vault", null) != null ? [local.resolved_dns_zone_ids["vault"]] : []
  tags                           = local.common_tags
}

module "pe_ai_services" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_private_endpoint"
  count  = local.enable_pe && var.enable_ai_services ? 1 : 0

  name                           = "pe-proj-ai-services"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.this.name
  subnet_id                      = local.resolved_subnet_id
  private_connection_resource_id = azurerm_cognitive_account.ai_services[0].id
  subresource_names              = ["account"]
  private_dns_zone_ids           = lookup(local.resolved_dns_zone_ids, "account", null) != null ? [local.resolved_dns_zone_ids["account"]] : []
  tags                           = local.common_tags
}

module "pe_ai_search" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_private_endpoint"
  count  = local.enable_pe && var.enable_ai_search ? 1 : 0

  name                           = "pe-proj-ai-search"
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

  name                           = "pe-proj-sql-server"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.this.name
  subnet_id                      = local.resolved_subnet_id
  private_connection_resource_id = module.sql_database[0].server_id
  subresource_names              = ["sqlServer"]
  private_dns_zone_ids           = lookup(local.resolved_dns_zone_ids, "sqlServer", null) != null ? [local.resolved_dns_zone_ids["sqlServer"]] : []
  tags                           = local.common_tags
}

########################################
# Outbound PE rules on the HUB (inbound_outbound_safe only)
# Rules are created on the HUB workspace because
# the project lives within the hub's managed vnet.
# The hub identity needs Contributor on the project
# RG to approve PE connections on project resources.
########################################

data "azapi_resource" "hub" {
  count = local.network.enable_outbound_rules ? 1 : 0

  type        = "Microsoft.MachineLearningServices/workspaces@2024-10-01"
  resource_id = var.hub_workspace_id

  response_export_values = ["identity.principalId"]
}

resource "azurerm_role_assignment" "hub_identity_on_project_rg" {
  count = local.network.enable_outbound_rules ? 1 : 0

  scope                = azurerm_resource_group.this.id
  role_definition_name = "Contributor"
  principal_id         = data.azapi_resource.hub[0].output.identity.principalId
  principal_type       = "ServicePrincipal"
}

locals {
  pe_outbound_rules = local.network.enable_outbound_rules ? merge(
    var.enable_storage ? {
      "pe-${var.project_name}-storage-blob" = {
        service_resource_id = module.storage_account[0].id
        subresource_target  = "blob"
      }
    } : {},
    var.enable_storage_datalake ? {
      "pe-${var.project_name}-datalake-blob" = {
        service_resource_id = module.storage_datalake[0].id
        subresource_target  = "blob"
      }
      "pe-${var.project_name}-datalake-dfs" = {
        service_resource_id = module.storage_datalake[0].id
        subresource_target  = "dfs"
      }
    } : {},
    var.enable_keyvault ? {
      "pe-${var.project_name}-keyvault" = {
        service_resource_id = module.key_vault[0].id
        subresource_target  = "vault"
      }
    } : {},
    var.enable_ai_services ? {
      "pe-${var.project_name}-ai-services" = {
        service_resource_id = azurerm_cognitive_account.ai_services[0].id
        subresource_target  = "account"
      }
    } : {},
    var.enable_ai_search ? {
      "pe-${var.project_name}-ai-search" = {
        service_resource_id = module.ai_search[0].id
        subresource_target  = "searchService"
      }
    } : {},
    var.enable_sql_database ? {
      "pe-${var.project_name}-sql-server" = {
        service_resource_id = module.sql_database[0].server_id
        subresource_target  = "sqlServer"
      }
    } : {}
  ) : {}
}

resource "azapi_resource" "pe_outbound_rules" {
  for_each = local.pe_outbound_rules

  type                      = "Microsoft.MachineLearningServices/workspaces/outboundRules@2024-10-01"
  name                      = each.key
  parent_id                 = var.hub_workspace_id
  schema_validation_enabled = false
  locks                     = [var.hub_workspace_id]

  body = {
    properties = {
      type     = "PrivateEndpoint"
      category = "UserDefined"
      status   = "Active"
      destination = {
        serviceResourceId = each.value.service_resource_id
        subresourceTarget = each.value.subresource_target
        sparkEnabled      = false
      }
    }
  }

  depends_on = [
    module.ai_project,
    azurerm_role_assignment.hub_identity_on_project_rg,
  ]
}
