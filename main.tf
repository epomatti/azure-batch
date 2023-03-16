terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.47.0"
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


### Log Analytics Workspace ###
resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${var.sys}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


### Network ###

# resource "azurerm_network_security_group" "main" {
#   name                = "nsg-${var.sys}"
#   location            = azurerm_resource_group.main.location
#   resource_group_name = azurerm_resource_group.main.name
# }

# resource "azurerm_network_security_rule" "internet" {
#   name                        = "rule-internet"
#   priority                    = 100
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   resource_group_name         = azurerm_resource_group.main.name
#   network_security_group_name = azurerm_network_security_group.main.name
# }

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

# resource "azurerm_subnet_network_security_group_association" "main" {
#   subnet_id                 = azurerm_subnet.main.id
#   network_security_group_id = azurerm_network_security_group.main.id
# }

# Jumpbox
resource "azurerm_network_security_group" "jumpbox" {
  name                = "nsg-jumpbox-${var.sys}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_network_security_rule" "jumpbox_inbound" {
  name                        = "jumpbox-inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.jumpbox.name
}

resource "azurerm_network_security_rule" "jumpbox_outbound" {
  name                        = "jumpbox-outbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.jumpbox.name
}

resource "azurerm_subnet" "jumpbox" {
  name                 = "jumpbox-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "jumpbox" {
  subnet_id                 = azurerm_subnet.jumpbox.id
  network_security_group_id = azurerm_network_security_group.jumpbox.id
}

### Storage ###

# This will be used as auto-storage
resource "azurerm_storage_account" "main" {
  name                     = "st${var.sys}789"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# This will be a resource file from the blob
resource "azurerm_storage_account" "jobfiles" {
  name                     = "st${var.sys}res111"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "jobfiles" {
  name                  = "jobfiles"
  storage_account_name  = azurerm_storage_account.jobfiles.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "molecules_zip" {
  name                   = "molecules.zip"
  storage_account_name   = azurerm_storage_account.jobfiles.name
  storage_container_name = azurerm_storage_container.jobfiles.name
  type                   = "Block"
  source                 = "molecules.zip"
}

### Batch ###

resource "azurerm_batch_account" "main" {
  name                = "ba${var.sys}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  # public_network_access_enabled = false

  storage_account_id                  = azurerm_storage_account.main.id
  storage_account_authentication_mode = "BatchAccountManagedIdentity"

  pool_allocation_mode = "BatchService"

  identity {
    type = "SystemAssigned"
  }

  # TODO: Change to private when ready
  lifecycle {
    ignore_changes = [
      public_network_access_enabled
    ]
  }
}

resource "azurerm_role_assignment" "batch" {
  scope                = azurerm_storage_account.main.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_batch_account.main.identity[0].principal_id
}

resource "azurerm_batch_application" "main" {
  name                = "molecular-analysis"
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

# Adds permission for the job to read from the data storage
resource "azurerm_role_assignment" "jobfiles" {
  scope                = azurerm_storage_account.jobfiles.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}

resource "azurerm_batch_pool" "dev" {
  name                = "dev"
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_batch_account.main.name
  display_name        = "dev"
  vm_size             = "STANDARD_D2S_V3"
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
    version   = "22.04.202303090"
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
    command_line       = "echo test"
    wait_for_success   = true
    task_retry_maximum = 1
    common_environment_properties = {
      TEST_MESSAGE = "TEST"
    }

    user_identity {
      auto_user {
        elevation_level = "Admin"
        scope           = "Pool"
      }
    }

    resource_file {
      storage_container_url     = "https://${azurerm_storage_container.jobfiles.storage_account_name}.blob.core.windows.net/${azurerm_storage_container.jobfiles.name}"
      user_assigned_identity_id = azurerm_user_assigned_identity.main.id
    }
  }

  # network_configuration {
  #   subnet_id = azurerm_subnet.main.id
  # }

  lifecycle {
    ignore_changes = [
      fixed_scale[0].target_dedicated_nodes
    ]
  }
}

resource "azurerm_batch_job" "dev" {
  name               = "dev-job"
  batch_pool_id      = azurerm_batch_pool.dev.id
  task_retry_maximum = 1
}

### Administration Jumpbox ###

resource "azurerm_public_ip" "main" {
  name                = "pip-jumpbox-${var.sys}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "main" {
  name                = "nic-jumpbox-${var.sys}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "jumpbox"
    subnet_id                     = azurerm_subnet.jumpbox.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                  = "vm-jumpbox-${var.sys}"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  size                  = var.jumpbox_size
  admin_username        = var.jumpbox_admin_user
  admin_password        = var.jumpbox_admin_password
  network_interface_ids = [azurerm_network_interface.main.id]

  custom_data = filebase64("${path.module}/cloud-init.sh")

  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = var.jumpbox_admin_user
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "22.04.202303090"
  }
}

# Adds permissions to the jumpbox VM to manage Batch
resource "azurerm_role_assignment" "jumpbox_batch" {
  scope                = azurerm_batch_account.main.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_linux_virtual_machine.main.identity[0].principal_id
}
