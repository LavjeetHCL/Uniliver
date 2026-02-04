module "rgs" {
  source = "../../modules/ResourceGroup"
  rgs    = var.rgs
}


module "networking" {
  depends_on    = [module.rgs]
  source        = "../../modules/Networking"
  vnets_subnets = var.vnets_subnets
}



module "vms" {
  depends_on      = [module.rgs, module.networking]
  source          = "../../modules/LinuxVirtualMachine"
  vms             = var.vms
  vnet_subnet_ids = module.networking.vnet_subnet_ids
}
