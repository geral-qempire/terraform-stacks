########################################
# RBAC Profile Assignment
########################################

########################################
# Data Sources - Lookup Principals by Name/Type
########################################

# Lookup Azure AD Users by user_principal_name
# Note: Azure AD provider doesn't support display_name lookup directly
# Users must provide user_principal_name (e.g., user@domain.com) instead of display name
data "azuread_user" "users" {
  for_each = {
    for idx, principal in var.principals : idx => principal
    if principal.type == "User"
  }
  user_principal_name = each.value.name
}

# Lookup Azure AD Groups by display_name
data "azuread_group" "groups" {
  for_each = {
    for idx, principal in var.principals : idx => principal
    if principal.type == "Group"
  }
  display_name = each.value.name
}

# Lookup Azure AD Service Principals by display_name
# If the name is already a GUID (principal_id), we'll use it directly
locals {
  # Check if ServicePrincipal name is a GUID (principal_id already provided)
  sp_is_principal_id = {
    for idx, principal in var.principals : idx => (
      principal.type == "ServicePrincipal" && 
      can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", lower(principal.name)))
    )
  }
}

data "azuread_service_principal" "service_principals" {
  for_each = {
    for idx, principal in var.principals : idx => principal
    if principal.type == "ServicePrincipal" && !local.sp_is_principal_id[idx]
  }
  display_name = each.value.name
}

# Lookup Managed Identities by parsing resource ID
# Parse resource ID to extract resource group name and identity name
locals {
  managed_identity_parts = {
    for idx, principal in var.principals : idx => {
      resource_id       = principal.name
      resource_group    = regex("/resourceGroups/([^/]+)/", principal.name)[0]
      identity_name     = regex("/userAssignedIdentities/([^/]+)$", principal.name)[0]
    }
    if principal.type == "ManagedIdentity"
  }
}

data "azurerm_user_assigned_identity" "managed_identities" {
  for_each = local.managed_identity_parts
  name                = each.value.identity_name
  resource_group_name = each.value.resource_group
}

########################################
# Local - Resolve Principal IDs
########################################

locals {
  # Map each principal to its resolved principal_id
  principal_ids = {
    for idx, principal in var.principals : idx => (
      principal.type == "User" ? data.azuread_user.users[idx].object_id : (
        principal.type == "Group" ? data.azuread_group.groups[idx].object_id : (
          principal.type == "ServicePrincipal" ? (
            local.sp_is_principal_id[idx] ? principal.name : data.azuread_service_principal.service_principals[idx].object_id
          ) : (
            principal.type == "ManagedIdentity" ? data.azurerm_user_assigned_identity.managed_identities[idx].principal_id : null
          )
        )
      )
    )
  }

  assignment_scopes = length(var.scopes) > 0 ? var.scopes : (
    var.scope != null ? [var.scope] : []
  )

  # Create cartesian product of principal_ids × roles
  # Include principal_type so it can be passed to the role assignment
  # Note: ManagedIdentities are treated as ServicePrincipal in Azure role assignments
  rbac_assignments = {
    for pair in flatten([
      for idx, principal_id in local.principal_ids : [
        for scope_index, scope in local.assignment_scopes : [
          for role_index, role in var.roles : {
            # Compose a readable, stable key using loop indexes: principal, scope, role
            key            = format("p%02d-s%02d-r%02d", idx, scope_index, role_index)
            principal_id   = principal_id
            principal_type = var.principals[idx].type == "ManagedIdentity" ? "ServicePrincipal" : var.principals[idx].type
            role           = role
            scope          = scope
          }
        ]
      ] if principal_id != null
    ]) : pair.key => {
      scope                = pair.scope
      principal_id         = pair.principal_id
      principal_type      = pair.principal_type
      role_definition_name = pair.role
    }
  }
}

########################################
# Module - RBAC Role Assignments
########################################

module "rbac_assignments" {
  source = "../az_role_assignment"

  rbac                           = local.rbac_assignments
  skip_service_principal_aad_check = var.skip_service_principal_aad_check
}

