locals {
  private_dns_zone_defaults = {
    blob  = ["privatelink.blob.core.windows.net"]
    file  = ["privatelink.file.core.windows.net"]
    queue = ["privatelink.queue.core.windows.net"]
    table = ["privatelink.table.core.windows.net"]
  }

  private_endpoint_matrix = {
    blob = {
      enabled           = var.enable_private_endpoint_blob
      subresource_names = ["blob"]
      dns_zones         = lookup(var.private_dns_zone_overrides, "blob", local.private_dns_zone_defaults.blob)
    }
    file = {
      enabled           = var.enable_private_endpoint_file
      subresource_names = ["file"]
      dns_zones         = lookup(var.private_dns_zone_overrides, "file", local.private_dns_zone_defaults.file)
    }
    queue = {
      enabled           = var.enable_private_endpoint_queue
      subresource_names = ["queue"]
      dns_zones         = lookup(var.private_dns_zone_overrides, "queue", local.private_dns_zone_defaults.queue)
    }
    table = {
      enabled           = var.enable_private_endpoint_table
      subresource_names = ["table"]
      dns_zones         = lookup(var.private_dns_zone_overrides, "table", local.private_dns_zone_defaults.table)
    }
  }

  enabled_private_endpoints = {
    for key, cfg in local.private_endpoint_matrix : key => cfg if cfg.enabled
  }
}

############################################################
# Name generation for private endpoints
############################################################

module "private_endpoint_names" {
  for_each        = local.enabled_private_endpoints
  source          = "git::https://github.com/geral-qempire/terraform-modules.git?ref=modules/az_name_generator/v1.0.0"
  resource_type   = "pep-${each.key}"
  location        = var.location
  project_name    = var.project_name
  environment     = var.environment
  org_code        = var.org_code
  random_postfix  = var.name_random_postfix
  merged          = true
}

############################################################
# Private endpoints
############################################################

module "private_endpoints" {
  for_each = local.enabled_private_endpoints
  source   = "git::https://github.com/geral-qempire/terraform-modules.git?ref=modules/az_private_endpoint/v1.0.1"

  providers = {
    azurerm     = azurerm
    azurerm.dns = azurerm.dns
  }

  name                          = module.private_endpoint_names[each.key].name
  location                      = var.location
  private_endpoint_location     = var.private_endpoint_location
  resource_group_name           = var.resource_group_name
  subnet_id                     = var.private_endpoint_subnet_id
  subnet_name                   = var.private_endpoint_subnet_name
  virtual_network_name          = var.private_endpoint_virtual_network_name
  virtual_network_resource_group_name = coalesce(var.private_endpoint_virtual_network_resource_group_name, var.resource_group_name)
  private_connection_resource_id = module.storage_account.storage_account_id
  subresource_names             = each.value.subresource_names
  private_dns_zones             = each.value.dns_zones
  dns_resource_group_name       = var.dns_resource_group_name
  tags                          = local.base_tags
}


