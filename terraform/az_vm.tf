iprovider "azurerm" {
  features {}
}

##################################
# Resource Group
##################################

resource "azurerm_resource_group" "rg" {
  name     = "terra-rg"
  location = "Central India"
}

##################################
# Virtual Network
##################################

resource "azurerm_virtual_network" "vnet" {
  name                = "terra-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  address_space = [
    "10.0.0.0/16"
  ]
}

##################################
# Subnet
##################################

resource "azurerm_subnet" "subnet" {
  name                 = "terra-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = [
    "10.0.1.0/24"
  ]
}

##################################
# Public IP
##################################

resource "azurerm_public_ip" "public_ip" {
  name                = "terra-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  allocation_method = "Static"
  sku               = "Standard"
}

##################################
# Network Security Group
##################################

resource "azurerm_network_security_group" "nsg" {
  name                = "terra-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"

    source_port_range          = "*"
    destination_port_range     = "22"

    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"

    source_port_range          = "*"
    destination_port_range     = "80"

    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"

    source_port_range          = "*"
    destination_port_range     = "443"

    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

##################################
# Network Interface
##################################

resource "azurerm_network_interface" "nic" {
  name                = "terra-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"

    subnet_id                     = azurerm_subnet.subnet.id

    private_ip_address_allocation = "Dynamic"

    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
}

##################################
# NSG Association
##################################

resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

##################################
# Linux VM (ARM64)
##################################

resource "azurerm_linux_virtual_machine" "vm" {

  name                = "automate-vm"

  resource_group_name = azurerm_resource_group.rg.name

  location            = azurerm_resource_group.rg.location

  size = "Standard_B2ps_v2"

  admin_username = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  disable_password_authentication = true

  admin_ssh_key {

    username = "azureuser"

    public_key = file("terra-key.pub")
  }

  os_disk {

    caching = "ReadWrite"

    storage_account_type = "StandardSSD_LRS"

    disk_size_gb = 30
  }

  source_image_reference {

    publisher = "Canonical"

    offer = "ubuntu-24_04-lts"

    sku = "server-arm64"

    version = "latest"
  }

  tags = {
    Name = "Automate"
  }
}

##################################
# Output Public IP
##################################

output "vm_public_ip" {
  value = azurerm_public_ip.public_ip.ip_address
}
