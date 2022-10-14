terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.26.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "Terraformrg" {
  name     = "Terraformrg"
  location = "West Europe"
}

resource "azurerm_virtual_network" "OluVnet" {
  name                = "OluVnet"
  location            = azurerm_resource_group.Terraformrg.location
  resource_group_name = azurerm_resource_group.Terraformrg.name
  address_space       = ["10.0.0.0/16"]


  tags = {
    environment = "Dev"
  }
}

resource "azurerm_subnet" "Olu-subnet" {
  name                 = "Olu-subnet"
  resource_group_name  = azurerm_resource_group.Terraformrg.name
  virtual_network_name = azurerm_virtual_network.OluVnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_security_group" "Olu-sg" {
  name                = "Olu-sg"
  location            = azurerm_resource_group.Terraformrg.location
  resource_group_name = azurerm_resource_group.Terraformrg.name

  tags = {
    environment = "Dev"
  }
}

resource "azurerm_network_security_rule" "Olu-rule" {
  name                        = "Olu-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.Terraformrg.name
  network_security_group_name = azurerm_network_security_group.Olu-sg.name
}
resource "azurerm_subnet_network_security_group_association" "Olusecgroup" {
  subnet_id                 = azurerm_subnet.Olu-subnet.id
  network_security_group_id = azurerm_network_security_group.Olu-sg.id
}
resource "azurerm_network_interface" "Olu-nic" {
  name                = "Olu-nic"
  location            = azurerm_resource_group.Terraformrg.location
  resource_group_name = azurerm_resource_group.Terraformrg.name

ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Olu-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
    environment = "dev"
  }
}
resource "azurerm_linux_virtual_machine" "Olu-vm" {
  name                            = "Olu-vm"
  resource_group_name             = azurerm_resource_group.Terraformrg.name
  location                        = azurerm_resource_group.Terraformrg.location
  size                            = "Standard_B1s"
  admin_username                  = "adminuser"
  admin_password                  = "abc59!"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.Olu-nic.id,
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
   source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}