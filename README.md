![example workflow](https://github.com/aztfmods/module-azurerm-acr/actions/workflows/validate.yml/badge.svg)

# Container registry

Terraform module which creates container registry resources on Azure.

The below features are made available:

- multiple container registries
- [replication](#usage-replications) support on each registry
- [terratest](https://terratest.gruntwork.io) is used to validate different integrations

The below examples shows the usage when consuming the module:

## Usage: single

```hcl
module "acr" {
  source = "github.com/aztfmods/module-azurerm-acr"

  naming = {
    company = local.naming.company
    env     = local.naming.env
    region  = local.naming.region
  }

  registry = {
    demo = {
      location      = module.global.groups.acr.location
      resourcegroup = module.global.groups.acr.name
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

  naming = {
    company = local.naming.company
    env     = local.naming.env
    region  = local.naming.region
  }

  registry = {
    demo = {
      location          = module.global.groups.acr.location
      resourcegroup     = module.global.groups.acr.name
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

## Data Sources

| Name | Type |
| :-- | :-- |
| [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/1.39.0/docs/data-sources/resource_group) | datasource |

## Inputs

| Name | Description | Type | Required |
| :-- | :-- | :-- | :-- |
| `registry` | describes container registry related configuration | object | yes |
| `naming` | contains naming convention | string | yes |

## Outputs

| Name | Description |
| :-- | :-- |
| `acr` | contains all container registry config |
| `merged_ids` | contains all container registry resource id's specified within the module|

## Local development

To test modules on your local machine, first make sure you are authenticated to your subscription  
using [azure cli](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli).

Install [terraform](https://developer.hashicorp.com/terraform/downloads) locally, and go to a working directoy in the [examples](examples) folder  
in your terminal. Perform a terraform init and apply.

## Authors

Module is maintained by [Dennis Kool](https://github.com/dkooll) with help from [these awesome contributors](https://github.com/aztfmods/module-azurerm-acr/graphs/contributors).

## License

MIT Licensed. See [LICENSE](https://github.com/aztfmods/module-azurerm-acr/blob/main/LICENSE) for full details.