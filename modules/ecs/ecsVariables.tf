variable "aws_region" {
  description = "The AWS region"
  default     = "eu-west-2"
}

variable "app_image" {
  description = "Docker image of the TDR application"
  default       = "nationalarchives/prototype-play-app:latest"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = "9000"
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = "1"
}

variable "ecs_task_execution_role" {
  description = "Role arn for the ecsTaskExecutionRole"
  default     = "arn:aws:iam::247222723249:role/ecsTaskExecutionRole"
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