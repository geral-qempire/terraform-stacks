data "azurerm_client_config" "current" {}

########################################
# Centralized naming
########################################

module "naming" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_naming"

  project_name = var.project_name
  environment  = var.environment
  location     = var.location
  scope        = "proj"
}

########################################
# Resource Group (separate from hub)
########################################

resource "azurerm_resource_group" "this" {
  name     = module.naming.resource_names.resource_group
  location = var.location
  tags     = local.common_tags
}

########################################
# AI Project (child of hub, deployed via azapi)
########################################

module "ai_project" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_ai_project"

  name              = module.naming.resource_names.workspace
  location          = var.location
  resource_group_id = azurerm_resource_group.this.id
  hub_workspace_id  = var.hub_workspace_id
  friendly_name     = "${var.project_name} (${var.environment})"
  tags              = local.common_tags
}
