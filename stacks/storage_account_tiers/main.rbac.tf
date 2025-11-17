########################################
# RBAC for Storage Accounts - Write Access and Read Access Profiles
########################################

locals {
  resource_id = module.storage_account.storage_account_id

  # RBAC Role Profiles
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

  alert_scope_candidates = [
    {
      enabled = var.enable_availability_alert
      id      = module.storage_account.availability_alert_id
    },
    {
      enabled = var.enable_success_server_latency_alert
      id      = module.storage_account.success_server_latency_alert_id
    },
    {
      enabled = var.enable_used_capacity_alert
      id      = module.storage_account.used_capacity_alert_id
    }
  ]

  alert_ids = [for alert in local.alert_scope_candidates : alert.id if alert.enabled]
}

########################################
# Module - Write Access RBAC Profile Assignments
########################################

module "rbac_write_access" {
  count  = length(var.write_access_principals) > 0 ? 1 : 0
  source = "git::https://github.com/geral-qempire/terraform-modules.git?ref=modules/az_rbac_profile_assignment/v1.0.1"

  roles      = local.write_access_roles
  principals = var.write_access_principals
  scopes     = [local.resource_id]
}

########################################
# Module - Read Access RBAC Profile Assignments
########################################

module "rbac_read_access" {
  count  = length(var.read_access_principals) > 0 ? 1 : 0
  source = "git::https://github.com/geral-qempire/terraform-modules.git?ref=modules/az_rbac_profile_assignment/v1.0.1"

  roles      = local.read_access_roles
  principals = var.read_access_principals
  scopes     = [local.resource_id]
}

########################################
# Module - Alert Access RBAC Profile Assignments
########################################

module "rbac_alert_access" {
  count  = length(var.alert_access_principals) > 0 && length(local.alert_ids) > 0 ? 1 : 0
  source = "git::https://github.com/geral-qempire/terraform-modules.git?ref=modules/az_rbac_profile_assignment/v1.0.1"

  roles      = local.alert_access_roles
  principals = var.alert_access_principals
  scopes     = local.alert_ids
}
