# terraform-stacks

This repository contains Terraform stacks that compose multiple modules to create complete infrastructure solutions.

## File Structure

```
terraform-stacks/
├── .github/
│   └── workflows/
│       └── terraform-module-releaser.yml
├── stacks/
│   └── <stack_name>/
│       ├── main.tf
│       ├── main.*.tf          # Additional resource files (e.g., main.rbac.tf, main.alerts.tf)
│       ├── variables.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── versions.tf
│       ├── locals.tf
│       ├── terraform.tfvars
│       └── tests/             # Optional test directory
│           ├── main.tf
│           ├── variables.tf
│           ├── outputs.tf
│           ├── providers.tf
│           ├── versions.tf
│           ├── backend.tf
│           └── terraform.tfvars
├── .gitignore
├── LICENSE
└── README.md
```

Each stack should be self-contained with:
- `main.tf` - Primary resource definitions
- `main.*.tf` - Additional resource files (e.g., RBAC, alerts, private endpoints)
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `providers.tf` - Provider configuration
- `versions.tf` - Provider and Terraform version constraints
- `locals.tf` - Local values
- `terraform.tfvars` - Example variable values (excluded from releases)
- `tests/` - Optional test directory (excluded from releases)

## Tagged Versions

When a stack is tagged (e.g., `stacks/resource_group_stack/v1.0.0`), the `techpivot/terraform-module-releaser@v1` action places the stack's files in the root of the tag.

**Excluded from tagged releases:**
- `*terraform.tfvars` files
- `**/tests/**` directories and their contents

**Example tag structure:**
```
stacks/resource_group_stack/v1.0.0/
├── main.tf
├── main.rbac.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── versions.tf
└── locals.tf
```

The `tests/` directory and `terraform.tfvars` files are not included in the release.
