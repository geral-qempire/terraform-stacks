############################################################
# Core context
############################################################

project_name        = "example"
environment         = "stg"         # TODO: dev/qua/prd short code
location            = "northeurope" # TODO: Azure region
name_random_postfix = false

infra_subscription_id = "ce21458b-fafa-4f85-999c-9b3734b235b3" # TODO: subscription that will host the resource group

############################################################
# Tagging
############################################################

cost_center      = "DA - 1000"    # TODO: cost center tag
business_unit    = "DA - 110"   # TODO: business unit tag
application_name = "example" # TODO: application name tag
application_code = "EXAMPLE"       # TODO: application code tag
additional_tags  = {}

############################################################
# RBAC principals
############################################################

write_access_principals = []

read_access_principals = []

alert_access_principals = []


