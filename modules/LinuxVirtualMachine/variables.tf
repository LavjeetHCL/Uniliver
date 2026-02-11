variable "vms" {
  type = map(object({
    resource_group_name = string
    location            = string
    vnet_name           = string
    subnet_name         = string
    admin_username      = string
    size                = string
    userdata_script     = string
    inbound_open_ports  = list(number)
    source_image_reference = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
    enable_public_ip = bool
    #kv_name = string
  }))
}



variable "vnet_subnet_ids" {
  type = map(map(string))
  description = "A map of virtual network names to their subnet IDs."
}


variable "public_key" {
  description = "SSH public key content"
  type        = string
}


