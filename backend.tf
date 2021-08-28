## Backend storage terraform.tfstate
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-slashicorp-azure-tf"
    storage_account_name = "slashiclienttf"
    container_name       = "terraform-state"
    key                  = "terraform.tfstate"
  }
}