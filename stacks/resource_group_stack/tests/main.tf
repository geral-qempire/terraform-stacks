module "stacks_resource_group_stack" {
  source = "../"

  project_name         = var.project_name
  environment          = var.environment
  location             = var.location
  name_random_postfix  = var.name_random_postfix
  infra_subscription_id = var.infra_subscription_id
  cost_center          = var.cost_center
  business_unit        = var.business_unit
  application_name     = var.application_name
  application_code     = var.application_code
  additional_tags      = var.additional_tags
  write_access_principals = var.write_access_principals
  read_access_principals  = var.read_access_principals
  alert_access_principals = var.alert_access_principals
}
