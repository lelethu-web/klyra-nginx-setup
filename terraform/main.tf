# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.1"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "klyra" {
  name     = "rg-klyra-nginx"
  location = "North Europe"
}

# Create a virtual network
resource "azurerm_virtual_network" "klyra" {
  name                = "vnet-klyra-nginx"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.klyra.location
  resource_group_name = azurerm_resource_group.klyra.name
}

# Create a subnet
resource "azurerm_subnet" "klyra" {
  name                 = "subnet-klyra-nginx"
  resource_group_name  = azurerm_resource_group.klyra.name
  virtual_network_name = azurerm_virtual_network.klyra.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create public IP
resource "azurerm_public_ip" "klyra" {
  name                = "pip-klyra-nginx"
  resource_group_name = azurerm_resource_group.klyra.name
  location            = azurerm_resource_group.klyra.location
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "klyra" {
  name                = "nsg-klyra-nginx"
  location            = azurerm_resource_group.klyra.location
  resource_group_name = azurerm_resource_group.klyra.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
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
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    destination_address_prefix = "*"
    source_address_prefix      = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "klyra" {
  name                = "nic-klyra-nginx"
  location            = azurerm_resource_group.klyra.location
  resource_group_name = azurerm_resource_group.klyra.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.klyra.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.klyra.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "klyra" {
  network_interface_id      = azurerm_network_interface.klyra.id
  network_security_group_id = azurerm_network_security_group.klyra.id
}

# Generate random text for a unique storage account name
resource "random_id" "random_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.klyra.name
  }
  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "klyra" {
  name                     = "diag${random_id.random_id.hex}"
  location                 = azurerm_resource_group.klyra.location
  resource_group_name      = azurerm_resource_group.klyra.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "klyra" {
  name                = "vm-klyra-nginx"
  resource_group_name = azurerm_resource_group.klyra.name
  location            = azurerm_resource_group.klyra.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"

  # Disable password authentication
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.klyra.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/klyra-nginx-key.pub")  # Update this path to your public key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.klyra.primary_blob_endpoint
  }
}

# Output the public IP address
output "public_ip_address" {
  value = azurerm_linux_virtual_machine.klyra.public_ip_address
}
