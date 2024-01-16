resource "azurerm_user_assigned_identity" "main" {
  name                = "batch-pool-user"
  location            = var.location
  resource_group_name = var.group
}

# Adds permission for the job to read from the data storage
resource "azurerm_role_assignment" "jobfiles" {
  scope                = var.storage_jobfiles_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}

resource "azurerm_batch_pool" "dev" {
  name                = "dev"
  resource_group_name = var.group
  account_name        = var.batch_account_name
  display_name        = "dev"
  vm_size             = var.batch_vm_size
  node_agent_sku_id   = "batch.node.ubuntu 22.04"
  max_tasks_per_node  = 1

  target_node_communication_mode = "Simplified"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.main.id]
  }

  storage_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "LATEST"
  }

  data_disks {
    lun                  = 0
    caching              = "None"
    disk_size_gb         = 10
    storage_account_type = "Premium_LRS"
  }

  fixed_scale {
    node_deallocation_method  = "TaskCompletion"
    target_dedicated_nodes    = 0
    target_low_priority_nodes = 0
  }

  start_task {
    command_line       = "echo test"
    wait_for_success   = false
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
      storage_container_url     = "https://${var.jobfiles_storage_name}.blob.core.windows.net/${var.jobfiles_storage_name}"
      user_assigned_identity_id = azurerm_user_assigned_identity.main.id
    }
  }

  network_configuration {
    subnet_id                        = var.batch_subnet_id
    public_address_provisioning_type = "NoPublicIPAddresses"
  }

  lifecycle {
    ignore_changes = [
      fixed_scale[0].target_dedicated_nodes
    ]
  }
}

# resource "azurerm_batch_job" "dev" {
#   name               = "dev-job"
#   batch_pool_id      = azurerm_batch_pool.dev.id
#   task_retry_maximum = 1
# }
