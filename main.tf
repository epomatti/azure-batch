terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.sys}"
  location = var.location
}

module "network" {
  source   = "./modules/network"
  sys      = var.sys
  location = azurerm_resource_group.main.location
  group    = azurerm_resource_group.main.name
}

module "storage" {
  source   = "./modules/storage"
  sys      = var.sys
  location = azurerm_resource_group.main.location
  group    = azurerm_resource_group.main.name
}

module "batch_account" {
  source               = "./modules/batch/account"
  sys                  = var.sys
  location             = azurerm_resource_group.main.location
  group                = azurerm_resource_group.main.name
  batch_account_public = var.batch_account_public
  autostorage_id       = module.storage.autostorage_id
}

module "batch_pool" {
  source                = "./modules/batch/pool"
  count                 = var.provision_batch_pool ? 1 : 0
  sys                   = var.sys
  location              = azurerm_resource_group.main.location
  group                 = azurerm_resource_group.main.name
  batch_account_name    = module.batch_account.batch_account_name
  batch_subnet_id       = module.network.batch_subnet_id
  batch_vm_size         = var.batch_vm_size
  storage_jobfiles_id   = module.storage.jobfiles_storage_id
  jobfiles_storage_name = module.storage.jobfiles_storage_name
}

module "privatelink" {
  source           = "./modules/privatelink"
  count            = var.provision_private_link == true ? 1 : 0
  sys              = var.sys
  location         = azurerm_resource_group.main.location
  group            = azurerm_resource_group.main.name
  batch_account_id = module.batch_account.batch_account_id
  vnet_id          = module.network.vnet_id
  subnet_id        = module.network.batch_subnet_id

  provision_batchAccount_private_endpoint   = var.provision_batchAccount_private_endpoint
  provision_nodeManagement_private_endpoint = var.provision_nodeManagement_private_endpoint
}

module "vm_linux" {
  source           = "./modules/vm/linux"
  count            = var.provision_linux_vm ? 1 : 0
  sys              = var.sys
  location         = azurerm_resource_group.main.location
  group            = azurerm_resource_group.main.name
  jumpbox_size     = var.jumpbox_size_linux
  jumpbox_subnet   = module.network.jumpbox_subnet_id
  batch_account_id = module.batch_account.batch_account_id
}

module "vm_win" {
  source         = "./modules/vm/win"
  count          = var.provision_win_vm ? 1 : 0
  sys            = var.sys
  location       = azurerm_resource_group.main.location
  group          = azurerm_resource_group.main.name
  jumpbox_size   = var.jumpbox_size_win
  jumpbox_subnet = module.network.jumpbox_subnet_id
}
