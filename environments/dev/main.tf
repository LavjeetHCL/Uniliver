module "rgs" {
  source = "../../modules/ResourceGroup"
  rgs    = var.rgs
}


module "networking" {
  depends_on    = [module.rgs]
  source        = "../../modules/Networking"
  vnets_subnets = var.vnets_subnets
}

# module "KeyVault" {
#   depends_on = [module.rgs]
#   source     = "../../modules/KeyVault"
#   key_vaults = var.key_vaults
# }


module "vms" {
  depends_on      = [module.rgs, module.networking, ] # if keyvault module is enabled, add it as a dependency here
  source          = "../../modules/LinuxVirtualMachine"
  vms             = var.vms
  vnet_subnet_ids = module.networking.vnet_subnet_ids
  public_key      = file("${path.module}/SSH/vm_public_key.pub")
 

}
