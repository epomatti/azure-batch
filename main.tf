terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # TODO: Upgrade when 3.86 issue is fixed
      version = "3.85.0"
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

module "keyvault" {
  source   = "./modules/keyvault"
  sys      = var.sys
  location = azurerm_resource_group.main.location
  group    = azurerm_resource_group.main.name
}

module "storage" {
  source   = "./modules/storage"
  sys      = var.sys
  location = azurerm_resource_group.main.location
  group    = azurerm_resource_group.main.name

  keyvault_id                 = module.keyvault.id
  keyvault_autostorage_key_id = module.keyvault.autostorage_key_id
  keyvault_jobfiles_key_id    = module.keyvault.storagefiles_key_id
}

module "monitor" {
  source   = "./modules/monitor"
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

  keyvault_id        = module.keyvault.id
  cmk_versionless_id = module.keyvault.batch_cmk_versionless_id

  network_account_access         = var.network_account_access
  network_node_management_access = var.network_account_access
  batch_allow_ip                 = var.batch_allow_ip
}

module "batch_pool" {
  source                           = "./modules/batch/pool"
  count                            = var.provision_batch_pool ? 1 : 0
  sys                              = var.sys
  location                         = azurerm_resource_group.main.location
  group                            = azurerm_resource_group.main.name
  batch_account_name               = module.batch_account.batch_account_name
  batch_subnet_id                  = module.network.batch_subnet_id
  batch_vm_size                    = var.batch_vm_size
  storage_jobfiles_id              = module.storage.jobfiles_storage_id
  jobfiles_storage_name            = module.storage.jobfiles_storage_name
  public_address_provisioning_type = var.public_address_provisioning_type
  jobfiles_storage_account_key     = module.storage.account_key
  share_url                        = module.storage.share_url
}

module "privatelink" {
  count            = var.provision_private_link == true ? 1 : 0
  source           = "./modules/privatelink"
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
  jumpbox_size     = var.jumpbox_linux_vm_size
  jumpbox_subnet   = module.network.jumpbox_subnet_id
  batch_account_id = module.batch_account.batch_account_id
}

module "vm_win" {
  source         = "./modules/vm/win"
  count          = var.provision_win_vm ? 1 : 0
  sys            = var.sys
  location       = azurerm_resource_group.main.location
  group          = azurerm_resource_group.main.name
  jumpbox_size   = var.jumpbox_win_vm_size
  jumpbox_subnet = module.network.jumpbox_subnet_id
}

module "entra" {
  source            = "./modules/entra"
  resource_group_id = azurerm_resource_group.main.id
  batch_account_id  = module.batch_account.batch_account_id
  tenant_domain     = var.tenant_domain
}
