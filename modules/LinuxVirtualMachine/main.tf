resource "random_string" "vm_username" {
  for_each = var.vms

  length  = 8
  upper   = false
  lower   = true
  numeric = true
  special = false
}

resource "random_password" "vm_password" {
  for_each = var.vms

  length           = 20
  special          = true
  override_special = "!@#$%^&*()-_=+"
}

data "azurerm_key_vault" "kv" {
  for_each            = var.vms
  name                = each.value.kv_name
  resource_group_name = each.value.resource_group_name
}

resource "azurerm_key_vault_secret" "vm_username" {
  for_each = var.vms

  name         = "${each.key}-admin-username"
  value        = random_string.vm_username[each.key].result
  key_vault_id = data.azurerm_key_vault.kv[each.key].id
}


resource "azurerm_key_vault_secret" "vm_password" {
  for_each = var.vms

  name         = "${each.key}-admin-password"
  value        = random_password.vm_password[each.key].result
  key_vault_id = data.azurerm_key_vault.kv[each.key].id
}


# data "azurerm_key_vault_secret" "vm_username" {
#   for_each     = var.vms
#   name         = "${each.key}-admin-username"
#   key_vault_id = data.azurerm_key_vault.kv["kv1"].id
# }


# data "azurerm_key_vault_secret" "vm_password" {
#   for_each     = var.vms
#   name         = "${each.key}-admin-password"
#   key_vault_id = data.azurerm_key_vault.kv["kv1"].id
# }



resource "azurerm_public_ip" "pips" {
  for_each            = { for vm_name, vm_details in var.vms : vm_name => vm_details if vm_details.enable_public_ip == true }
  name                = "${each.key}-pip"
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  depends_on          = [azurerm_public_ip.pips]
  for_each            = var.vms
  name                = "${each.key}-nic"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = lookup(lookup(var.vnet_subnet_ids, each.value.vnet_name), each.value.subnet_name)
    private_ip_address_allocation = "Dynamic"

    #Conditionally associate the public IP
    public_ip_address_id = lookup(lookup(azurerm_public_ip.pips, each.key, {}), "id", null)
  }
}

resource "azurerm_network_security_group" "nsg" {
  for_each            = var.vms
  name                = "${each.key}-nsg"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  dynamic "security_rule" {
    for_each = each.value.inbound_open_ports
    content {
      name                       = "OpenPort${security_rule.value}"
      priority                   = ceil((security_rule.value % 9) + 130)
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = security_rule.value
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
}

resource "azurerm_network_interface_security_group_association" "association" {
  for_each                  = var.vms
  network_interface_id      = azurerm_network_interface.nic[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}

resource "azurerm_linux_virtual_machine" "vms" {
  for_each                        = var.vms
  name                            = each.key
  resource_group_name             = each.value.resource_group_name
  location                        = each.value.location
  size                            = each.value.size
  admin_username                  = random_string.vm_username[each.key].result #data.azurerm_key_vault_secret.vm_username[each.key].value
  admin_password                  = random_password.vm_password[each.key].result #data.azurerm_key_vault_secret.vm_password[each.key].value
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.nic[each.key].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = each.value.source_image_reference.publisher
    offer     = each.value.source_image_reference.offer
    sku       = each.value.source_image_reference.sku
    version   = each.value.source_image_reference.version
  }
}

output "vm_private_ips" {
  value = { for k, v in azurerm_linux_virtual_machine.vms : v.name => v.private_ip_address }
}
output "vm_public_ips" {
  value = { for k, v in azurerm_linux_virtual_machine.vms : v.name => v.public_ip_address }
}

output "vm_nic_ids" {
  value = { for k, v in azurerm_linux_virtual_machine.vms : v.name => v.network_interface_ids[0] }
}

output "vm_ids" {
  value = { for k, v in azurerm_linux_virtual_machine.vms : v.name => v.id }
}
