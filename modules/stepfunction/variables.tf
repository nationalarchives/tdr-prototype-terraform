variable "cluster_arn" {
  description = "VPC id value"
  type        = string
}

variable "ecs_private_subnet" {
  description = "The private subnet for the task to run in"
  type = list(string)
}

variable "virus_check_task_arn" {
  description = "The arn for the virus check task"
  type = string
}

variable "environment" {
  description = "The environment"
}

variable "ecs_vpc" {
  description = "The VPC for the ECS tasks"
}

variable "common_tags" {
  description = "The tags which all resources must use"
}

variable "virus_check_container_name" {
  description = "The container name of the virus check ecs task"
}

variable "file_format_check_task_arn" {
  description = "The arn for the file format check task"
}

variable "file_format_check_container_name" {
  description = "The container name of the file format check ecs task"
}

variable "checksum_check_task_arn" {
  description = "The arn for the checksum check task"
}

variable "checksum_check_container_name" {
  description = "The container name of the checksum check ecs task"
}

variable "virus_check_topic_arn" {
  description = "The SNS topic to send updates to once the step function completes the virus check"
}

variable "file_format_check_topic_arn" {
  description = "The SNS topic to send updates to once the step function completes the file format check"
}

variable "checksum_check_topic_arn" {
  description = "The SNS topic to send updates to once the step function completes the checksum check"
}