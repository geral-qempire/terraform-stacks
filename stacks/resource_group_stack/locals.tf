locals {
  base_tags = merge({
    environment     = upper(var.environment)
    costCenter      = upper(var.cost_center)
    businessUnit    = upper(var.business_unit)
    applicationName = upper(var.application_name)
    applicationCode = upper(var.application_code)
  }, var.additional_tags)

}


