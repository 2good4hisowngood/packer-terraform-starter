resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.rg_location
}

resource "random_string" "random_name" {
  length  = 4
  upper   = false
  special = false
}

module "avd" {
  source          = "./modules/avd"
  rg_name         = azurerm_resource_group.rg.name
  rg_location     = azurerm_resource_group.rg.location
  rg_id           = azurerm_resource_group.rg.id
  hostpool_name   = var.hostpool_name
  vnet_name       = var.vnet_name
  address_space   = var.address_space
  subnet_prefixes = var.subnet_prefixes
  vm_size         = var.vm_size
  vm_count        = var.vm_count
  admin_username  = var.admin_username
  admin_password  = var.admin_password
  random_name     = random_string.random_name.id
  current_client  = data.azurerm_client_config.current
}
