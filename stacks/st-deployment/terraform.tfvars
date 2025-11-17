########################################
# Core Configuration
########################################

# Subscription IDs
infra_subscription_id = "2a4f4e29-3789-4e47-867d-62a6eb17950b"
dns_subscription_id   = "0d2447a1-c993-432b-be88-01ba39e66f84"

# Core 
resource_group_name = "rg-ne-sta-tiers-dev"
service_prefix      = "sta-deployment"
location            = "northeurope"
environment         = "dev"

# Network (for private endpoints)
subnet_name              = "snet-dev"
vnet_name                = "vnet-sdc-genai"
vnet_resource_group_name = "rg-sdc-genai-networking"
dns_resource_group_name  = "rg-swc-dns"

########################################
# Tags
########################################

costCenter      = "41000 - DDA"
businessUnit    = "41400 - DDA-DATA SCIENCE"
applicationName = "MAAIF"
applicationCode = "CA1148"

########################################
# Tier Selection
########################################

parameter_tier = "custom"
parameter_tier_custom = {
  account_tier                      = "Standard"
  account_replication_type          = "RAGZRS"
  account_kind                      = "StorageV2"
  access_tier                       = "Cool"
  public_network_access_enabled     = false
  shared_access_key_enabled         = false
  infrastructure_encryption_enabled = true
  min_tls_version                   = "TLS1_2"
  network_rules_default_action      = "Deny"
  network_rules_bypass              = ["AzureServices"]
  blob_delete_retention_days        = 21
  container_delete_retention_days   = 21
}

versioning_tier = "custom"
versioning_tier_custom = {
  versioning_enabled                            = true
  rule_name                                     = "versioning-retain-90d"
  delete_after_days_since_creation              = 90
  change_tier_to_cool_after_days_since_creation = 45
  filters_blob_types                            = ["blockBlob"]
  filters_prefix_match                          = ["critical/", "reports/"]
}

lifecycle_tier = "custom"
lifecycle_tier_custom = {
  last_access_time_enabled                  = true
  rule_name                                 = "lifecycle-hot-cool-archive"
  auto_tier_to_hot_from_cool_enabled        = true
  tier_to_cool_after_days_since_last_access = 60
  delete_after_days_since_last_access       = 730
  filters_blob_types                        = ["blockBlob"]
  filters_prefix_match                      = ["archive/"]
}

########################################
# Private Endpoint Configuration
########################################

enable_private_endpoint_blob  = true
enable_private_endpoint_file  = false
enable_private_endpoint_queue = false
enable_private_endpoint_table = false
enable_private_endpoint_dfs   = false


########################################
# RBAC Principals
########################################

write_access_principals = [
  {
    name = "diogoazevedo15_gmail.com#EXT#@diogoazevedo15gmail.onmicrosoft.com"
    type = "User"
  },
  {
    name = "GenAI - Full"
    type = "Group"
  },
  {
    name = "sp-genai-app"
    type = "ServicePrincipal"
  }
]

# read_access_principals = [
#   {
#     name = "GenAI - Read"
#     type = "Group"
#   }
# ]

alert_access_principals = [
  {
    name = "GenAI - Read"
    type = "Group"
  }
]


########################################
# Alerts
########################################

enable_availability_alert              = true
enable_success_server_latency_alert    = true
enable_used_capacity_alert             = true
availability_alert_severity            = 1
availability_alert_threshold           = 0
success_server_latency_alert_severity  = 2
success_server_latency_alert_threshold = 0
used_capacity_alert_severity           = 3
used_capacity_alert_threshold          = 0

# Action Group
action_group_enabled = true
action_group_emails  = ["diogoazevedo15@gmail.com"]

# Identity Configuration
identity = {
  type         = "SystemAssigned"
  identity_ids = []
}

