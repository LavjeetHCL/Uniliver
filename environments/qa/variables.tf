variable "rgs" {
  type = map(object({
    location = string
    tags     = optional(map(string))
  }))
}



variable "vnets_subnets" {
  type = map(object({
    location            = string
    resource_group_name = string
    address_space       = list(string)
    enable_bastion = optional(bool, false)

    subnets = map(object({
      address_prefixes = list(string)
    }))
  }))
  description = "Map of virtual networks and their corresponding subnets."
}


variable "vms" {
  type = map(object({
    resource_group_name     = string
    location                = string
    vnet_name               = string
    subnet_name             = string
    size                    = string
    admin_username          = string
    admin_password          = string
    userdata_script         = string
    inbound_open_ports      = list(number)
    source_image_reference  = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
    enable_public_ip        = bool
  }))
  description = "Map of virtual machines to be created."
}


