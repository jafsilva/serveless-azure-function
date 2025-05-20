terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "zelabs"
    storage_account_name = "zelabstfstate"
    container_name       = "tfstate"
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

locals {
  current_datetime_full = timestamp()
  current_datetime      = replace(substr(local.current_datetime_full, 0, 10), "-", "")
}

resource "azurerm_storage_account" "this" {
  name                     = "${var.project_name}${local.current_datetime}"
  resource_group_name      = data.azurerm_resource_group.this.name
  location                 = data.azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "this" {
  name                =  "${var.project_name}-${local.current_datetime}"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  sku_name            = "Y1"
  os_type             = "Linux"
}

resource "azurerm_linux_function_app" "this" {
  name                       = "${var.project_name}"
  resource_group_name        = data.azurerm_resource_group.this.name     # Usando o nome do RG existente
  location                   = data.azurerm_resource_group.this.location # Usando a localização do RG existente
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
  lifecycle {
    prevent_destroy = false
  }
}

variable "project_name" {
  default = "zelabs"
}