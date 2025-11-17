/**
 * Storage Account Tiers Template
 * - Deploys Storage Accounts with pre-configured tier settings
 * - Configures RBAC profiles for tech leads and developers
 * - Enables private endpoints and default alerts
 */

########################################
# Abbreviations
########################################
module "region_abbreviations" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_region_abbreviations?ref=modules/az_region_abbreviations/v1.0.0"
}

########################################
# Lookups (Resource Group and Subnet for Private Endpoint)
########################################
data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "private_endpoints" {
  name                = coalesce(var.vnet_name, "tech-${var.environment}-vnet")
  resource_group_name = coalesce(var.vnet_resource_group_name, "tech-net${var.environment}-ne-rg")
}

data "azurerm_subnet" "private_endpoints" {
  name                 = var.subnet_name
  virtual_network_name = coalesce(var.vnet_name, "tech-${var.environment}-vnet")
  resource_group_name  = coalesce(var.vnet_resource_group_name, "tech-net${var.environment}-ne-rg")
}

########################################
# Action Group (Optional)
########################################
module "action_group" {
  count  = length(local.action_group_receivers) > 0 ? 1 : 0
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_action_group_map?ref=modules/az_action_group_map/v1.0.0"

  environment          = var.environment
  service_prefix       = var.service_prefix
  location             = var.location
  resource_group_name  = data.azurerm_resource_group.this.name
  region_abbreviations = module.region_abbreviations.regions
  enabled              = true
  email_receivers      = local.action_group_receivers
  tags = {
    environment     = upper(var.environment)
    costCenter      = upper(var.costCenter)
    businessUnit    = upper(var.businessUnit)
    applicationName = upper(var.applicationName)
    applicationCode = upper(var.applicationCode)
  }
}

########################################
# Storage Account
########################################
module "storage_account" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_storage_account?ref=modules/az_storage_account/v1.0.0"

  providers = {
    azurerm.dns = azurerm.dns
  }

  environment          = var.environment
  service_prefix       = var.service_prefix
  resource_group_name  = data.azurerm_resource_group.this.name
  location             = var.location
  region_abbreviations = module.region_abbreviations.regions

  account_tier                      = local.selected_parameter_tier.account_tier
  account_replication_type          = local.selected_parameter_tier.account_replication_type
  account_kind                      = local.selected_parameter_tier.account_kind
  access_tier                       = local.selected_parameter_tier.access_tier
  min_tls_version                   = local.selected_parameter_tier.min_tls_version
  public_network_access_enabled     = local.selected_parameter_tier.public_network_access_enabled
  shared_access_key_enabled         = local.selected_parameter_tier.shared_access_key_enabled
  infrastructure_encryption_enabled = local.selected_parameter_tier.infrastructure_encryption_enabled
  network_rules_default_action      = local.selected_parameter_tier.network_rules_default_action
  network_rules_bypass              = local.selected_parameter_tier.network_rules_bypass
  blob_versioning_enabled           = coalesce(local.selected_versioning_tier.versioning_enabled, false)
  blob_last_access_time_enabled     = coalesce(local.selected_lifecycle_tier.last_access_time_enabled, false)
  blob_delete_retention_days        = local.selected_parameter_tier.blob_delete_retention_days
  container_delete_retention_days   = local.selected_parameter_tier.container_delete_retention_days

  # Private Endpoints (configurable per deployment)
  enable_private_endpoint_blob  = var.enable_private_endpoint_blob
  enable_private_endpoint_file  = var.enable_private_endpoint_file
  enable_private_endpoint_table = var.enable_private_endpoint_table
  enable_private_endpoint_queue = var.enable_private_endpoint_queue
  enable_private_endpoint_dfs   = var.enable_private_endpoint_dfs

  dns_resource_group_name   = var.dns_hub_resource_group_name
  subnet_id                 = data.azurerm_subnet.private_endpoints.id
  private_endpoint_location = data.azurerm_virtual_network.private_endpoints.location

  # Integrated Alerts
  enable_availability_alert           = var.enable_availability_alert
  enable_success_server_latency_alert = var.enable_success_server_latency_alert
  enable_used_capacity_alert          = var.enable_used_capacity_alert

  availability_alert_severity            = var.availability_alert_severity
  availability_alert_threshold           = var.availability_alert_threshold
  success_server_latency_alert_severity  = var.success_server_latency_alert_severity
  success_server_latency_alert_threshold = var.success_server_latency_alert_threshold
  used_capacity_alert_severity           = var.used_capacity_alert_severity
  used_capacity_alert_threshold          = var.used_capacity_alert_threshold

  # Alert Configuration
  availability_alert_action_group_ids           = length(local.action_group_receivers) > 0 ? [module.action_group[0].action_group_id] : (length(var.alert_action_group_ids) > 0 ? var.alert_action_group_ids : [])
  success_server_latency_alert_action_group_ids = length(local.action_group_receivers) > 0 ? [module.action_group[0].action_group_id] : (length(var.alert_action_group_ids) > 0 ? var.alert_action_group_ids : [])
  used_capacity_alert_action_group_ids          = length(local.action_group_receivers) > 0 ? [module.action_group[0].action_group_id] : (length(var.alert_action_group_ids) > 0 ? var.alert_action_group_ids : [])

  identity = var.identity

  tags = {
    environment     = upper(var.environment)
    costCenter      = upper(var.costCenter)
    businessUnit    = upper(var.businessUnit)
    applicationName = upper(var.applicationName)
    applicationCode = upper(var.applicationCode)
  }
}

resource "azurerm_storage_management_policy" "this" {
  count              = length(local.management_policy_rules) > 0 ? 1 : 0
  storage_account_id = module.storage_account.storage_account_id

  dynamic "rule" {
    for_each = local.management_policy_rules
    content {
      name    = rule.value.name
      enabled = true

      filters {
        blob_types   = coalesce(rule.value.filters.blob_types, ["blockBlob"])
        prefix_match = coalesce(rule.value.filters.prefix_match, [])
      }

      actions {
        dynamic "version" {
          for_each = lookup(rule.value.actions, "version", null) != null ? [lookup(rule.value.actions, "version", null)] : []
          content {
            change_tier_to_cool_after_days_since_creation = lookup(version.value, "change_tier_to_cool_after_days_since_creation", null)
            delete_after_days_since_creation              = lookup(version.value, "delete_after_days_since_creation", null)
          }
        }

        dynamic "base_blob" {
          for_each = lookup(rule.value.actions, "base_blob", null) != null ? [lookup(rule.value.actions, "base_blob", null)] : []
          content {
            auto_tier_to_hot_from_cool_enabled                          = lookup(base_blob.value, "auto_tier_to_hot_from_cool_enabled", false)
            tier_to_cool_after_days_since_last_access_time_greater_than = lookup(base_blob.value, "tier_to_cool_after_days_since_last_access_time_greater_than", null)
            delete_after_days_since_last_access_time_greater_than       = lookup(base_blob.value, "delete_after_days_since_last_access_time_greater_than", null)
          }
        }
      }
    }
  }
}
