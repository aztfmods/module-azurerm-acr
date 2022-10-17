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

module "logging" {
  source = "github.com/aztfmods/module-azurerm-law"

  naming = {
    company = local.naming.company
    env     = local.naming.env
    region  = local.naming.region
  }

  laws = {
    diags = {
      location      = module.global.groups.acr.location
      resourcegroup = module.global.groups.acr.name
      sku           = "PerGB2018"
      retention     = 30
    }
  }
  depends_on = [module.global]
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
      location      = module.global.groups.acr.location
      resourcegroup = module.global.groups.acr.name
      sku           = "Premium"
    }
  }
  depends_on = [module.global]
}

module "diagnostic_settings" {
  source = "github.com/aztfmods/module-azurerm-diags"
  count  = length(module.acr.merged_ids)

  resource_id           = element(module.acr.merged_ids, count.index)
  logs_destinations_ids = [lookup(module.logging.laws.diags, "id", null)]
}