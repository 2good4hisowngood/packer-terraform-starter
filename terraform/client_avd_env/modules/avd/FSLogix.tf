# FSLogix requires a storage account to store the profile containers. This module creates the storage account and the required resources for FSLogix. 
# https://learn.microsoft.com/en-us/azure/virtual-desktop/fslogix-profile-containers
# https://learn.microsoft.com/en-us/fslogix/how-to-configure-profile-container-azure-ad

# The Storage Account needs to be entra joined.
resource "azurerm_storage_account" "storage" {
  name                = "filestorage${var.random_name}"
  resource_group_name = var.rg_name
  location            = var.rg_location

  account_tier                  = "Standard"
  account_kind                  = "StorageV2"
  account_replication_type      = "LRS"
  https_traffic_only_enabled    = true
  access_tier                   = "Hot"
  public_network_access_enabled = true
  min_tls_version               = "TLS1_2"

  azure_files_authentication {
    directory_type = "AADKERB"
  }
}

# A file share will need to be created in the storage account to store the profile containers.
resource "azurerm_storage_share" "fslogix_share" {
  name               = "fslogix"
  storage_account_id = azurerm_storage_account.storage.id
  quota              = 1024
}

# The storage account will need to have a role assignment to allow the Users to access the storage account.
data "azurerm_role_definition" "vm_admin_script_role" {
  name = "Storage Blob Data Contributor"
}

resource "azurerm_role_assignment" "script_role" {
  scope              = azurerm_storage_account.storage.id
  role_definition_id = data.azurerm_role_definition.vm_admin_script_role.id
  principal_id       = var.current_client.object_id
}

# This storage account will hold scripts that will be used to configure the VMs.
resource "azurerm_storage_account" "scripts" {
  name                = "scripts${var.random_name}"
  resource_group_name = var.rg_name
  location            = var.rg_location

  account_tier                  = "Standard"
  account_kind                  = "StorageV2"
  account_replication_type      = "LRS"
  https_traffic_only_enabled    = true
  access_tier                   = "Hot"
  public_network_access_enabled = true
  min_tls_version               = "TLS1_2"

  depends_on = [
    azurerm_storage_account.storage
  ]
}

resource "azurerm_storage_container" "scripts" {
  name                  = "scripts"
  storage_account_id  = azurerm_storage_account.scripts.id
  container_access_type = "private"
  depends_on = [
    azurerm_role_assignment.script_role
  ]
}

resource "time_sleep" "container_rbac" {
  create_duration = "20s"

  triggers = {
    scope = azurerm_role_assignment.script_role.scope
    name  = azurerm_storage_container.scripts.name
    setup_host_content = data.template_file.setup_host.rendered
  }

  depends_on = [
    azurerm_storage_account.scripts,
    azurerm_storage_account.storage,
    azurerm_role_assignment.script_role
  ]
}

data "template_file" "setup_host" {
  template = file("${path.module}//setup-host.ps1")

  vars = {
    storageAccountName = azurerm_storage_account.storage.name
    storageAccountKey  = azurerm_storage_account.storage.primary_access_key
  }
}

resource "azurerm_storage_blob" "setup_host" {
  name                   = "setup-host.ps1"
  storage_account_name   = azurerm_storage_account.scripts.name
  storage_container_name = time_sleep.container_rbac.triggers["name"]
  type                   = "Block"
  source_content         = time_sleep.container_rbac.triggers["setup_host_content"] #"${path.module}//scripts//setup-host.ps1"
  depends_on = [
    azurerm_role_assignment.script_role,
    data.template_file.setup_host,
    time_sleep.container_rbac
  ]
}