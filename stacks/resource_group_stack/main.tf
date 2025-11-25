############################################################
# Name generation
############################################################

module "resource_group_name" {
  source         = "../../../terraform-modules/modules/az_name_generator"
  resource_type  = "rg"
  location       = var.location
  project_name   = var.project_name
  environment    = var.environment
  random_postfix = var.name_random_postfix
}

############################################################
# Resource group
############################################################

resource "azurerm_resource_group" "this" {
  name     = module.resource_group_name.name
  location = var.location
  tags     = local.base_tags
}


