############################################################
# Shared locals
############################################################

locals {

  base_tags = merge({
    environment     = upper(var.environment)
    costCenter      = upper(var.cost_center)
    businessUnit    = upper(var.business_unit)
    applicationName = upper(var.application_name)
    applicationCode = upper(var.application_code)
  }, var.additional_tags)

  ############################################################
  # Storage tiers
  ############################################################
  
  storage_tier_baseline = {
    defaults = {
      account_tier                      = "Standard"
      account_kind                      = "StorageV2"
      access_tier                       = "Hot"
      min_tls_version                   = "TLS1_2"
      shared_access_key_enabled         = false
      infrastructure_encryption_enabled = false
      network_rules_bypass              = var.network_rules_bypass
    }
    bronze = {
      account_replication_type        = "LRS"
      blob_delete_retention_days      = 7
      container_delete_retention_days = 7
      enable_geo_priority_replication = false
    }
    silver = {
      account_replication_type        = "ZRS"
      blob_delete_retention_days      = 30
      container_delete_retention_days = 30
      enable_geo_priority_replication = false
    }
    gold = {
      account_replication_type        = "GZRS"
      blob_delete_retention_days      = 30
      container_delete_retention_days = 30
      enable_geo_priority_replication = false
    }
    plat = {
      account_replication_type        = "GZRS"
      blob_delete_retention_days      = 30
      container_delete_retention_days = 30
      enable_geo_priority_replication = true
    }
    diamond = {
      account_replication_type        = "RAGZRS"
      blob_delete_retention_days      = 30
      container_delete_retention_days = 30
      enable_geo_priority_replication = true
    }
  }

  storage_tier_key = var.storage_tier == "override" ? "bronze" : var.storage_tier
  storage_tier_base = merge(
    local.storage_tier_baseline.defaults,
    lookup(local.storage_tier_baseline, local.storage_tier_key, local.storage_tier_baseline.bronze)
  )
  storage_tier_selected = var.storage_tier == "override" && var.storage_tier_override != null ? merge(local.storage_tier_base, var.storage_tier_override) : local.storage_tier_base

  has_allowed_ips               = length(var.allowed_ip_addresses) > 0
  public_network_access_enabled = local.has_allowed_ips
  network_rules_default_action  = "Deny"
  network_rules_ip_rules        = local.has_allowed_ips ? var.allowed_ip_addresses : []

  ############################################################
  # Smart lifecycle tiers
  ############################################################

  lifecycle_prefix_match_safelist = length(var.lifecycle_prefix_match) > 0 ? var.lifecycle_prefix_match : []

  smart_lifecycle_tiers = {
    false = null
    true = {
      hot_to_cool_days = 30
      cool_to_cold_days = 90
    }
  }

  selected_smart_lifecycle = (
    var.smart_lifecycle_tier == "override"
    ? var.smart_lifecycle_override
    : lookup(local.smart_lifecycle_tiers, var.smart_lifecycle_tier, null)
  )

  lifecycle_management_policy_rules = local.selected_smart_lifecycle == null ? [] : [
    {
      name = "smart-lifecycle"
      filters = {
        blob_types   = ["blockBlob"]
        prefix_match = local.lifecycle_prefix_match_safelist
      }
      actions = {
        base_blob = merge(
          {
            auto_tier_to_hot_from_cool_enabled                          = true
            tier_to_cool_after_days_since_last_access_time_greater_than = local.selected_smart_lifecycle.hot_to_cool_days
            tier_to_cold_after_days_since_last_access_time_greater_than  = local.selected_smart_lifecycle.cool_to_cold_days
          },
          try(local.selected_smart_lifecycle.cold_to_archive_days, null) != null ? {
            tier_to_archive_after_days_since_last_access_time_greater_than = local.selected_smart_lifecycle.cold_to_archive_days
          } : {},
          try(local.selected_smart_lifecycle.delete_after_days, null) != null ? {
            delete_after_days_since_last_access_time_greater_than = local.selected_smart_lifecycle.delete_after_days
          } : {}
        )
      }
    }
  ]

  ############################################################
  # Versioning tiers
  ############################################################

  versioning_tier_baseline = {
    defaults = {
      filters_blob_types   = ["blockBlob"]
      filters_prefix_match = []
    }
    bronze = {
      versioning_enabled                            = false
      delete_after_days_since_creation              = null
      change_tier_to_cool_after_days_since_creation = null
      rule_name                                     = null
    }
    silver = {
      versioning_enabled                            = true
      delete_after_days_since_creation              = 14
      change_tier_to_cool_after_days_since_creation = null
      rule_name                                     = "versioning-retain-14d"
    }
    gold = {
      versioning_enabled                            = true
      delete_after_days_since_creation              = 30
      change_tier_to_cool_after_days_since_creation = null
      rule_name                                     = "versioning-retain-30d"
    }
    platinum = {
      versioning_enabled                            = true
      delete_after_days_since_creation              = 60
      change_tier_to_cool_after_days_since_creation = 30
      rule_name                                     = "versioning-retain-60d"
    }
    diamond = {
      versioning_enabled                            = true
      delete_after_days_since_creation              = 90
      change_tier_to_cool_after_days_since_creation = 30
      rule_name                                     = "versioning-retain-90d"
    }
  }

  versioning_tier_key = var.versioning_tier == "override" ? "bronze" : var.versioning_tier
  versioning_tier_base = merge(
    local.versioning_tier_baseline.defaults,
    lookup(local.versioning_tier_baseline, local.versioning_tier_key, local.versioning_tier_baseline.bronze)
  )
  versioning_tier_selected = var.versioning_tier == "override" && var.versioning_tier_override != null ? merge(
    local.versioning_tier_base,
    var.versioning_tier_override
  ) : local.versioning_tier_base

  versioning_version_actions = merge(
    local.versioning_tier_selected.delete_after_days_since_creation != null ? {
      delete_after_days_since_creation = local.versioning_tier_selected.delete_after_days_since_creation
    } : {},
    local.versioning_tier_selected.change_tier_to_cool_after_days_since_creation != null ? {
      change_tier_to_cool_after_days_since_creation = local.versioning_tier_selected.change_tier_to_cool_after_days_since_creation
    } : {}
  )

  versioning_management_policy_rule = (
    local.versioning_tier_selected.versioning_enabled &&
    length(local.versioning_version_actions) > 0
  ) ? {
    name = coalesce(local.versioning_tier_selected.rule_name, "versioning-retention")
    filters = {
      blob_types   = coalesce(local.versioning_tier_selected.filters_blob_types, ["blockBlob"])
      prefix_match = coalesce(local.versioning_tier_selected.filters_prefix_match, [])
    }
    actions = {
      version = local.versioning_version_actions
    }
  } : null

  all_lifecycle_management_policy_rules = concat(
    local.lifecycle_management_policy_rules,
    local.versioning_management_policy_rule != null ? [local.versioning_management_policy_rule] : []
  )
}



