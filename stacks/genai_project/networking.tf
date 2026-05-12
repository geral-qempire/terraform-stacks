########################################
# PE outbound rules (inbound_outbound_safe only)
# Rules are created on the HUB workspace because
# the project lives within the hub's managed vnet.
# The hub identity needs Contributor on the project
# RG to approve PE connections on project resources.
# Rules are created sequentially with a 2s delay to
# avoid Etag conflicts on the workspace API.
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
  pe_outbound_list = local.network.enable_outbound_rules ? concat(
    var.enable_storage ? [{
      name                = "pe-${var.project_name}-storage-blob"
      service_resource_id = module.storage_account[0].id
      subresource_target  = "blob"
    }] : [],
    var.enable_storage_datalake ? [
      {
        name                = "pe-${var.project_name}-datalake-blob"
        service_resource_id = module.storage_datalake[0].id
        subresource_target  = "blob"
      },
      {
        name                = "pe-${var.project_name}-datalake-dfs"
        service_resource_id = module.storage_datalake[0].id
        subresource_target  = "dfs"
      },
    ] : [],
    var.enable_keyvault ? [{
      name                = "pe-${var.project_name}-keyvault"
      service_resource_id = module.key_vault[0].id
      subresource_target  = "vault"
    }] : [],
    var.enable_ai_search ? [{
      name                = "pe-${var.project_name}-ai-search"
      service_resource_id = module.ai_search[0].id
      subresource_target  = "searchService"
    }] : [],
    var.enable_sql_database ? [{
      name                = "pe-${var.project_name}-sql-server"
      service_resource_id = module.sql_database[0].server_id
      subresource_target  = "sqlServer"
    }] : [],
  ) : []
}

resource "time_sleep" "pe_delay" {
  count           = length(local.pe_outbound_list)
  create_duration = count.index > 0 ? "2s" : "0s"

  triggers = {
    name     = local.pe_outbound_list[count.index].name
    after_id = count.index > 0 ? azapi_resource.pe_outbound_rules[count.index - 1].id : ""
  }

  depends_on = [azurerm_role_assignment.hub_identity_on_project_rg]
}

resource "azapi_resource" "pe_outbound_rules" {
  count = length(local.pe_outbound_list)

  type                      = "Microsoft.MachineLearningServices/workspaces/outboundRules@2024-10-01"
  name                      = time_sleep.pe_delay[count.index].triggers["name"]
  parent_id                 = var.hub_workspace_id
  schema_validation_enabled = false

  body = {
    properties = {
      type     = "PrivateEndpoint"
      category = "UserDefined"
      status   = "Active"
      destination = {
        serviceResourceId = local.pe_outbound_list[count.index].service_resource_id
        subresourceTarget = local.pe_outbound_list[count.index].subresource_target
        sparkEnabled      = false
      }
    }
  }

  depends_on = [
    module.ai_project,
    azurerm_role_assignment.hub_identity_on_project_rg,
  ]
}
