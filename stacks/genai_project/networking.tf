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

module "outbound_rules" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_ai_outbound_rules"
  count  = local.network.enable_outbound_rules ? 1 : 0

  workspace_id           = var.hub_workspace_id
  private_endpoint_rules = local.pe_outbound_rules

  depends_on = [module.ai_project]
}
