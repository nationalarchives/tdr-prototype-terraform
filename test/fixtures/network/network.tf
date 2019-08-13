provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "all" {}

module "network" {
    source = "../../../modules/network"
    app_name = "kitchen"
    common_tags = map(
      "CreatedBy", "Kitchen-Terraform",
      "Environment", "kitchen",
      "Owner", "TDR",
      "Terraform", true
    )
}