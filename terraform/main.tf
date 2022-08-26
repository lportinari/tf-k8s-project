terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "dev" {
  name     = "voting-app"
  location = "East US"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks"
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name
  dns_prefix          = "aks"

  default_node_pool {
    name       = "aks"
    node_count = 3
    vm_size    = "Standard_D2_v2"
    zones      = [1, 2, 3]
  }

  identity {
    type = "SystemAssigned"
  }

}

resource "azurerm_container_registry" "my_registry" {
  name                = "lvpcregistry"
  resource_group_name = azurerm_resource_group.dev.name
  location            = azurerm_resource_group.dev.location
  sku                 = "Premium"
  admin_enabled       = false
}

resource "azurerm_role_assignment" "my_registry_role1" {
  scope                = azurerm_container_registry.my_registry.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}