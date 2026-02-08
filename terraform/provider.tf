terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  
  backend "azurerm" {
    # Uncomment and configure for remote state
    # resource_group_name  = "terraform-state-rg"
    # storage_account_name = "tfstategameplatform"
    # container_name       = "tfstate"
    # key                  = "aks-game-platform.tfstate"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  
  # Uncomment to specify subscription
  # subscription_id = "your-subscription-id"
}
