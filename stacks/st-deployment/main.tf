module "storage_account_tiers_stack" {
  source = "git::https://github.com/geral-qempire/terraform-stacks.git?ref=stacks/storage_account_tiers/v1.0.1"

  # Core Configuration
  service_prefix      = var.service_prefix
  location            = var.location
  environment         = var.environment
  resource_group_name = var.resource_group_name

  # Tier Selection
  parameter_tier         = var.parameter_tier
  parameter_tier_custom  = var.parameter_tier_custom
  versioning_tier        = var.versioning_tier
  versioning_tier_custom = var.versioning_tier_custom
  lifecycle_tier         = var.lifecycle_tier
  lifecycle_tier_custom  = var.lifecycle_tier_custom

  # Subscription IDs
  infra_subscription_id = var.infra_subscription_id
  dns_subscription_id   = var.dns_subscription_id

  # Private Endpoint Configuration
  subnet_name                 = var.subnet_name
  vnet_name                   = var.vnet_name
  vnet_resource_group_name    = var.vnet_resource_group_name
  dns_hub_resource_group_name = var.dns_resource_group_name

  # Private Endpoint Flags
  enable_private_endpoint_blob  = var.enable_private_endpoint_blob
  enable_private_endpoint_file  = var.enable_private_endpoint_file
  enable_private_endpoint_queue = var.enable_private_endpoint_queue
  enable_private_endpoint_table = var.enable_private_endpoint_table
  enable_private_endpoint_dfs   = var.enable_private_endpoint_dfs

  # RBAC Configuration
  write_access_principals = var.write_access_principals
  read_access_principals  = var.read_access_principals
  alert_access_principals = var.alert_access_principals

  # Action Group Configuration
  action_group_emails    = var.action_group_enabled ? var.action_group_emails : []
  alert_action_group_ids = var.alert_action_group_ids

  # Alert Configuration
  enable_availability_alert              = var.enable_availability_alert
  availability_alert_severity            = var.availability_alert_severity
  availability_alert_threshold           = var.availability_alert_threshold
  enable_success_server_latency_alert    = var.enable_success_server_latency_alert
  success_server_latency_alert_severity  = var.success_server_latency_alert_severity
  success_server_latency_alert_threshold = var.success_server_latency_alert_threshold
  enable_used_capacity_alert             = var.enable_used_capacity_alert
  used_capacity_alert_severity           = var.used_capacity_alert_severity
  used_capacity_alert_threshold          = var.used_capacity_alert_threshold

  # Identity Configuration
  identity = var.identity

  # Tags
  costCenter      = var.costCenter
  businessUnit    = var.businessUnit
  applicationName = var.applicationName
  applicationCode = var.applicationCode
}

