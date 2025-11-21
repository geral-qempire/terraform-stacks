provider "azurerm" {
  features {}
  subscription_id     = var.infra_subscription_id
  storage_use_azuread = true
}

provider "azapi" {
  subscription_id = var.infra_subscription_id
}

provider "azurerm" {
  features {}
  alias               = "dns"
  subscription_id     = var.dns_subscription_id
  storage_use_azuread = true
}