data "azurerm_client_config" "current" {}

########################################
# Resource Group (separate from hub)
########################################

resource "azurerm_resource_group" "this" {
  name     = local.resource_names.resource_group
  location = var.location
  tags     = local.common_tags
}

########################################
# AI Project (child of hub, deployed via azapi)
########################################

module "ai_project" {
  source = "git::https://github.com/geral-qempire/terraform-modules.git//modules/az_ai_project"

  name              = local.resource_names.ai_project
  location          = var.location
  resource_group_id = azurerm_resource_group.this.id
  hub_workspace_id  = var.hub_workspace_id
  friendly_name     = "${var.project_name} (${var.environment})"
  tags              = local.common_tags
}
