############################################
# Name of subnets and region_abbreviation
############################################

locals {
  ########################################
  # Parameter Tiers (account + networking)
  ########################################
  parameter_tiers = {
    bronze = {
      account_tier                      = "Standard"
      account_replication_type          = "LRS"
      account_kind                      = "StorageV2"
      access_tier                       = "Hot"
      public_network_access_enabled     = false
      shared_access_key_enabled         = true
      infrastructure_encryption_enabled = false
      min_tls_version                   = "TLS1_2"
      network_rules_default_action      = "Deny"
      network_rules_bypass              = ["AzureServices"]
      blob_delete_retention_days        = 7
      container_delete_retention_days   = 7
    }

    silver = {
      account_tier                      = "Standard"
      account_replication_type          = "ZRS"
      account_kind                      = "StorageV2"
      access_tier                       = "Hot"
      public_network_access_enabled     = false
      shared_access_key_enabled         = true
      infrastructure_encryption_enabled = false
      min_tls_version                   = "TLS1_2"
      network_rules_default_action      = "Deny"
      network_rules_bypass              = ["AzureServices"]
      blob_delete_retention_days        = 30
      container_delete_retention_days   = 30
    }
  }

  custom_parameter_tier = var.parameter_tier_custom != null ? merge(
    local.parameter_tiers.bronze,
    var.parameter_tier_custom
  ) : null

  all_parameter_tiers = merge(
    local.parameter_tiers,
    local.custom_parameter_tier != null ? { custom = local.custom_parameter_tier } : {}
  )

  selected_parameter_tier = lookup(local.all_parameter_tiers, var.parameter_tier, local.parameter_tiers.bronze)

  ########################################
  # Versioning Tiers (blob version retention)
  ########################################
  versioning_tiers = {
    bronze = {
      versioning_enabled                            = false
      rule_name                                     = null
      delete_after_days_since_creation              = null
      change_tier_to_cool_after_days_since_creation = null
      filters_blob_types                            = ["blockBlob"]
      filters_prefix_match                          = []
    }

    silver = {
      versioning_enabled                            = true
      rule_name                                     = "versioning-retain-14d"
      delete_after_days_since_creation              = 14
      change_tier_to_cool_after_days_since_creation = null
      filters_blob_types                            = ["blockBlob"]
      filters_prefix_match                          = []
    }

    gold = {
      versioning_enabled                            = true
      rule_name                                     = "versioning-retain-60d"
      delete_after_days_since_creation              = 60
      change_tier_to_cool_after_days_since_creation = 30
      filters_blob_types                            = ["blockBlob"]
      filters_prefix_match                          = []
    }
  }

  custom_versioning_tier = var.versioning_tier_custom != null ? merge(
    local.versioning_tiers.bronze,
    var.versioning_tier_custom
  ) : null

  all_versioning_tiers = merge(
    local.versioning_tiers,
    local.custom_versioning_tier != null ? { custom = local.custom_versioning_tier } : {}
  )

  selected_versioning_tier = lookup(local.all_versioning_tiers, var.versioning_tier, local.versioning_tiers.bronze)

  versioning_version_actions = merge(
    local.selected_versioning_tier.delete_after_days_since_creation != null ? {
      delete_after_days_since_creation = local.selected_versioning_tier.delete_after_days_since_creation
    } : {},
    local.selected_versioning_tier.change_tier_to_cool_after_days_since_creation != null ? {
      change_tier_to_cool_after_days_since_creation = local.selected_versioning_tier.change_tier_to_cool_after_days_since_creation
    } : {}
  )

  versioning_management_policy_rule = (
    local.selected_versioning_tier.versioning_enabled &&
    length(local.versioning_version_actions) > 0
    ) ? {
    name = coalesce(local.selected_versioning_tier.rule_name, "versioning-retention")
    filters = {
      blob_types   = coalesce(local.selected_versioning_tier.filters_blob_types, ["blockBlob"])
      prefix_match = coalesce(local.selected_versioning_tier.filters_prefix_match, [])
    }
    actions = {
      version = local.versioning_version_actions
    }
  } : null

  ########################################
  # Lifecycle Tiers (data temperature + retention)
  ########################################
  lifecycle_tiers = {
    bronze = {
      last_access_time_enabled                  = false
      rule_name                                 = null
      auto_tier_to_hot_from_cool_enabled        = null
      tier_to_cool_after_days_since_last_access = null
      delete_after_days_since_last_access       = null
      filters_blob_types                        = ["blockBlob"]
      filters_prefix_match                      = []
    }

    silver = {
      last_access_time_enabled                  = true
      rule_name                                 = "lifecycle-hot-cool-delete"
      auto_tier_to_hot_from_cool_enabled        = true
      tier_to_cool_after_days_since_last_access = 90
      delete_after_days_since_last_access       = 365
      filters_blob_types                        = ["blockBlob"]
      filters_prefix_match                      = []
    }
  }

  custom_lifecycle_tier = var.lifecycle_tier_custom != null ? merge(
    local.lifecycle_tiers.bronze,
    var.lifecycle_tier_custom
  ) : null

  all_lifecycle_tiers = merge(
    local.lifecycle_tiers,
    local.custom_lifecycle_tier != null ? { custom = local.custom_lifecycle_tier } : {}
  )

  selected_lifecycle_tier = lookup(local.all_lifecycle_tiers, var.lifecycle_tier, local.lifecycle_tiers.bronze)

  lifecycle_base_blob_actions = merge(
    local.selected_lifecycle_tier.auto_tier_to_hot_from_cool_enabled != null ? {
      auto_tier_to_hot_from_cool_enabled = local.selected_lifecycle_tier.auto_tier_to_hot_from_cool_enabled
    } : {},
    local.selected_lifecycle_tier.tier_to_cool_after_days_since_last_access != null ? {
      tier_to_cool_after_days_since_last_access_time_greater_than = local.selected_lifecycle_tier.tier_to_cool_after_days_since_last_access
    } : {},
    local.selected_lifecycle_tier.delete_after_days_since_last_access != null ? {
      delete_after_days_since_last_access_time_greater_than = local.selected_lifecycle_tier.delete_after_days_since_last_access
    } : {}
  )

  lifecycle_management_policy_rule = length(local.lifecycle_base_blob_actions) > 0 ? {
    name = coalesce(local.selected_lifecycle_tier.rule_name, "lifecycle-default")
    filters = {
      blob_types   = coalesce(local.selected_lifecycle_tier.filters_blob_types, ["blockBlob"])
      prefix_match = coalesce(local.selected_lifecycle_tier.filters_prefix_match, [])
    }
    actions = {
      base_blob = local.lifecycle_base_blob_actions
    }
  } : null

  management_policy_rules = [
    for rule in [local.versioning_management_policy_rule, local.lifecycle_management_policy_rule] : rule
    if rule != null
  ]

  ########################################
  # Action Group Receivers
  ########################################
  action_group_receivers = length(var.action_group_emails) > 0 ? {
    for idx, addr in var.action_group_emails : format("email%02d", idx + 1) => { email_address = addr }
  } : {}
}

