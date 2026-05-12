data "azurerm_client_config" "current" {}

########################################
# Resource Group
########################################

resource "azurerm_resource_group" "this" {
  name     = local.resource_names.resource_group
  location = var.location
  tags     = local.common_tags
}

########################################
# Hub-level Storage Account
########################################

module "storage_account" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_storage_account"

  name                          = local.resource_names.storage
  location                      = var.location
  resource_group_name           = azurerm_resource_group.this.name
  account_replication_type      = local.tier.storage_replication_type
  public_network_access_enabled = local.network.public_network_access
  tags                          = local.common_tags
}

########################################
# Hub-level Key Vault
########################################

module "key_vault" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_key_vault"

  name                          = local.resource_names.key_vault
  location                      = var.location
  resource_group_name           = azurerm_resource_group.this.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = local.tier.keyvault_sku
  purge_protection_enabled      = local.tier.keyvault_purge_protection
  public_network_access_enabled = local.network.public_network_access
  tags                          = local.common_tags
}

########################################
# AI Services (Cognitive Account)
########################################

resource "azurerm_cognitive_account" "ai_services" {
  name                          = local.resource_names.ai_services
  location                      = var.location
  resource_group_name           = azurerm_resource_group.this.name
  kind                          = "AIServices"
  sku_name                      = "S0"
  custom_subdomain_name         = local.resource_names.ai_services
  public_network_access_enabled = local.network.public_network_access
  local_auth_enabled            = false

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

########################################
# AI Hub
########################################

module "ai_hub" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_ai_hub"

  name                           = local.resource_names.ai_hub
  location                       = var.location
  resource_group_name            = azurerm_resource_group.this.name
  storage_account_id             = module.storage_account.id
  key_vault_id                   = module.key_vault.id
  application_insights_id        = azurerm_application_insights.this.id
  public_network_access_enabled  = local.network.public_network_access
  managed_network_isolation_mode = local.network.managed_network_isolation_mode
  tags                           = local.common_tags
}
