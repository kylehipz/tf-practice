terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.15.0"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
      recover_soft_deleted_keys = true
    }
  }
}

data "azuread_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name = "kylehipz"
  location = "southeastasia"
}

resource "azurerm_service_plan" "as_plan" {
  name = "kylehipz-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  sku_name = "P1v2"
  os_type = "Linux"
}

resource "azurerm_linux_web_app" "as" {
  name = "kylehipz"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  service_plan_id = azurerm_service_plan.as_plan.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    http2_enabled = true
  }

  app_settings = {WEBSITES_PORT = "8000"}
}

resource "azurerm_linux_web_app_slot" "as-slot" {
  name = "staging"
  app_service_id = azurerm_linux_web_app.as.id

  identity {
    type = "SystemAssigned"
  }

  site_config { 
    http2_enabled = true
  }
}

resource "azurerm_key_vault" "kv" {
  name = "kylehipz-kv"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  enable_rbac_authorization = true
  tenant_id = data.azuread_client_config.current.tenant_id
  soft_delete_retention_days = 7
  purge_protection_enabled = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azuread_client_config.current.tenant_id
    object_id = data.azuread_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
    ]

    storage_permissions = [
      "Get",
    ]
  }
}

resource "azurerm_storage_account" "sa" {
  name = "kylehipzsa"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location

  account_tier = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_application_insights" "ai" {
  name = "kylehipz-ai"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location

  application_type = "web"
}

resource "azuread_group" "group" {
  display_name     = "Kyle Hipz Devs"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true

  members = [
    data.azuread_client_config.current.object_id,
    azurerm_linux_web_app.as.identity[0].principal_id,
    azurerm_linux_web_app_slot.as-slot.identity[0].principal_id,
  ]
}
