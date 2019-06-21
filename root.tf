locals {
  environment = lookup(var.workspace_to_environment_map, terraform.workspace, "dev")
}

terraform {
  backend "s3" {
    bucket         = "tdr-prototype-terraform-state"
    key            = "prototype-terraform.state"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "tdr-prototype-terraform-statelock"
  }
}

provider "aws" {
  region = var.region
}

module "cognito" {
  #Source will be the module github repository
  source = "./modules/cognito"

  cognito_user_pool = "${var.tag_prefix}-${local.environment}"
  tag_name          = "${var.tag_prefix}-authentication-${local.environment}-userpool1"
  environment       = local.environment
}