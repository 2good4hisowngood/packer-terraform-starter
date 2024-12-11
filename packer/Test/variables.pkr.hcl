locals {
  disk_encryption_set_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.rgName}/providers/Microsoft.Compute/diskEncryptionSets/${var.acgName}-des"
}

variable "rgName" {
  type    = string
  default = "rg-acg-test"
}

variable "acgName" {
  type    = string
  default = "acgDemo"
}

variable "image_name" {
  type    = string
  default = "WindowsImage"
}

variable "build_key_vault_name" {
  type    = string
  default = "kv-demo"
}

variable "build_revision" {
  type    = string
  default = "001"
}

variable "image_offer" {
  type    = string
  default = "WindowsServer"
}

variable "image_publisher" {
  type    = string
  default = "MicrosoftWindowsServer"
}

variable "image_sku" {
  type    = string
  default = "2022-datacenter-g2"
}

variable "temp_os_disk_name" {
  type    = string
  default = "osDisk001"
}

variable "destination_image_version" {
  type    = string
  default = "1.0.0"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "vmSize" {
  type    = string
  default = "Standard_DS3_V2"
}

variable "subscription_id" {
  type    = string
  sensitive = false
  default = "<REPLACE_WITH_YOUR_SUBSCRIPTION_ID>" # You need to have a default value despite using a pkr_var_value to pass the value in.
}

variable "tenant_id" {
  type    = string
  sensitive = true
  default = "<REPLACE_WITH_YOUR_TENANT_ID>" # You need to have a default value despite using a pkr_var_value to pass the value in.
}

variable "client_id" {
  type    = string
  sensitive = true
  default = "<REPLACE_WITH_YOUR_CLIENT_ID>" # You need to have a default value despite using a pkr_var_value to pass the value in.
}

variable "client_secret" {
  type    = string
  sensitive = true
  default = "<REPLACE_WITH_YOUR_CLIENT_SECRET>" # You need to have a default value despite using a pkr_var_value to pass the value in.
}

variable "Release" {
  type    = string
  default = "COOL"
}




