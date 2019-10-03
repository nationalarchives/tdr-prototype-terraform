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
  parameter_base_path = "/tdr/${local.environment}"
  api_arn = "arn:aws:execute-api:eu-west-2:${module.caller.account_id}:${module.api.graphql_stage_id}/${module.api.graphql_stage_name}/POST${module.api.graphql_path}"
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
  ecs_private_subnet = module.ecs_network.ecs_private_subnet
  ecs_public_subnet = module.ecs_network.ecs_public_subnet
}

module "backend_virus_check" {
  source = "./modules/backend_checks"

  environment = local.environment
  aws_region = local.aws_region
  tag_name = "${local.tag_prefix}-ecs-virus-check-${local.environment}"
  common_tags = local.common_tags
  graphql_invoke_url = module.api.graphql_api_url
  graphql_path = module.api.graphql_path
  api_arn = local.api_arn
  account_id = module.caller.account_id
  check_name = "virus"
  image = "nationalarchives/tdr-virus-check"

}

module "backend_checksum_check" {
  source = "./modules/backend_checks"

  environment = local.environment
  aws_region = local.aws_region
  tag_name = "${local.tag_prefix}-ecs-checksum-check-${local.environment}"
  common_tags = local.common_tags
  graphql_invoke_url = module.api.graphql_api_url
  graphql_path = module.api.graphql_path
  api_arn = local.api_arn
  account_id = module.caller.account_id
  check_name = "checksum"
  image = "nationalarchives/tdr-checksum-check"

}

module "backend_file_format_check" {
  source = "./modules/backend_checks"

  environment = local.environment
  aws_region = local.aws_region
  tag_name = "${local.tag_prefix}-ecs-fileformat-check-${local.environment}"
  common_tags = local.common_tags
  graphql_invoke_url = module.api.graphql_api_url
  graphql_path = module.api.graphql_path
  api_arn = local.api_arn
  account_id = module.caller.account_id
  check_name = "fileformat"
  image = "nationalarchives/tdr-file-format-check"

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
  ecs_private_subnet = module.ecs_network.ecs_private_subnet
  virus_check_task_arn = module.backend_virus_check.backend_check_task_arn
  virus_check_container_name = module.backend_virus_check.container_name
  file_format_check_task_arn = module.backend_file_format_check.backend_check_task_arn
  file_format_check_container_name = module.backend_file_format_check.container_name
  checksum_check_task_arn = module.backend_checksum_check.backend_check_task_arn
  checksum_check_container_name = module.backend_checksum_check.container_name
  virus_check_topic_arn = module.backend_virus_check.topic_arn
  file_format_check_topic_arn = module.backend_file_format_check.topic_arn
  checksum_check_topic_arn = module.backend_checksum_check.topic_arn
  common_tags = local.common_tags
}

module "api" {
  source = "./modules/api"
  common_tags = local.common_tags
  environment = local.environment
  vpc_id = local.ecs_vpc
  aws_region = local.aws_region
  database_availability_zones = local.availability_zones
  account_id = module.caller.account_id
  user_pool_arn = module.frontend.user_pool_arn
  database_password = var.database_password
  api_parameter_base_path = "${local.parameter_base_path}/api"
  app_image = "nationalarchives/sangria"
  app_port = 8080
  ecs_public_subnet = module.ecs_network.ecs_public_subnet
  ecs_private_subnet = module.ecs_network.ecs_private_subnet
  ecs_task_execution_role = "arn:aws:iam::247222723249:role/ecsTaskExecutionRole"
  ecs_vpc = local.ecs_vpc
  fargate_cpu = 1024
  fargate_memory = 2048
  lb_listener = module.frontend.load_balancer_listener
  app_name = "sangria-graphql"
  export_task_id = module.consignment_export.task_id
  export_container_id = module.consignment_export.container_id
  export_cluster_arn = module.consignment_export.cluster_arn
  export_security_group_id = module.consignment_export.security_group_id
}

module "consignment_export" {
  source = "./modules/consignment_export"
  common_tags = local.common_tags
  environment = local.environment
  vpc_id = local.ecs_vpc
  aws_region = local.aws_region
  api_arn = local.api_arn
  graphql_invoke_url = module.api.graphql_api_url
  graphql_path = module.api.graphql_path
  consignment_file_bucket_arn = module.stepfunction.upload_bucket_arn
}
