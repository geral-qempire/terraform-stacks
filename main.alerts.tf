############################################################
# Golden signal alerts
############################################################

locals {
  golden_signal_email_receivers = {
    for alias, email in var.golden_signal_alert_emails :
    alias => { email_address = email }
  }

  golden_signal_has_email_receivers = length(local.golden_signal_email_receivers) > 0

  golden_signal_alert_toggles = {
    base  = var.enable_base_alerts
    blob  = var.enable_blob_alerts
    file  = var.enable_file_alerts
    queue = var.enable_queue_alerts
  }

  golden_signal_alert_catalog = {
    account_availability = {
      display_name     = "Account availability"
      surface          = "base"
      enabled          = true
      metric_namespace = "Microsoft.Storage/storageAccounts"
      metric_name      = "Availability"
      aggregation      = "Average"
      operator         = "LessThan"
      threshold        = 100
      severity         = 1
      window           = "PT5M"
      frequency        = "PT5M"
      description      = "Alert when storage account availability drops below 100%."
    }

    file_throttling = {
      display_name     = "Throttling (Files)"
      surface          = "file"
      enabled          = true
      metric_namespace = "Microsoft.Storage/storageAccounts/fileServices"
      metric_name      = "Transactions"
      aggregation      = "Total"
      operator         = "GreaterThanOrEqual"
      threshold        = 1
      severity         = 2
      window           = "PT15M"
      frequency        = "PT5M"
      description      = "Triggers on any throttled file share transaction."
      dimensions = [
        {
          name     = "ResponseType"
          operator = "Include"
          values   = ["Throttled"]
        }
      ]
    }

    used_capacity_overall = {
      display_name     = "Used capacity (overall)"
      surface          = "base"
      enabled          = true
      metric_namespace = "Microsoft.Storage/storageAccounts"
      metric_name      = "UsedCapacity"
      aggregation      = "Average"
      operator         = "GreaterThan"
      threshold        = 5.0e14
      severity         = 3
      window           = "PT1H"
      frequency        = "PT1H"
      description      = "Overall account capacity consumption approaching quota."
    }

    blob_capacity = {
      display_name     = "Blob capacity"
      surface          = "blob"
      enabled          = true
      metric_namespace = "Microsoft.Storage/storageAccounts/blobServices"
      metric_name      = "BlobCapacity"
      aggregation      = "Average"
      operator         = "GreaterThan"
      threshold        = 5.0e14
      severity         = 3
      window           = "PT1H"
      frequency        = "PT1H"
      description      = "Blob-only capacity consumption spike."
    }

    egress_spike = {
      display_name     = "Egress spike"
      surface          = "base"
      enabled          = true
      metric_namespace = "Microsoft.Storage/storageAccounts"
      metric_name      = "Egress"
      aggregation      = "Total"
      operator         = "GreaterThan"
      threshold        = 6.0e7
      severity         = 2
      window           = "PT5M"
      frequency        = "PT5M"
      description      = "Detects unusual outbound spikes (cost/exfil)."
    }

    ingress_spike = {
      display_name     = "Ingress spike"
      surface          = "base"
      enabled          = true
      metric_namespace = "Microsoft.Storage/storageAccounts"
      metric_name      = "Ingress"
      aggregation      = "Total"
      operator         = "GreaterThan"
      threshold        = 1.073741824e9
      severity         = 3
      window           = "PT5M"
      frequency        = "PT5M"
      description      = "Detects large ingest spikes."
    }

    blob_e2e_latency = {
      display_name     = "Blob Success E2E latency"
      surface          = "blob"
      enabled          = true
      metric_namespace = "Microsoft.Storage/storageAccounts/blobServices"
      metric_name      = "SuccessE2ELatency"
      aggregation      = "Average"
      operator         = "GreaterThan"
      threshold        = 1000
      severity         = 3
      window           = "PT5M"
      frequency        = "PT1M"
      description      = "Elevated end-to-end latency for successful blob operations."
    }

    blob_server_latency = {
      display_name     = "Blob Success server latency"
      surface          = "blob"
      enabled          = true
      metric_namespace = "Microsoft.Storage/storageAccounts/blobServices"
      metric_name      = "SuccessServerLatency"
      aggregation      = "Average"
      operator         = "GreaterThan"
      threshold        = 1000
      severity         = 2
      window           = "PT5M"
      frequency        = "PT1M"
      description      = "Backend processing latency for blob requests."
    }

    file_availability = {
      display_name     = "Files availability"
      surface          = "file"
      enabled          = true
      metric_namespace = "Microsoft.Storage/storageAccounts/fileServices"
      metric_name      = "Availability"
      aggregation      = "Average"
      operator         = "LessThanOrEqual"
      threshold        = 99.9
      severity         = 3
      window           = "PT5M"
      frequency        = "PT1M"
      description      = "File service availability degradation."
    }

    file_capacity = {
      display_name     = "File capacity"
      surface          = "file"
      enabled          = true
      metric_namespace = "Microsoft.Storage/storageAccounts/fileServices"
      metric_name      = "FileCapacity"
      aggregation      = "Average"
      operator         = "GreaterThan"
      threshold        = 8.796093022208e13
      severity         = 3
      window           = "PT1H"
      frequency        = "PT15M"
      description      = "Capacity used by Azure Files approaching limit."
    }

    file_share_capacity_quota = {
      display_name     = "File share capacity quota"
      surface          = "file"
      enabled          = true
      metric_namespace = "Microsoft.Storage/storageAccounts/fileServices"
      metric_name      = "FileShareCapacityQuota"
      aggregation      = "Average"
      operator         = "GreaterThan"
      threshold        = 5.222680231936e12
      severity         = 4
      window           = "PT1H"
      frequency        = "PT5M"
      description      = "File share quota early warning."
    }

    file_share_snapshot_count = {
      display_name     = "File share snapshot count"
      surface          = "file"
      enabled          = true
      metric_namespace = "Microsoft.Storage/storageAccounts/fileServices"
      metric_name      = "FileShareSnapshotCount"
      aggregation      = "Average"
      operator         = "GreaterThan"
      threshold        = 190
      severity         = 3
      window           = "PT1H"
      frequency        = "PT15M"
      description      = "Large file snapshot counts (space/management risk)."
    }

    file_share_count = {
      display_name     = "File share count"
      surface          = "file"
      enabled          = true
      metric_namespace = "Microsoft.Storage/storageAccounts/fileServices"
      metric_name      = "FileShareCount"
      aggregation      = "Average"
      operator         = "GreaterThan"
      threshold        = 0
      severity         = 3
      window           = "PT1H"
      frequency        = "PT1H"
      description      = "Governance check – any file shares exist."
    }

    file_transactions_anonymous = {
      display_name     = "File transactions (anonymous success)"
      surface          = "file"
      enabled          = true
      metric_namespace = "Microsoft.Storage/storageAccounts/fileServices"
      metric_name      = "Transactions"
      aggregation      = "Total"
      operator         = "GreaterThan"
      threshold        = 10
      severity         = 3
      window           = "PT5M"
      frequency        = "PT1M"
      description      = "Anonymous success transactions pattern detection for Files."
      dimensions = [
        {
          name     = "Authentication"
          operator = "Include"
          values   = ["Anonymous"]
        },
        {
          name     = "ResponseType"
          operator = "Include"
          values   = ["Success"]
        }
      ]
    }

    queue_count = {
      display_name     = "Queue count"
      surface          = "queue"
      enabled          = true
      metric_namespace = "Microsoft.Storage/storageAccounts/queueServices"
      metric_name      = "QueueCount"
      aggregation      = "Average"
      operator         = "GreaterThan"
      threshold        = 0
      severity         = 0
      window           = "PT1H"
      frequency        = "PT1H"
      description      = "Governance check – any queues exist."
    }

    queue_capacity = {
      display_name     = "Queue capacity"
      surface          = "queue"
      enabled          = true
      metric_namespace = "Microsoft.Storage/storageAccounts/queueServices"
      metric_name      = "QueueCapacity"
      aggregation      = "Average"
      operator         = "GreaterThan"
      threshold        = 3.145728e7
      severity         = 4
      window           = "PT1H"
      frequency        = "PT5M"
      description      = "Queue storage consumption approaching limit."
    }

    queue_message_backlog = {
      display_name     = "Queue message backlog"
      surface          = "queue"
      enabled          = true
      metric_namespace = "Microsoft.Storage/storageAccounts/queueServices"
      metric_name      = "QueueMessageCount"
      aggregation      = "Average"
      operator         = "GreaterThan"
      threshold        = 1000
      severity         = 3
      window           = "PT1H"
      frequency        = "PT5M"
      description      = "Backlog indicator – messages piling up in queues."
    }
  }

  golden_signal_alert_effective = {
    for key, alert in local.golden_signal_alert_catalog :
    key => merge(alert, {
      enabled   = coalesce(try(var.golden_signal_alert_overrides[key].enabled, null), alert.enabled)
      severity  = coalesce(try(var.golden_signal_alert_overrides[key].severity, null), alert.severity)
      threshold = coalesce(try(var.golden_signal_alert_overrides[key].threshold, null), alert.threshold)
    })
  }

  golden_signal_alerts_enabled = {
    for key, alert in local.golden_signal_alert_effective :
    key => alert
    if alert.enabled && (
      # Include if there's an override entry (user explicitly wants this alert)
      contains(keys(var.golden_signal_alert_overrides), key) ||
      # Or if the surface toggle is on
      lookup(local.golden_signal_alert_toggles, alert.surface, false)
    )
  }
}

locals {
  storage_account_metric_scopes = {
    base  = module.storage_account.storage_account_id
    blob  = "${module.storage_account.storage_account_id}/blobServices/default"
    file  = "${module.storage_account.storage_account_id}/fileServices/default"
    queue = "${module.storage_account.storage_account_id}/queueServices/default"
  }
}

module "golden_signal_action_group_name" {
  count          = local.golden_signal_has_email_receivers ? 1 : 0
  source         = "git::https://github.com/geral-qempire/terraform-modules.git?ref=modules/az_name_generator/v1.0.0"
  resource_type  = "ag"
  location       = var.location
  project_name   = var.project_name
  environment    = var.environment
  org_code       = var.org_code
  random_postfix = var.name_random_postfix
  merged         = true
}

module "golden_signal_action_group" {
  count  = local.golden_signal_has_email_receivers ? 1 : 0
  source = "git::https://github.com/geral-qempire/terraform-modules.git?ref=modules/az_action_group_map/v1.0.0"

  name               = module.golden_signal_action_group_name[0].name
  resource_group_name = var.resource_group_name
  enabled            = true
  email_receivers    = local.golden_signal_email_receivers
  tags               = local.base_tags
}

locals {
  golden_signal_action_group_ids = distinct(concat(
    var.golden_signal_action_group_ids,
    local.golden_signal_has_email_receivers ? [module.golden_signal_action_group[0].action_group_id] : []
  ))
}

resource "azurerm_monitor_metric_alert" "golden_signal" {
  for_each            = local.golden_signal_alerts_enabled
  name                = "alrt-${replace(each.key, "_", "-")}-${module.storage_account_name.name}"
  resource_group_name = var.resource_group_name
  scopes = [
    lookup(local.storage_account_metric_scopes, each.value.surface, module.storage_account.storage_account_id)
  ]
  description         = each.value.description
  severity            = each.value.severity
  enabled             = true
  auto_mitigate       = false
  tags                = local.base_tags

  frequency   = each.value.frequency
  window_size = each.value.window

  criteria {
    metric_namespace = each.value.metric_namespace
    metric_name      = each.value.metric_name
    aggregation      = each.value.aggregation
    operator         = each.value.operator
    threshold        = each.value.threshold

    dynamic "dimension" {
      for_each = try(each.value.dimensions, [])
      content {
        name     = dimension.value.name
        operator = dimension.value.operator
        values   = dimension.value.values
      }
    }
  }

  dynamic "action" {
    for_each = local.golden_signal_action_group_ids
    content {
      action_group_id = action.value
    }
  }
}

locals {
  golden_signal_alert_outputs = {
    for key, alert in azurerm_monitor_metric_alert.golden_signal :
    key => {
      id        = alert.id
      name      = alert.name
      severity  = local.golden_signal_alerts_enabled[key].severity
      threshold = local.golden_signal_alerts_enabled[key].threshold
    }
  }

  golden_signal_primary_action_group_id = local.golden_signal_has_email_receivers ? module.golden_signal_action_group[0].action_group_id : null
}


