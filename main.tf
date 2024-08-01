# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "go-tf-jt-resources"
  location = "brazilsouth"
}

resource "azurerm_service_plan" "sp" {
  name = "go-tf-jt-zipdeploy"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type = "Linux"
  sku_name = "F1"
}

resource "azurerm_linux_web_app" "webapp" {
  name = "go-tf-jt-instance"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id = azurerm_service_plan.sp.id

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
  }

  site_config {
    always_on = false
    
    application_stack {
      docker_image = "golang"
      docker_image_tag = "latest"
    }
  }
}

output "resultado" {
  value = azurerm_linux_web_app.webapp.outbound_ip_addresses
}
