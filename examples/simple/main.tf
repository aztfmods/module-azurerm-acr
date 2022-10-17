provider "azurerm" {
  features {}
}

locals {
  naming = {
    company = "cn"
    env     = "p"
    region  = "weu"
  }
}

module "global" {
  source = "github.com/aztfmods/module-azurerm-global"
  rgs = {
    acr = {
      name     = "rg-${local.naming.company}-acr-${local.naming.env}-${local.naming.region}"
      location = "westeurope"
    }
  }
}

module "acr" {
  source = "../../"

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

      enable = {
        trust_policy     = true
        retention_policy = true
        admin            = true
      }

      replications = {
        sea  = { location = "southeastasia", enable_zone_redundancy = false }
        eus2 = { location = "eastus2", enable_zone_redundancy = false, regional_endpoint_enabled = true }
      }
    }
  }
  depends_on = [module.global]
}