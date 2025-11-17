# Storage Account Tiers Stack

This Terraform stack provisions Azure Storage Accounts with opinionated defaults across three capability areas:

- **Parameter tiers**: core account settings such as replication, network posture, and soft-delete windows.
- **Versioning tiers**: blob versioning enablement and version retention rules.
- **Lifecycle tiers**: access-based temperature management and long-term retention for base blobs.

Each capability offers curated Bronze/Silver/Gold defaults (as applicable) and a `custom` escape hatch to override any attribute while reusing the stack’s wiring for networking, RBAC, and alerts.

## Tier Catalogue

### Parameter tiers

| Tier | Intended env | Redundancy | Soft delete (blob / container) | Networking posture | Notes (availability & DR) | Terraform knobs (high-level) |
| --- | --- | --- | --- | --- | --- | --- |
| **Bronze** | Dev | **LRS** (single-region) | **7d / 7d** | Deny-by-default; PE optional | Lowest cost; no zone/geo protection | `account_replication_type = "LRS"` • `delete_retention_policy.days = 7` • `container_delete_retention_policy.days = 7` |
| **Silver** | QA / Prod | **ZRS** | **30d / 30d** | Deny-by-default; **Private Endpoint recommended** | Zone-redundant within the primary region. Use `parameter_tier_custom` for GRS/RA if cross-region DR is required. | `account_replication_type = "ZRS"` • `delete_retention_policy.days = 30` • `container_delete_retention_policy.days = 30` |

### Versioning tiers

| Tier | Versioning | Retention window (versions) | Expected RPO* | Expected RTO | Scope & notes | Terraform knobs |
| --- | --- | --- | --- | --- | --- | --- |
| **Bronze** | **Off** | — | Best-effort (soft-delete only) | N/A to minutes | Protects only deletes via soft delete; no per-write rollback | `blob_properties.versioning_enabled = false` |
| **Silver** | **On** | **14 days** (delete old versions) | *Per-blob:* ≈ **time since last change** (typically minutes) | Minutes (locate + copy/restore) | Good for most apps; lean cost | `versioning_enabled = true` • Management policy: `version { delete_after_days_since_creation_greater_than = 14 }` |
| **Gold** | **On** | **60 days** (Cool @30d, delete @60d) | *Per-blob:* ≈ **time since last change** | Minutes (rehydrate only if Archive used elsewhere) | Longer rollback window; tiers older versions to Cool | `versioning_enabled = true` • Management policy: `version { tier_to_cool_after_days_since_creation_greater_than = 30  delete_after_days_since_creation_greater_than = 60 }` |

### Lifecycle tiers

| Tier | What it does | Prereqs | Policy logic | Terraform knobs (management policy – `base_blob`) |
| --- | --- | --- | --- | --- |
| **Bronze** | No lifecycle (always Hot) | — | — | *No rule* |
| **Silver** | **Hot → Cool → Delete** (access-aware) | `blob_properties.last_access_time_enabled = true` | Cool if **not accessed for 90 days**; **Delete if not accessed for 365 days (1 year)**; auto-promote Cool→Hot on read | `auto_tier_to_hot_from_cool_enabled = true` • `tier_to_cool_after_days_since_last_access_time_greater_than = 90` • `delete_after_days_since_last_access_time_greater_than = 365` |

> **Custom tiers**: set `parameter_tier`, `versioning_tier`, or `lifecycle_tier` to `"custom"` and provide the corresponding `*_custom` object. Unspecified fields inherit the Bronze defaults for that capability.

## Usage

```hcl
module "storage_account_tiers" {
  source = "../../terraform/azure/omni/storage_account_tiers"

  service_prefix      = "omni"
  environment         = "dev"
  location            = "North Europe"
  resource_group_name = "rg-ne-omni-dev"
  infra_subscription_id = "00000000-0000-0000-0000-000000000000" # optional override
  dns_subscription_id   = "11111111-1111-1111-1111-111111111111" # optional override

  # Tier selections
  parameter_tier = "silver"
  versioning_tier = "gold"
  lifecycle_tier  = "silver"

  # Example customisation
  # parameter_tier = "custom"
  # parameter_tier_custom = {
  #   account_replication_type = "RAGZRS"
  # }

  subnet_name                 = "tech-infra-snet"
  vnet_name                   = "tech-dev-vnet"
  vnet_resource_group_name    = "tech-netdev-ne-rg"
  dns_hub_resource_group_name = "rg-ne-dns"
  enable_private_endpoint_blob = true
  enable_private_endpoint_file = false

  write_access_principals = [{
    name = "Engineering Storage Contributors"
    type = "Group"
  }]

  action_group_emails = ["storage-alerts@example.com"]
  alert_action_group_ids = []
  enable_used_capacity_alert = true

  costCenter      = "IT"
  businessUnit    = "Engineering"
  applicationName = "Omni"
  applicationCode = "OMNI"
}
```

## Custom tier overrides

- **Parameter** (`parameter_tier_custom`): replication mode, soft-delete windows, TLS, access tier, network defaults.
- **Versioning** (`versioning_tier_custom`): toggle versioning, retention/tiering days, rule name, and filters.
- **Lifecycle** (`lifecycle_tier_custom`): access tracking, auto-tier toggle, access thresholds, and filters.

Any value omitted in a `*_custom` object inherits the Bronze defaults for that capability.

## Role Profiles

### Write Access Profile (`write_access_principals`)

Principals supplied through `write_access_principals` receive write-level access to every storage data plane surface:

| Role | Description |
| --- | --- |
| **Storage Blob Data Contributor** | Write access to blob containers and blobs |
| **Storage File Data SMB Share Contributor** | Write access to file shares and files |
| **Storage Table Data Contributor** | Write access to table data |
| **Storage Queue Data Contributor** | Write access to queue data |
| **Reader** | Read metadata about the Storage Account |

### Read Access Profile (`read_access_principals`)

Principals supplied through `read_access_principals` receive read-only access to all storage services:

| Role | Description |
| --- | --- |
| **Storage Blob Data Reader** | Read-only access to blob containers and blobs |
| **Storage File Data SMB Share Reader** | Read-only access to file shares and files |
| **Storage Table Data Reader** | Read-only access to table data |
| **Storage Queue Data Reader** | Read-only access to queue data |
| **Reader** | Read metadata about the Storage Account |

### Alert Access Profile (`alert_access_principals`)

Provide principals through `alert_access_principals` to grant the `BDSO Alert Operator` role on any metric alerts that this stack creates.

## File structure

```
storage_account_tiers/
├── main.tf            # Storage account deployment and supporting resources
├── main.rbac.tf       # RBAC profile assignments
├── main.tiers.tf      # Tier configuration locals
├── outputs.tf         # Output values
├── variables.tf       # Input variables
├── providers.tf       # Provider configuration
├── versions.tf        # Terraform and provider constraints
└── README.md          # This file
```

## Key variables

- `infra_subscription_id`, `dns_subscription_id`
- `parameter_tier` / `parameter_tier_custom`
- `versioning_tier` / `versioning_tier_custom`
- `lifecycle_tier` / `lifecycle_tier_custom`
- Networking inputs (`subnet_name`, `vnet_name`, `vnet_resource_group_name`, `dns_hub_resource_group_name`)
- Alert configuration (`action_group_emails`, `alert_action_group_ids`, `enable_*_alert`, thresholds, severities)
- Managed identity (`identity`)
- RBAC principal lists
- Tagging inputs (`costCenter`, `businessUnit`, `applicationName`, `applicationCode`)

Refer to `variables.tf` for full definitions and defaults.

## Outputs

- Storage account identifiers, endpoints, and private endpoint IDs
- Alert resource IDs
- Optional action group identifiers
- Selected tier names (`parameter_tier`, `versioning_tier`, `lifecycle_tier`)
- Resolved tier configuration objects for each capability (`*_tier_config`)

## Notes & dependencies

- Soft delete, versioning, last-access tracking, and lifecycle rules are configured via `azurerm_storage_account_blob_properties` and `azurerm_storage_management_policy`.
- Module dependencies: `az_region_abbreviations_v2`, `az_storage_account_v2`, `az_action_group_map`, and `az_rbac_profile_assignment`.
- Ensure the DNS subscription contains the required Private DNS zones when enabling private endpoints.
- Point the providers at the correct subscriptions with `infra_subscription_id` and `dns_subscription_id` (defaults to the ambient provider if omitted).


test.