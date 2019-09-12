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

variable "aws_region" {
  type = string
}

variable "database_availability_zones" {
  type = list(string)
}

variable "account_id" {
  description = "The account id of the user"
}

variable "user_pool_arn" {
  type        = string
  description = "The ARN of the Cognito user pool used to authenticate TDR users"
}

variable "database_password" {
  type        = string
  description = "Password for the RDS database user"
}

variable "api_parameter_base_path" {
  type        = string
  description = "Prefix for SSM parameters used by the API"
}

variable "app_image" {}

variable "app_port" {}

variable "fargate_cpu" {}

variable "fargate_memory" {}

variable "ecs_task_execution_role" {}

variable "ecs_vpc" {}

variable "ecs_public_subnet" {}

variable "ecs_private_subnet" {}

variable "lb_listener" {}

variable "app_name" {}