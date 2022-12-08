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

module "kv" {
  source = "github.com/aztfmods/module-azurerm-kv"

  company = module.global.company
  env     = module.global.env
  region  = module.global.region

  vaults = {
    demo = {
      location      = module.global.groups.demo.location
      resourcegroup = module.global.groups.demo.name
      sku           = "standard"

      retention_in_days = 7

      enable = {
        rbac_auth        = true
        purge_protection = true
      }

      keys = {
        acr = {
          key_type = "RSA"
          key_size = 2048
          key_opts = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
        }
      }
    }
  }
  depends_on = [module.global]
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

      role_assignment_scope = module.kv.vaults.demo.id

      encryption = {
        kv_key_id = module.kv.kv_keys["demo.acr"].id
      }

      identity = {
        type = "UserAssigned"
      }
    }
  }
  depends_on = [module.global]
}