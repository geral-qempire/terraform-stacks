terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = ">= 4.38.1"
      configuration_aliases = [azurerm.dns]
    }
    azapi = {
      source  = "azure/azapi"
      version = ">= 1.13.1"
    }
  }
}

