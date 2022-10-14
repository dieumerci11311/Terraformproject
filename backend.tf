terraform {
  backend "azurerm" {
    resource_group_name  = "tfstateRGOlu"
    storage_account_name = "tfstatestorageolu"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}