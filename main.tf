provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

//Gets the environment based on the terraform workspace if use workspace for each environment
locals {
  environment = "${lookup(var.workspace_to_environment_map, terraform.workspace, "dev")}"
}

module "cognito_admin" {
  source            = "./modules/cognito"
  cognito_user_pool = "${terraform.workspace}-${var.tag_prefix}-admin"
  tag_name          = "${terraform.workspace}-${var.tag_prefix}-admin"
}

module "cognito" {
  source            = "./modules/cognito"
  cognito_user_pool = "${terraform.workspace}-${var.tag_prefix}"
  tag_name          = "${terraform.workspace}-${var.tag_prefix}"
}

module "vpc" {
  source   = "./modules/vpc"
  vpc_name = "${terraform.workspace}-${var.tag_prefix}"
  cidr     = "10.0.0.0/17"
  tag_name = "${terraform.workspace}-${var.tag_prefix}"
}

module "stepfunction" {
  source             = "./modules/stepfunction"
  step_function_name = "${terraform.workspace}-${var.tag_prefix}"
  tag_name           = "${terraform.workspace}-${var.tag_prefix}"
}
