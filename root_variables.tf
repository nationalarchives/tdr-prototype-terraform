variable "workspace_to_environment_map" {
  type = "map"

  default = {
    dev  = "dev"
    test = "test"
    prod = "prod"
  }
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "tag_prefix" {
  description = "Prefix for module tags to identify the project the module belongs to"
  type        = string
  default     = "tdr-prototype"
}