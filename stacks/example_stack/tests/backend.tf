terraform {
  backend "azurerm" {
    resource_group_name  = "rg-swc-tfstate-nonprod"
    storage_account_name = "stswcqetfstatenonprod"
    container_name       = "tfstate"
    key                  = "stack-staging/example_stack/terraform.tfstate"
  }
}

