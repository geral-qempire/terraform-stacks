terraform {
  backend "azurerm" {
    subscription_id      = "2a4f4e29-3789-4e47-867d-62a6eb17950b"
    resource_group_name  = "rg-swc-tfstate-nonprod"
    storage_account_name = "stswcqetfstatenonprod"
    container_name       = "genai-tfstate"
    key                  = "storage-account-tiers/terraform.tfstate"
  }
}

