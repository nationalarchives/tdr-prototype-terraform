variable "tag_name" {
  description = "Tag name for resource"
  type        = string
}

variable "environment" {
  description = "Environment resource is running in"
  type        = string
  default     = "dev"
}

variable "cognito_user_pool" {
  description = "The name of the user pool"
  type        = string
}