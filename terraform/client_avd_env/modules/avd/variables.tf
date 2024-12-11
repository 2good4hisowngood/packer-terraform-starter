variable "rg_name" {
  description = "The name of the resource group"
  type        = string
  default     = "my-resource-group"
}

variable "rg_location" {
  description = "The location of the resource group"
  type        = string
  default     = "East US"
}

variable "hostpool_name" {
  description = "The name of the host pool"
  type        = string
  default     = "my-hostpool"
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "my-vnet"
}

variable "address_space" {
  description = "The address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_prefixes" {
  description = "The subnet prefixes for the virtual network"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "vm_size" {
  description = "The size of the virtual machines"
  type        = string
  default     = "Standard_B2ms"
}

variable "vm_count" {
  description = "The number of virtual machines"
  type        = number
  default     = 2
}

variable "admin_username" {
  description = "The admin username for the virtual machines"
  type        = string
  default     = "adminuser"
}

variable "admin_password" {
  description = "The admin password for the virtual machines"
  type        = string
  sensitive   = true
  default     = "P@ssw0rd1234"
}

variable "image_name" {
  description = "The name of the image"
  type        = string
  default     = "WindowsImage"
}

variable "acg_rg_name" {
  description = "The name of the resource group for the shared image gallery"
  type        = string
  default     = "rg-acg-test"
}

variable "acgName" {
  description = "The name of the shared image gallery"
  type        = string
  default     = "acgDemo"
}

variable "rg_id" {
  description = "The ID of the resource group to assign the roles to"
  type        = string
}

variable "random_name" {
  description = "The random name for the storage account"
  type        = string  
}

variable "current_client" {
  description = "The current client configuration"
  type        = any
}