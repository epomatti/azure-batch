### Administration Jumpbox ###
resource "azurerm_public_ip" "main" {
  name                = "pip-jumpbox-${var.sys}"
  resource_group_name = var.group
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "main" {
  name                = "nic-jumpbox-${var.sys}"
  resource_group_name = var.group
  location            = var.location

  ip_configuration {
    name                          = "jumpbox"
    subnet_id                     = var.jumpbox_subnet
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                  = "vm-jumpbox-${var.sys}"
  resource_group_name   = var.group
  location              = var.location
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
    caching              = "ReadOnly"
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
  scope                = var.batch_account_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_linux_virtual_machine.main.identity[0].principal_id
}
