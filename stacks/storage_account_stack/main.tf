############################################################
# Name generation (locals defined in locals.tf)
############################################################

module "storage_account_name" {
  source         = "../../../terraform-modules/modules/az_name_generator"
  resource_type  = "st"
  location       = var.location
  project_name   = var.project_name
  environment    = var.environment
  org_code       = var.org_code
  random_postfix = var.name_random_postfix
  merged         = true
}

############################################################
# Storage account
############################################################

module "storage_account" {
  source = "../../../terraform-modules/modules/az_storage_account"

  providers = {
    azurerm = azurerm
    azapi   = azapi
  }

  name                 = module.storage_account_name.name
  resource_group_name  = var.resource_group_name
  location             = var.location

  account_tier                      = local.storage_tier_selected.account_tier
  account_kind                      = local.storage_tier_selected.account_kind
  access_tier                       = local.storage_tier_selected.access_tier
  account_replication_type          = local.storage_tier_selected.account_replication_type
  min_tls_version                   = local.storage_tier_selected.min_tls_version
  shared_access_key_enabled         = local.storage_tier_selected.shared_access_key_enabled
  infrastructure_encryption_enabled = local.storage_tier_selected.infrastructure_encryption_enabled
  blob_delete_retention_days        = local.storage_tier_selected.blob_delete_retention_days
  container_delete_retention_days   = local.storage_tier_selected.container_delete_retention_days
  enable_geo_priority_replication   = local.storage_tier_selected.enable_geo_priority_replication

  public_network_access_enabled = local.public_network_access_enabled
  network_rules_default_action  = local.network_rules_default_action
  network_rules_bypass          = local.storage_tier_selected.network_rules_bypass
  network_rules_ip_rules        = local.network_rules_ip_rules

  blob_versioning_enabled       = local.versioning_tier_selected.versioning_enabled
  blob_last_access_time_enabled = var.smart_lifecycle_tier != "off"

  lifecycle_management_policy_rules = local.all_lifecycle_management_policy_rules
  identity                           = var.identity
  tags                               = local.base_tags
}


