variable "common_tags" {
  description = "Set of tags that are common for all resources"
  type        = map(string)
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

variable "app_name" {
  type = string
}

variable "environment" {
  description = "Environment resource is running in"
  type        = string
  default     = "dev"
}


