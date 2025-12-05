provider "azurerm" {
  features {}

  subscription_id     = var.infra_subscription_id
  storage_use_azuread = true
}

provider "azurerm" {
  alias = "dns"

  features {}

  subscription_id = coalesce(var.dns_subscription_id, var.infra_subscription_id)
}

provider "azapi" {
  subscription_id = var.infra_subscription_id
}


