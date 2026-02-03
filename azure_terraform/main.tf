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