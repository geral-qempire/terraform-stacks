########################################
# Outbound rules (inbound_outbound_safe only)
########################################

locals {
  # Auto-generate PE outbound rules for connected resources when in locked-down mode
  pe_outbound_rules = local.network.enable_outbound_rules ? merge(
    {
      "pe-storage-blob" = {
        service_resource_id = module.storage_account.id
        subresource_target  = "blob"
      }
      "pe-storage-file" = {
        service_resource_id = module.storage_account.id
        subresource_target  = "file"
      }
      "pe-keyvault" = {
        service_resource_id = module.key_vault.id
        subresource_target  = "vault"
      }
      "pe-ai-services" = {
        service_resource_id = azurerm_cognitive_account.ai_services.id
        subresource_target  = "account"
      }
    },
    var.enable_storage_datalake ? {
      "pe-datalake-blob" = {
        service_resource_id = module.storage_datalake[0].id
        subresource_target  = "blob"
      }
      "pe-datalake-dfs" = {
        service_resource_id = module.storage_datalake[0].id
        subresource_target  = "dfs"
      }
    } : {},
    var.enable_ai_search ? {
      "pe-ai-search" = {
        service_resource_id = module.ai_search[0].id
        subresource_target  = "searchService"
      }
    } : {},
    var.enable_sql_database ? {
      "pe-sql-server" = {
        service_resource_id = module.sql_database[0].server_id
        subresource_target  = "sqlServer"
      }
    } : {}
  ) : {}
}

module "outbound_rules" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_ai_outbound_rules"
  count  = local.network.enable_outbound_rules ? 1 : 0

  workspace_id = module.ai_hub.id
  fqdn_rules   = var.outbound_fqdn_rules

  private_endpoint_rules = local.pe_outbound_rules

  depends_on = [module.ai_hub]
}
