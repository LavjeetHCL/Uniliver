#Terraform configuration for QA environment
terraform {
  # Backend configuration (commented out for testing)
  backend "azurerm" {
    resource_group_name  = "backend-dev"
    storage_account_name = "backendstgukdev"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}
