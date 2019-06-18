variable "access_key" {
  description = "AWS access key"
  type        = string
}

variable "secret_key" {
  description = "AWS secret key"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "tag_prefix" {
  description = "Prefix for module tags to identify the project the module belongs to"
  type        = string
}

variable "workspace_to_environment_map" {
  type = map

  default = {
    dev     = "dev"
    qa      = "qa"
    staging = "staging"
    prod    = "prod"
  }
}