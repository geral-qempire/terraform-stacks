############################################################
# Core context
############################################################

project_name        = "rg-stack"
environment         = "rel"         # TODO: dev/qua/prd short code
location            = "northeurope" # TODO: Azure region
name_random_postfix = false

infra_subscription_id = "2a4f4e29-3789-4e47-867d-62a6eb17950b" # TODO: subscription that will host the resource group

############################################################
# Tagging
############################################################

cost_center      = "DA - 100"    # TODO: cost center tag
business_unit    = "DA - 110"   # TODO: business unit tag
application_name = "rg-stack" # TODO: application name tag
application_code = "DLK"       # TODO: application code tag
additional_tags  = {}

############################################################
# RBAC principals
############################################################

write_access_principals = []

read_access_principals = []

alert_access_principals = []


