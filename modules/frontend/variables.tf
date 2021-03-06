variable "common_tags" {
  description = "Set of tags that are common for all resources"
  type        = map(string)
}

variable "tag_name" {
  type    = string
  default = "tdr-ecs"
}

variable "tag_service" {
  type    = string
  default = "tdr-ecs"
}

variable "environment" {
  description = "Environment resource is running in"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "The AWS region"
  default     = "eu-west-2"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

variable "app_image" {
  description   = "Docker image of the TDR application"
  default       = "docker.io/nationalarchives/prototype-play-app"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = "9000"
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = "1"
}

variable "app_name" {
  description = "Name of the hosted application"
  type        = string
  default     = "tdr-application"
}

variable "health_check_path" {
  default = "/"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "2048"
}

variable "ecs_vpc" {
  description = "The VPC for the application"
}

variable "ecs_private_subnet" {
  description = "The private subnet for the application"
}

variable "ecs_public_subnet" {
  description = "The public subnet for the application"
}
