provider "azurerm" {
  features {}
}

module "global" {
  source = "github.com/aztfmods/module-azurerm-global"

  company = "cn"
  env     = "p"
  region  = "weu"

  rgs = {
    demo = { location = "westeurope" }
  }
}

module "acr" {
  source = "../../"

  company = module.global.company
  env     = module.global.env
  region  = module.global.region

  registry = {
    acr1 = {
      location      = module.global.groups.demo.location
      resourcegroup = module.global.groups.demo.name
      sku           = "Premium"
    }

    acr2 = {
      location      = module.global.groups.demo.location
      resourcegroup = module.global.groups.demo.name
      sku           = "Premium"
    }
  }
  depends_on = [module.global]
}