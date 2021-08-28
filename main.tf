## Provider informations
provider "azurerm" {
  version = "=2.0.0"
  features {}
}

## Backend storage terraform.tfstate
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-slashicorp-azure-tf"
    storage_account_name = "slashiclienttf"
    container_name       = "terraform-state"
    key                  = "terraform.tfstate"
  }
}

## Resourcegroup information
resource "azurerm_resource_group" "rg-slashicorp-azure-tf" {
  name     = "rg-slashicorp-azure-tf"
  location = "northcentralus"
}

## Create the virtual network for an AKS cluster
module "network" {
  source              = "git@github.com:FairwindsOps/azure-terraform-modules.git//virtual_network?ref=virtual_network-v0.6.0"
  region              = "northcentralus"
  resource_group_name = azurerm_resource_group.rg-slashicorp-azure-tf.name
  name                = "aks-dimdim-network"
  network_cidr_prefix = "10.64.0.0"
  network_cidr_suffix = 10
  subnets = [{
    name       = "aks-dimdim-subnet"
    cidr_block = 16
  }]
}

## Create the AKS cluster
module "cluster" {
  source              = "git@github.com:FairwindsOps/azure-terraform-modules.git//aks_cluster?ref=aks_cluster-v0.8.0"
  region              = "centralus"
  cluster_name        = "aks-dimdim-cluster"
  kubernetes_version  = "1.20.7"
  resource_group_name = azurerm_resource_group.rg-slashicorp-azure-tf.name
  node_subnet_id      = module.network.subnet_ids[0]
  network_plugin      = "azure"
  network_policy      = "calico"
  public_ssh_key_path = "aks-key.pub"
}

## Create the node pool
module "node_pool" {
  source         = "git@github.com:FairwindsOps/azure-terraform-modules.git//aks_node_pool?ref=aks_node_pool-v0.4.0"
  name           = "aks-dimdim-cluster-spool"
  kubernetes_version  = "1.20.7"
  aks_cluster_id = module.cluster.id
  node_subnet_id = module.network.subnet_ids[0]
}