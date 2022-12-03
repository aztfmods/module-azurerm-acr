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

module "kv" {
  source = "github.com/aztfmods/module-azurerm-kv"

  naming = {
    company = local.naming.company
    env     = local.naming.env
    region  = local.naming.region
  }

  vaults = {
    demo = {
      location      = module.global.groups.acr.location
      resourcegroup = module.global.groups.acr.name
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

  naming = {
    company = local.naming.company
    env     = local.naming.env
    region  = local.naming.region
  }

  registry = {
    demo = {
      location            = module.global.groups.acr.location
      resourcegroup       = module.global.groups.acr.name
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