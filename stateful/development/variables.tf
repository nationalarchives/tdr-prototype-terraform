variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "enviroment" {
  description = "Application environment"
  type        = string
  default     = "dev"
}

variable "tag_prefix" {
  description = "Prefix for module tags to identify the project the module belongs to"
  type        = string
  default     = "tdr-prototype"
}