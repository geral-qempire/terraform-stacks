########################################
# PE outbound rules (inbound_outbound_safe only)
# Rules are created on the HUB workspace because
# the project lives within the hub's managed vnet.
########################################

locals {
  pe_outbound_rules = local.network.enable_outbound_rules ? merge(
    var.enable_storage ? {
      "pe-proj-storage-blob" = {
        service_resource_id = module.storage_account[0].id
        subresource_target  = "blob"
      }
    } : {},
    var.enable_storage_datalake ? {
      "pe-proj-datalake-blob" = {
        service_resource_id = module.storage_datalake[0].id
        subresource_target  = "blob"
      }
      "pe-proj-datalake-dfs" = {
        service_resource_id = module.storage_datalake[0].id
        subresource_target  = "dfs"
      }
    } : {},
    var.enable_keyvault ? {
      "pe-proj-keyvault" = {
        service_resource_id = module.key_vault[0].id
        subresource_target  = "vault"
      }
    } : {},
    var.enable_ai_search ? {
      "pe-proj-ai-search" = {
        service_resource_id = module.ai_search[0].id
        subresource_target  = "searchService"
      }
    } : {},
    var.enable_sql_database ? {
      "pe-proj-sql-server" = {
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

  depends_on = [module.ai_project]
}
