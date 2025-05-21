terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "zelabs" # Substituir por resource group existente
    storage_account_name = "storageaccountname" # Substituir por storage account existente
    container_name       = "tfstate" # Substituir por container em um storage account existente
    key                  = "serveless-azure-function.tfstate"
  }

}

provider "azurerm" {
  features {}
}


# Data source para buscar o Resource Group existente
data "azurerm_resource_group" "this" {
  name = "${var.project_name}"
}


resource "azurerm_storage_account" "this" {
  name                     = "${var.project_name}20250520"
  resource_group_name      = data.azurerm_resource_group.this.name
  location                 = data.azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "this" {
  name                =  "${var.project_name}-20250520"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  sku_name            = "Y1"
  os_type             = "Linux"
}

resource "azurerm_linux_function_app" "this" {
  name                       = "${var.project_name}"
  resource_group_name        = data.azurerm_resource_group.this.name
  location                   = data.azurerm_resource_group.this.location
  service_plan_id            = azurerm_service_plan.this.id
  storage_account_name       = azurerm_storage_account.this.name
  storage_account_access_key = azurerm_storage_account.this.primary_access_key

  site_config {
    application_stack {
      python_version = "3.12" # Específico para runtime Python
    }
  }
  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "python"
  }
}

variable "project_name" {
  default = "zelabs"
}