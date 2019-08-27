variable "workspace_to_environment_map" {
  type = "map"

  //Maps the Terraform workspace to the AWS environment.
  default = {
    dev  = "dev"
    test = "test"
    prod = "prod"
  }
}

variable "database_password" {
  type = "string"
}
