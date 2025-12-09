provider "azurerm" {
  features {}

  subscription_id     = var.infra_subscription_id
  storage_use_azuread = true
}
