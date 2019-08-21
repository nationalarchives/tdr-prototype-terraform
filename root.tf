locals {
  #Ensure that developers' workspaces always default to 'dev'
  environment = lookup(var.workspace_to_environment_map, terraform.workspace, "dev")
  tag_prefix = module.global_variables.tag_prefix
  aws_region = module.global_variables.default_aws_region
  availability_zones = module.global_variables.default_availability_zones
  common_tags = map(
  "Environment", local.environment,
  "Owner", "TDR",
  "Terraform", true
  )
  ecs_vpc = module.ecs_network.ecs_vpc
  ecs_public_subnet = module.ecs_network.ecs_public_subnet
  ecs_private_subnet = module.ecs_network.ecs_private_subnet
  parameter_base_path = "/tdr/${local.environment}"
}

terraform {
  backend "s3" {
    bucket = "tdr-prototype-terraform-state"
    key = "prototype-terraform.state"
    region = "eu-west-2"
    encrypt = true
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
  aws_region = local.aws_region
  tag_name = "${local.tag_prefix}-ecs-${local.environment}"
  common_tags = local.common_tags
  ecs_vpc = local.ecs_vpc
  ecs_private_subnet = local.ecs_private_subnet
  ecs_public_subnet = local.ecs_public_subnet
}

module "virus_check" {
  source = "./modules/virus_check"

  environment = local.environment
  aws_region = local.aws_region
  tag_name = "${local.tag_prefix}-ecs-virus-check-${local.environment}"
  common_tags = local.common_tags
}

module "file_format_check" {
  source = "./modules/file_format_check"

  environment = local.environment
  aws_region = local.aws_region
  tag_name = "${local.tag_prefix}-ecs-file-format-check-${local.environment}"
  common_tags = local.common_tags
}

module "checksum_check" {
  source = "./modules/checksum_check"

  environment = local.environment
  aws_region = local.aws_region
  tag_name = "${local.tag_prefix}-ecs-checksum-check-${local.environment}"
  common_tags = local.common_tags
  ecs_vpc = local.ecs_vpc
}

module "ecs_network" {
  source = "./modules/network"
  common_tags = local.common_tags
  environment = local.environment
  app_name = "ecs"
}

module "caller" {
  source = "./modules/caller"
}

module "stepfunction" {
  source = "./modules/stepfunction"
  ecs_vpc = local.ecs_vpc
  account_id = module.caller.account_id
  environment = local.environment
  cluster_arn = module.frontend.app_cluster_arn
  ecs_private_subnet = local.ecs_private_subnet
  virus_check_task_arn = module.virus_check.virus_check_task_arn
  virus_check_container_name = module.virus_check.virus_check_container_name
  file_format_check_task_arn = module.file_format_check.file_format_check_task_arn
  file_format_check_container_name = module.file_format_check.file_format_check_container_name
  checksum_check_task_arn = module.checksum_check.checksum_check_task_arn
  checksum_check_container_name = module.checksum_check.checksum_check_container_name
  virus_check_topic_arn = module.virus_check.virus_check_topic_arn
  file_format_check_topic_arn = module.file_format_check.file_format_topic_arn
  checksum_check_topic_arn = module.checksum_check.checksum_topic_arn
  common_tags = local.common_tags
}

module "api" {
  source = "./modules/api"
  common_tags = local.common_tags
  environment = local.environment
  vpc_id = local.ecs_vpc
  private_subnet = local.ecs_private_subnet
  aws_region = local.aws_region
  database_availability_zones = local.availability_zones
  database_password = "${var.database_password}"
  api_parameter_base_path = "${local.parameter_base_path}/api"
}
