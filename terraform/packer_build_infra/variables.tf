variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-acg-test"
}

variable "location" {
  description = "The location where the resources will be deployed"
  type        = string
  default     = "East US"
}

variable "image_gallery_name" {
  description = "The name of the shared image gallery"
  type        = string
  default     = "acgDemo"
}

# variable "key_vault_name" {
#   description = "The name of the key vault"
#   type        = string
#   default     = "kv-demo"  
# }

variable "tags" {
  description = "Tags to be applied to the resources"
  type        = map(string)
  default     = {
    Hello = "There"
    World = "Example"
  }
}