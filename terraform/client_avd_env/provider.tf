terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.11.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.0.2"
    }
  }
  backend "azurerm" {
      resource_group_name  = "personal-devops"
      storage_account_name = "mypersonalterraform"
      container_name       = "tfstate"
      key                  = "example_avd_env.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

provider "azuread" {
}

provider "time" {
}

provider "random" {
  
}

data "azurerm_client_config" "current" {}