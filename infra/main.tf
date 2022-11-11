resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = random_pet.rg_name.id
}

# Create virtual network
resource "azurerm_virtual_network" "my_k8s_network" {
  name                = "k8sVnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "my_k8s_subnet" {
  name                 = "k8sSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.my_k8s_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "my_k8s_public_ip_kubemaster" {
  name                = "k8sKubeMasterPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_public_ip" "my_k8s_public_ip_kubeworker" {
  name                = "k8sKubeWorkerPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "my_k8s_nsg_kubemaster" {
  name                = "k8sKubeMasterNetworkSecurityGroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  dynamic "security_rule" {
    for_each = var.nsg_rules_kubemaster
    content {
      name                       = security_rule.value["name"]
      priority                   = security_rule.value["priority"]
      direction                  = security_rule.value["direction"]
      access                     = security_rule.value["access"]
      protocol                   = security_rule.value["protocol"]
      source_port_range          = security_rule.value["source_port_range"]
      destination_port_range     = security_rule.value["destination_port_range"]
      source_address_prefix      = security_rule.value["source_address_prefix"]
      destination_address_prefix = security_rule.value["destination_address_prefix"]
    }
  }
}

resource "azurerm_network_security_group" "my_k8s_nsg_kubeworker" {
  name                = "k8sKubeWorkerNetworkSecurityGroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  dynamic "security_rule" {
    for_each = var.nsg_rules_kubeworker
    content {
      name                       = security_rule.value["name"]
      priority                   = security_rule.value["priority"]
      direction                  = security_rule.value["direction"]
      access                     = security_rule.value["access"]
      protocol                   = security_rule.value["protocol"]
      source_port_range          = security_rule.value["source_port_range"]
      destination_port_range     = security_rule.value["destination_port_range"]
      source_address_prefix      = security_rule.value["source_address_prefix"]
      destination_address_prefix = security_rule.value["destination_address_prefix"]
    }
  }
}

# Create network interface
resource "azurerm_network_interface" "my_k8s_nic_kubemaster" {
  name                = "k8sKubeMasterNIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "k8s_nic_kubemaster_configuration"
    subnet_id                     = azurerm_subnet.my_k8s_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my_k8s_public_ip_kubemaster.id
  }
}

resource "azurerm_network_interface" "my_k8s_nic_kubeworker" {
  name                = "k8sKubeWorkerNIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "k8s_nic_kubeworker_configuration"
    subnet_id                     = azurerm_subnet.my_k8s_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my_k8s_public_ip_kubeworker.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "kubemaster" {
  network_interface_id      = azurerm_network_interface.my_k8s_nic_kubemaster.id
  network_security_group_id = azurerm_network_security_group.my_k8s_nsg_kubemaster.id
}

resource "azurerm_network_interface_security_group_association" "kubeworker" {
  network_interface_id      = azurerm_network_interface.my_k8s_nic_kubeworker.id
  network_security_group_id = azurerm_network_security_group.my_k8s_nsg_kubeworker.id
}

# Create (and display) an SSH key
resource "tls_private_key" "k8s_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "my_k8s_vm_kubemaster" {
  name                  = "kubemaster"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.my_k8s_nic_kubemaster.id]
  size                  = "Standard_D4s_v3"

  os_disk {
    name                 = "kubeMasterOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "8-LVM"
    version   = "latest"
  }

  computer_name                   = "kubemaster"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.k8s_ssh.public_key_openssh
  }
}

resource "azurerm_linux_virtual_machine" "my_k8s_vm_kubeworker" {
  name                  = "kubeworker"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.my_k8s_nic_kubeworker.id]
  size                  = "Standard_D4s_v3"

  os_disk {
    name                 = "kubeWorkerOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "8-LVM"
    version   = "latest"
  }

  computer_name                   = "kubeworker"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.k8s_ssh.public_key_openssh
  }
}
