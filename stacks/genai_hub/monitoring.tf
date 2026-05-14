########################################
# Log Analytics Workspace
########################################

resource "azurerm_log_analytics_workspace" "this" {
  name                = module.naming.resource_names.log_analytics
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = local.tier.log_analytics_retention_days
  tags                = local.common_tags
}

########################################
# Application Insights
########################################

resource "azurerm_application_insights" "this" {
  name                = module.naming.resource_names.app_insights
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = "web"
  tags                = local.common_tags
}
