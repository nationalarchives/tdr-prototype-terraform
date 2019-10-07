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

variable "aws_region" {
  type = string
}

variable "api_arn" {
  description = "ARN of API Gateway URL of the TDR API"
  type        = string
}

variable "consignment_file_bucket_arn" {
  description = "ARN of the bucket containing the files to be exported"
  type        = string
}

variable "graphql_invoke_url" {
  description = "The url for the graphql server"
}

variable "graphql_path" {
  description = "The graphql path"
}
