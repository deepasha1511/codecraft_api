variable "resource_group_name" {
  description = "Name of the resource group"
  default     = "codecraft-rg"
}

variable "location" {
  description = "Azure region"
  default     = "eastus"
}

variable "acr_name" {
  description = "Azure Container Registry name"
  default     = "codecraftacr"
}

variable "aks_cluster_name" {
  description = "AKS cluster name"
  default     = "codecraft-aks"
}

variable "aks_dns_prefix" {
  description = "AKS DNS prefix"
  default     = "codecraftaks"
}
