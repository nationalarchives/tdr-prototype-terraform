variable "common_tags" {
  description = "Set of tags that are common for all resources"
  type        = map
}

variable "environment" {
  description = "Environment resource is running in"
  type        = string
}

variable "vpc_id" {
  description = "The VPC for the API and DB"
}

variable "private_subnet" {
  description = "The private subnet for the database to run in"
  type = list(string)
}

variable "database_password" {
  type        = string
  description = "Password for the RDS database user"
}
