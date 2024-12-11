resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_shared_image_gallery" "example" {
  name                = var.image_gallery_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  description         = "Shared images and things."

  tags = var.tags
}

# resource "azurerm_key_vault" "example" {
#   name                        = "${var.key_vault_name}-${random_string.example.result}"
#   location                    = azurerm_resource_group.example.location
#   resource_group_name         = azurerm_resource_group.example.name
#   enabled_for_disk_encryption = true
#   enabled_for_deployment      = true
#   tenant_id                   = data.azurerm_client_config.current.tenant_id
#   soft_delete_retention_days  = 7
#   purge_protection_enabled    = false

#   sku_name = "standard"

#   access_policy {
#     tenant_id = data.azurerm_client_config.current.tenant_id
#     object_id = data.azurerm_client_config.current.object_id

#     key_permissions = [
#       "Get",
#     ]

#     secret_permissions = [
#       "Get",
#     ]

#     storage_permissions = [
#       "Get",
#     ]
#   }
# }

resource "azurerm_shared_image" "example" {
  name                = "WindowsImage"
  gallery_name        = azurerm_shared_image_gallery.example.name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Windows"
  hyper_v_generation  = "V2"

  identifier {
    publisher = "PublisherName"
    offer     = "OfferName"
    sku       = "ExampleSku"
  }
}

resource "random_string" "example" {
  length  = 6
  special = false
  upper   = false
  numeric = true
}

# data "azurerm_shared_image_versions" "example" {
#   gallery_name        = azurerm_shared_image_gallery.example.name
#   image_name          = azurerm_shared_image.example.name
#   resource_group_name = azurerm_resource_group.example.name
# }

# resource "azurerm_shared_image_version" "imported_versions" {
#   for_each            = tomap({ for version in data.azurerm_shared_image_versions.example.versions : version.name => version })

#   name                = each.value.name
#   gallery_name        = azurerm_shared_image_gallery.example.name
#   image_name          = azurerm_shared_image.example.name
#   resource_group_name = azurerm_resource_group.example.name
#   location            = azurerm_resource_group.example.location

#   target_region {
#     name                   = azurerm_resource_group.example.location
#     regional_replica_count = 1
#     storage_account_type   = "Standard_LRS"
#   }
# }

# # Import block for dynamically importing shared image versions
# import {
#   for_each = tomap({ for version in data.azurerm_shared_image_versions.example.versions : version.name => version })

#   to = azurerm_shared_image_version.imported_versions[each.key]
#   id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${azurerm_resource_group.example.name}/providers/Microsoft.Compute/galleries/${azurerm_shared_image_gallery.example.name}/images/${azurerm_shared_image.example.name}/versions/${each.key}"
# }