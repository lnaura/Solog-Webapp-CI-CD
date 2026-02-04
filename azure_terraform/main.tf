# 리소스 그룹
resource "azurerm_resource_group" "solog" {
  name     = var.resource_group_name
  location = var.location
}

# 네트워크
resource "azurerm_virtual_network" "solog_vnet" {
  name                = "vnet-solog"
  location            = azurerm_resource_group.solog.location
  resource_group_name = azurerm_resource_group.solog.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "snet-aks"
  resource_group_name  = azurerm_resource_group.solog.name
  virtual_network_name = azurerm_virtual_network.solog_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# ACR
resource "azurerm_container_registry" "acr" {
  name                = "sologregistry${var.suffix}"
  resource_group_name = azurerm_resource_group.solog.name
  location            = azurerm_resource_group.solog.location
  sku                 = "Basic"
  admin_enabled       = true
}

# AKS
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-solog-cluster"
  location            = azurerm_resource_group.solog.location
  resource_group_name = azurerm_resource_group.solog.name
  dns_prefix          = "sologaks"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "standard_b2s_v2"
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  network_profile {
    network_plugin     = "azure"
    service_cidr       = "10.1.0.0/16"
    dns_service_ip     = "10.1.0.10"
  }

  identity {
    type = "SystemAssigned"
  }
}

# 권한 설정
resource "azurerm_role_assignment" "aks_to_acr" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

# NSG
resource "azurerm_network_security_group" "aks_nsg" {
  name                = "nsg-aks"
  location            = azurerm_resource_group.solog.location
  resource_group_name = azurerm_resource_group.solog.name

  # SSH
  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  # HTTP
  security_rule {
    name                       = "AllowHTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  # HTTPS
  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowAzureLoadBalancerInBound"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*" # 모든 포트 허용 (로드밸런서 통신용)
    source_address_prefix      = "AzureLoadBalancer" # Azure 로드밸런서 서비스 태그
    destination_address_prefix = "*"
  }
}

# 서브넷과 NSG 연결
resource "azurerm_subnet_network_security_group_association" "aks_nsg_assoc" {
  subnet_id                 = azurerm_subnet.aks_subnet.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}