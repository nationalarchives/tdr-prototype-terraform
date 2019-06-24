locals {
  #Ensure that developers' workspaces always default to 'dev'
  environment = lookup(var.workspace_to_environment_map, terraform.workspace, "dev")
  tag_prefix  = module.global_variables.tag_prefix
  aws_region  = module.global_variables.default_aws_region
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
  region = local.aws_region
}

module "global_variables" {
  source = "./modules/global_variables"
}

module "cognito" {
  source = "./modules/cognito"

  cognito_user_pool = "${local.tag_prefix}-${local.environment}"
  tag_name          = "${local.tag_prefix}-authentication-${local.environment}-userpool1"
  environment       = local.environment
}

module "vpc" {
  source = "./modules/vpc"

  vpc_name = "${local.tag_prefix}-${local.environment}-vpc1"
  cidr     = "10.0.0.0/17"
  tag_name = "${local.tag_prefix}-cloud-${local.environment}-vpc1"
}

module "stepfunction" {
  source = "./modules/stepfunction"

  step_function_name = "${local.tag_prefix}-${local.environment}-stepfunc1"
  tag_name           = "${local.tag_prefix}-stepfunc-${local.environment}-sf"
  vpc_id             = module.vpc.vpc_id
}