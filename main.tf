terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.46.0"
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

### Group ###

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.sys}"
  location = var.location
}


### Network ###

resource "azurerm_network_security_group" "main" {
  name                = "nsg-${var.sys}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_network_security_rule" "internet" {
  name                        = "rule-internet"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.sys}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = "batch-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}


### Storage ###

resource "azurerm_storage_account" "main" {
  name                     = "st${var.sys}789"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

### Batch ###

resource "azurerm_batch_account" "main" {
  name                = "ba${var.sys}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  storage_account_id                  = azurerm_storage_account.main.id
  storage_account_authentication_mode = "BatchAccountManagedIdentity"

  pool_allocation_mode = "BatchService"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "batch" {
  scope                = azurerm_storage_account.main.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_batch_account.main.identity[0].principal_id
}

resource "azurerm_batch_application" "main" {
  name                = "molecularanalysis"
  display_name        = "Molecular Analysis"
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_batch_account.main.name
  allow_updates       = true

  lifecycle {
    ignore_changes = [
      default_version
    ]
  }

  depends_on = [
    azurerm_role_assignment.batch
  ]
}

resource "azurerm_user_assigned_identity" "main" {
  name                = "batch-pool-user"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_batch_pool" "dev" {
  name                = "dev"
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_batch_account.main.name
  display_name        = "dev"
  vm_size             = "STANDARD_DS2_V2"
  node_agent_sku_id   = "batch.node.ubuntu 22.04"
  max_tasks_per_node  = 1

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.main.id]
  }

  storage_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "22.04.202302280"
  }

  data_disks {
    lun                  = 0
    caching              = "None"
    disk_size_gb         = 10
    storage_account_type = "Premium_LRS"
  }

  fixed_scale {
    node_deallocation_method  = "TaskCompletion"
    target_dedicated_nodes    = 1
    target_low_priority_nodes = 0
  }

  start_task {
    command_line       = "bash run.sh"
    wait_for_success   = true
    task_retry_maximum = 1
    common_environment_properties = {
      env = "TEST"
    }

    user_identity {
      auto_user {
        elevation_level = "NonAdmin"
        scope           = "Task"
      }
    }
  }
}

resource "azurerm_batch_job" "dev" {
  name               = "dev-job"
  batch_pool_id      = azurerm_batch_pool.dev.id
  task_retry_maximum = 1
}
