############################################################
# Name generation
############################################################

module "resource_group_name" {
  source         = "git::https://github.com/geral-qempire/terraform-modules.git?ref=modules/az_name_generator/v1.0.0"
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


