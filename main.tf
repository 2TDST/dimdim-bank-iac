provider "azurerm" {
  version = "=2.0.0"
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-slashicorp-azure-tf"
    storage_account_name = "slashiclienttf"
    container_name       = "terraform-state"
    key                  = "terraform.tfstate"
  }
}

resource "azurerm_resource_group" "rg-slashicorp-azure-tf" {
  name     = "rg-slashicorp-azure-tf"
  location = "northcentralus"
}