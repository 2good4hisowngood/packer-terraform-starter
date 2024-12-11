variable "rg_name" {
  description = "The name of the resource group"
  type        = string
  default     = "my-rg"
}

variable "rg_location" {
  description = "The location of the resource group"
  type        = string
  default     = "East US"
}

variable "hostpool_name" {
  description = "The name of the host pool"
  type        = string
  default     = "avd-hp"
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
  default     = "Standard_DS1_v2"
}

variable "vm_count" {
  description = "The number of virtual machines"
  type        = number
  default     = 1
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
