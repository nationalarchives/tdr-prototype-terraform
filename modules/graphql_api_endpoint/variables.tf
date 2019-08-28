variable "aws_region" {
  description = "The AWS region"
  default     = "eu-west-2"
}

variable "environment" {
  description = "Environment resource is running in"
  type        = string
}

variable "account_id" {
  description = "The account id of the user"
  type        = string
}

variable "rest_api_id" {
  description = "The ID of the API Gateway REST API definition"
  type        = string
}

variable "relative_path" {
  description = "The path of the endpoint, relative to its parent resource"
  type        = string
}

variable "parent_resource_id" {
  description = "The ID of this module's API Gateway parent resource"
  type        = string
}

variable "authorization_type" {
  type        = string
  default     = "NONE"
}

variable "authorizer_id" {
  description = "The ID of the API Gateway authorizer"
  type        = string
  default     = ""
}

variable "lambda_arn" {
  description = "The ARN of the Lambda function that backs this API endpoint"
  type        = string
}

variable "lambda_name" {
  description = "The name of the Lambda function that backs this API endpoint"
  type        = string
}
