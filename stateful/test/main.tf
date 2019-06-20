terraform {
  backend "s3" {
    bucket         = "tdr-prototype-terraform-state"
    key            = "prototype-terraform/stateful/test/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "terraform-statelock-tdr-prototype"
  }
}

provider "aws" {
  region = var.region
}

module "cognito" {
  #Source will be the module github repository
  source = "../../modules/cognito"

  cognito_user_pool = "${var.tag_prefix}-${var.enviroment}"
  tag_name          = "${var.tag_prefix}-authentication-${var.enviroment}-userpool1"
  environment       = var.enviroment
}

module "vpc" {
  #Source will be the module github repository
  source = "../../modules/vpc"

  vpc_name = "${var.tag_prefix}-${var.enviroment}-vpc1"
  cidr     = "10.0.0.0/17"
  tag_name = "${var.tag_prefix}-cloud-${var.enviroment}-vpc1"
}

module "stepfunction" {
  #Source will be the module github repository
  source = "../../modules/stepfunction"

  step_function_name = "${var.tag_prefix}-${var.enviroment}-stepfunc1"
  tag_name           = "${var.tag_prefix}-stepfunc-${var.enviroment}-sf"
  vpc_id             = module.vpc.vpc_id
}