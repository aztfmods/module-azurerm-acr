![example workflow](https://github.com/aztfmods/module-azurerm-acr/actions/workflows/validate.yml/badge.svg)

# Container registry

Terraform module which creates container registry resources on Azure.

The below features are made available:

- [multiple](examples/multiple/main.tf) container registries
- [replication](examples/replications/main.tf) support on each registry
- [encryption](examples/encryption/main.tf) support
- [terratest](https://terratest.gruntwork.io) is used to validate different integrations

The below examples shows the usage when consuming the module:

## Usage: simple

```hcl
module "acr" {
  source = "github.com/aztfmods/module-azurerm-acr"

  company = module.global.company
  env     = module.global.env
  region  = module.global.region

  registry = {
    demo = {
      location      = module.global.groups.demo.location
      resourcegroup = module.global.groups.demo.name
      sku           = "Premium"
    }
  }
  depends_on = [module.global]
}
```

## Usage: replications

```hcl
module "acr" {
  source = "github.com/aztfmods/module-azurerm-acr"

  company = module.global.company
  env     = module.global.env
  region  = module.global.region

  registry = {
    demo = {
      location          = module.global.groups.demo.location
      resourcegroup     = module.global.groups.demo.name
      sku               = "Premium"
      retention_in_days = 90

      replications = {
        sea  = { location = "southeastasia", enable_zone_redundancy = false }
        eus2 = { location = "eastus2", enable_zone_redundancy = false, regional_endpoint_enabled = true }
      }
    }
  }
  depends_on = [module.global]
}
```

## Resources

| Name | Type |
| :-- | :-- |
| [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [random_string](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azurerm_container_registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) | resource |
| [azurerm_user_assigned_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |

## Data Sources

| Name | Type |
| :-- | :-- |
| [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/1.39.0/docs/data-sources/resource_group) | datasource |
| [azurerm_client_config](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | datasource |


## Inputs

| Name | Description | Type | Required |
| :-- | :-- | :-- | :-- |
| `registry` | describes container registry related configuration | object | yes |
| `company` | contains the company name used, for naming convention	| string | yes |
| `region` | contains the shortname of the region, used for naming convention	| string | yes |
| `env` | contains shortname of the environment used for naming convention	| string | yes |

## Outputs

| Name | Description |
| :-- | :-- |
| `acr` | contains all container registry config |
| `merged_ids` | contains all container registry resource id's |
| `mi` | contains all user managed identity config |

## Authors

Module is maintained by [Dennis Kool](https://github.com/dkooll) with help from [these awesome contributors](https://github.com/aztfmods/module-azurerm-acr/graphs/contributors).

## License

MIT Licensed. See [LICENSE](https://github.com/aztfmods/module-azurerm-acr/blob/main/LICENSE) for full details.
