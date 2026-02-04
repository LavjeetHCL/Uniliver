rgs = {
  rg-infra-app1-uk = {
    location = "southindia"
  }
  rg-infra-app2-uk = {
    location = "southindia"
  }
  rg-infra-app3-uk = {
    location = "southindia"
  }
}




vnets_subnets = {
  vnet-infra-app1-uk = {
    location            = "southindia"
    resource_group_name = "rg-infra-app1-uk"
    address_space       = ["10.0.0.0/16"]
    enable_bastion = false
    subnets = {
      frontend-subnet = {
        address_prefixes = ["10.0.0.0/24"]
      }
      backend-subnet = {
        address_prefixes = ["10.0.1.0/24"]
      }
      AzureBastionSubnet = {
        address_prefixes = ["10.0.2.0/24"]
      }
    }
  }
}


vms = {
  frontendvm = {
    resource_group_name = "rg-infra-app1-uk"
    location            = "southindia"
    vnet_name           = "vnet-infra-app1-uk"
    subnet_name         = "frontend-subnet"
    size                = "Standard_D2s_v3"
    admin_username      = "devopsadmin"
    admin_password      = "P@ssw01rd@123"
    userdata_script     = "install_nginx.sh"
    inbound_open_ports  = [22, 80]
    source_image_reference = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-focal"
      sku       = "20_04-lts"
      version   = "latest"
    }
    enable_public_ip = true
  }
  backendvm = {
    resource_group_name = "rg-infra-app1-uk"
    location            = "southindia"
    vnet_name           = "vnet-infra-app1-uk"
    subnet_name         = "backend-subnet"
    size                = "Standard_D2s_v3"
    admin_username      = "devopsadmin"
    admin_password      = "P@ssw01rd@123"
    userdata_script     = "install_python.sh"
    inbound_open_ports  = [22, 8000]
    source_image_reference = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-focal"
      sku       = "20_04-lts"
      version   = "latest"
    }
    enable_public_ip = false
  }
}



