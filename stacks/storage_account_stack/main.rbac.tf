locals {
  storage_account_scope = module.storage_account.storage_account_id

  write_access_roles = [
    "Storage Blob Data Contributor",
    "Storage File Data SMB Share Contributor",
    "Storage Queue Data Contributor",
    "Storage Table Data Contributor",
    "Reader"
  ]

  read_access_roles = [
    "Storage Blob Data Reader",
    "Storage File Data SMB Share Reader",
    "Storage Queue Data Reader",
    "Storage Table Data Reader",
    "Reader"
  ]

  alert_access_roles = [
    "BDSO Alert Operator"
  ]

  alert_scopes = values(azurerm_monitor_metric_alert.golden_signal)[*].id
}

module "rbac_write_profile" {
  count    = length(var.write_access_principals) > 0 ? 1 : 0
  source   = "git::https://github.com/geral-qempire/terraform-modules.git?ref=modules/az_rbac_profile_assignment/v1.1.0"

  roles      = local.write_access_roles
  principals = var.write_access_principals
  scopes     = [local.storage_account_scope]
}

module "rbac_read_profile" {
  count    = length(var.read_access_principals) > 0 ? 1 : 0
  source   = "git::https://github.com/geral-qempire/terraform-modules.git?ref=modules/az_rbac_profile_assignment/v1.1.0"

  roles      = local.read_access_roles
  principals = var.read_access_principals
  scopes     = [local.storage_account_scope]
}

module "rbac_alert_profile" {
  count    = length(var.alert_access_principals) > 0 && length(local.alert_scopes) > 0 ? 1 : 0
  source   = "git::https://github.com/geral-qempire/terraform-modules.git?ref=modules/az_rbac_profile_assignment/v1.1.0"

  roles      = local.alert_access_roles
  principals = var.alert_access_principals
  scopes     = local.alert_scopes
}


