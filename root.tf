locals {
  #Ensure that developers' workspaces always default to 'dev'
  environment = lookup(var.workspace_to_environment_map, terraform.workspace, "test")
  tag_prefix  = module.global_variables.tag_prefix
  aws_region  = module.global_variables.default_aws_region
  common_tags = map(
    "CreatedBy", module.caller.caller_arn,
    "Environment", local.environment,
    "Owner", "TDR",
    "Terraform", true
  )
  ecs_vpc = module.ecs_network.ecs_vpc
  ecs_public_subnet = module.ecs_network.ecs_public_subnet
  ecs_private_subnet = module.ecs_network.ecs_private_subnet
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

module "frontend" {
  source = "./modules/frontend"

  environment = local.environment
  aws_region  = local.aws_region
  tag_name    = "${local.tag_prefix}-ecs-${local.environment}"
  common_tags = local.common_tags
  ecs_vpc = local.ecs_vpc
  ecs_private_subnet = local.ecs_private_subnet
  ecs_public_subnet = local.ecs_public_subnet
}

module "virus_check" {
  source = "./modules/virus_check"

  environment = local.environment
  aws_region  = local.aws_region
  tag_name    = "${local.tag_prefix}-ecs-virus-check-${local.environment}"
  common_tags = local.common_tags
}

module "file_format_check" {
  source = "./modules/file_format_check"

  environment = local.environment
  aws_region  = local.aws_region
  tag_name    = "${local.tag_prefix}-ecs-file-format-check-${local.environment}"
  common_tags = local.common_tags
}

module "checksum_check" {
  source = "./modules/checksum_check"

  environment = local.environment
  aws_region  = local.aws_region
  tag_name    = "${local.tag_prefix}-ecs-checksum-check-${local.environment}"
  common_tags = local.common_tags
  ecs_vpc = local.ecs_vpc
}

module "ecs_network" {
  source = "./modules/network"
  common_tags = local.common_tags
  app_name = "ecs"
}

module "caller" {
  source = "./modules/caller"
}

/* module "security" {
  source = "./modules/security"
  app_port = module.ecs.app_port
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
} */