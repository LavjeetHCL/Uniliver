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
