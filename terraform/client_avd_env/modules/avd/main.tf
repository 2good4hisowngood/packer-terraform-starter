resource "azuread_group" "desktop_users" {
  display_name     = "Desktop Users"
  mail_enabled     = false
  security_enabled = true
}

resource "azurerm_role_assignment" "vm_login_role" {
  scope                = var.rg_id
  role_definition_name = "Virtual Machine User Login"
  principal_id         = azuread_group.desktop_users.object_id
}

resource "azurerm_role_assignment" "desktop_user_role" {
  scope                = var.rg_id
  role_definition_name = "Desktop Virtualization User"
  principal_id         = azuread_group.desktop_users.object_id
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.rg_name
  location            = var.rg_location
  address_space       = var.address_space
}

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_prefixes
}

resource "time_rotating" "avd_token" {
  rotation_days = 30
}

resource "azurerm_virtual_desktop_host_pool" "hostpool" {
  name                     = var.hostpool_name
  resource_group_name      = var.rg_name
  location                 = var.rg_location
  friendly_name            = var.hostpool_name
  type                     = "Pooled"
  load_balancer_type       = "BreadthFirst"
  preferred_app_group_type = "Desktop"
  custom_rdp_properties    = "targetisaadjoined:i:1;audiocapturemode:i:0;audiomode:i:0;drivestoredirect:s:*;encode redirected video capture:i:0;camerastoredirect:s:;devicestoredirect:s:;redirectclipboard:i:1;redirectcomports:i:0;redirectlocation:i:0;redirectprinters:i:1;redirectsmartcards:i:0;usbdevicestoredirect:s:" # May also need enablerdsaadauth:i:1

}

resource "azurerm_virtual_desktop_host_pool_registration_info" "hostpool_registration" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.hostpool.id
  expiration_date = time_rotating.avd_token.rotation_rfc3339

  depends_on = [azurerm_virtual_desktop_host_pool.hostpool]
}

resource "azurerm_virtual_desktop_application_group" "application_group" {
  name                = "${var.hostpool_name}-appgroup"
  resource_group_name = var.rg_name
  location            = var.rg_location
  host_pool_id        = azurerm_virtual_desktop_host_pool.hostpool.id
  type                = "Desktop"
  friendly_name       = "${var.hostpool_name}-appgroup"
}

resource "azurerm_virtual_desktop_workspace" "workspace" {
  name                = "${var.hostpool_name}-workspace"
  resource_group_name = var.rg_name
  location            = var.rg_location
  friendly_name       = "${var.hostpool_name}-workspace"
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "main" {
  workspace_id         = azurerm_virtual_desktop_workspace.workspace.id
  application_group_id = azurerm_virtual_desktop_application_group.application_group.id
}

data "azurerm_shared_image" "built_image" {
  name                = var.image_name
  resource_group_name = var.acg_rg_name
  gallery_name        = var.acgName

}

resource "azurerm_windows_virtual_machine" "session_host" {
  count                 = var.vm_count
  name                  = "${var.hostpool_name}-vm-${count.index}"
  resource_group_name   = var.rg_name
  location              = var.rg_location
  size                  = var.vm_size
  network_interface_ids = [azurerm_network_interface.session_host[count.index].id]
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  provision_vm_agent    = true
  license_type          = "Windows_Client"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_id = data.azurerm_shared_image.built_image.id
  # source_image_reference {
  #   publisher = "MicrosoftWindowsDesktop"
  #   offer     = "Windows-11"
  #   sku       = "win11-22h2-avd"
  #   version   = "latest"
  # }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_network_interface" "session_host" {
  count               = var.vm_count
  name                = "${var.hostpool_name}-nic-${count.index}"
  location            = var.rg_location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine_extension" "aad_login" {
  count                      = var.vm_count
  name                       = "aadds-join-vmext"
  virtual_machine_id         = azurerm_windows_virtual_machine.session_host.*.id[count.index]
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "2.0"
  auto_upgrade_minor_version = true
}

resource "azurerm_virtual_machine_extension" "custom_scripts" {
  count = var.vm_count
  name = "${var.hostpool_name}-vm-${count.index}-custom-scripts"
  virtual_machine_id = azurerm_windows_virtual_machine.session_host.*.id[count.index]
  publisher = "Microsoft.Compute"
  type = "CustomScriptExtension"
  type_handler_version = "1.10"
  auto_upgrade_minor_version = true

  protected_settings = <<PROTECTED_SETTINGS
  {
    "storageAccountName": "${azurerm_storage_account.scripts.name}",
    "storageAccountKey": "${azurerm_storage_account.scripts.primary_access_key}"
  }
  PROTECTED_SETTINGS

  settings = <<SETTINGS
  {
    "fileUris": ["https://${azurerm_storage_account.scripts.name}.blob.core.windows.net/scripts/setup-host.ps1"],
    "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File setup-host.ps1"
  }
  SETTINGS

  depends_on = [
    azurerm_virtual_machine_extension.aad_login,
    azurerm_storage_blob.setup_host
  ]
}

# This extension should activate last, as it registers the vm to the hostpool
resource "azurerm_virtual_machine_extension" "last_host_extension_hp_registration" {
  count                      = var.vm_count
  name                       = "${var.hostpool_name}-vm-${count.index}-avd_dsc"
  virtual_machine_id         = azurerm_windows_virtual_machine.session_host.*.id[count.index]
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true
  # automatic_upgrade_enabled = true

  settings = <<-SETTINGS
    {
      "modulesUrl": "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_09-08-2022.zip",
      "configurationFunction": "Configuration.ps1\\AddSessionHost",
      "properties": {
        "HostPoolName":"${var.hostpool_name}"
      }
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "properties": {
      "registrationInfoToken": "${azurerm_virtual_desktop_host_pool_registration_info.hostpool_registration.token}"
    }
  }
PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [settings, protected_settings]
  }

  depends_on = [
    azurerm_virtual_machine_extension.custom_scripts
  ]
}

