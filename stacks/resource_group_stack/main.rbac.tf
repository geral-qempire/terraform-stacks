locals {
  resource_group_scope = azurerm_resource_group.this.id

  write_access_roles = ["Contributor"]
  read_access_roles  = ["Reader"]
  alert_access_roles = ["BDSO Alert Operator"]
}

module "rbac_write_profile" {
  count  = length(var.write_access_principals) > 0 ? 1 : 0
  source = "git::https://github.com/geral-qempire/terraform-modules.git?ref=modules/az_rbac_profile_assignment/v1.1.0"

  roles      = local.write_access_roles
  principals = var.write_access_principals
  scopes     = [local.resource_group_scope]
}

module "rbac_read_profile" {
  count  = length(var.read_access_principals) > 0 ? 1 : 0
  source = "git::https://github.com/geral-qempire/terraform-modules.git?ref=modules/az_rbac_profile_assignment/v1.1.0"

  roles      = local.read_access_roles
  principals = var.read_access_principals
  scopes     = [local.resource_group_scope]
}

module "rbac_alert_profile" {
  count  = length(var.alert_access_principals) > 0 ? 1 : 0
  source = "git::https://github.com/geral-qempire/terraform-modules.git?ref=modules/az_rbac_profile_assignment/v1.1.0"

  roles      = local.alert_access_roles
  principals = var.alert_access_principals
  scopes     = [local.resource_group_scope]
}


