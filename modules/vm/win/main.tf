### Windows Jump Server ###

resource "azurerm_public_ip" "windows" {
  name                = "pip-windows-${var.sys}"
  resource_group_name = var.group
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "windows" {
  name                = "nic-windows-${var.sys}"
  resource_group_name = var.group
  location            = var.location

  ip_configuration {
    name                          = "windows"
    subnet_id                     = var.jumpbox_subnet
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.windows.id
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_windows_virtual_machine" "windows" {
  name                  = "win-${var.sys}"
  resource_group_name   = var.group
  location              = var.location
  size                  = var.jumpbox_size
  admin_username        = "bastionadmin"
  admin_password        = "P@ssw0rd.123"
  network_interface_ids = [azurerm_network_interface.windows.id]

  os_disk {
    name                 = "osdisk-win-${var.sys}"
    caching              = "ReadOnly"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter"
    version   = "latest"
  }
}
