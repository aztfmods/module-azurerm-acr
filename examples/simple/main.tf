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
    demo = {
      location            = module.global.groups.demo.location
      resourcegroup       = module.global.groups.demo.name
      sku                 = "Premium"
      retention_in_days   = 90
      network_rule_bypass = "None"

      enable = {
        trust_policy          = true
        retention_policy      = true
        admin                 = true
        export_policy         = true
        public_network_access = true
      }
    }
  }
  depends_on = [module.global]
}