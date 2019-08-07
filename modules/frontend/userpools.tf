locals {
    cdn_domain_name = aws_cloudfront_distribution.web_distribution.domain_name
}

resource "aws_cognito_user_pool" "pool" {
  name = "${var.app_name}-transfer-records-${var.environment}"

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  password_policy {
    minimum_length    = "8"
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  auto_verified_attributes = ["email"]

  #Standard required attributes
  #Please note all attribute schemas must EXPLICITLY define all the properties below to prevent resource replacement.
  #See: https://www.terraform.io/docs/providers/aws/r/cognito_user_pool.html#string_attribute_constraints
  schema {
    attribute_data_type      = "String"
    name                     = "email"
    required                 = true
    developer_only_attribute = false
    mutable                  = false
    
    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }

  #Custom attributes   
  schema {
    attribute_data_type      = "String"
    name                     = "department_id"
    required                 = false
    developer_only_attribute = false
    mutable                  = false
    
    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }

  schema {
    attribute_data_type      = "String"
    name                     = "department"
    required                 = false
    developer_only_attribute = false
    mutable                  = false
    
    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }

  tags = merge(
    var.common_tags,
    map(
      "Name", "${var.app_name}-user-pool-${var.environment}",      
      "CreatedBy", var.username
    )
  )
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "tdr-${var.environment}"
  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "aws_cognito_resource_server" "resource" {
  identifier = "tdr-${var.environment}"
  name       = "tdr-resource-server-${var.environment}"

  scope {
    scope_name        = "validate"
    scope_description = "Allows validation"
  }

  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "aws_cognito_user_pool_client" "authenticate" {
  name                                = "Authenticate"
  user_pool_id                        = aws_cognito_user_pool.pool.id
  refresh_token_validity               = "30"
  generate_secret                      = true
  explicit_auth_flows                  = ["ADMIN_NO_SRP_AUTH"]
  callback_urls                        = ["https://${local.cdn_domain_name}/authenticate/cognito"]
  supported_identity_providers         = ["COGNITO"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["aws.cognito.signin.user.admin", "email", "openid", "profile"]
  allowed_oauth_flows                  = ["code"]  
  
  #Spaces are not permitted in attribute names, use underscores instead, in the AWS console these display as spaces
  read_attributes = ["address", "birthdate", "email", "email_verified", "family_name", 
    "gender", "given_name", "locale", "middle_name", "name", "nickname", "phone_number",
    "phone_number_verified", "picture", "preferred_username", "profile", "zoneinfo", 
    "updated_at", "website"]
  write_attributes = ["address", "birthdate", "email", "family_name", 
    "gender", "given_name", "locale", "middle_name", "name", "nickname", "phone_number",
    "picture", "preferred_username", "profile", "zoneinfo", "updated_at", "website"]
}

resource "aws_cognito_user_pool_client" "upload" {
  name                                 = "Upload"
  user_pool_id                         = aws_cognito_user_pool.pool.id
  refresh_token_validity               = "30"
  generate_secret                      = false
  callback_urls                        = ["https://${local.cdn_domain_name}/upload"]
  supported_identity_providers         = ["COGNITO"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["openid", "profile"]
  allowed_oauth_flows                  = ["code"]  
  
  #Spaces are not permitted in attribute names, use underscores instead, in the AWS console these display as spaces
  read_attributes = ["address", "birthdate", "email", "email_verified", "family_name", 
    "gender", "given_name", "locale", "middle_name", "name", "nickname", "phone_number",
    "phone_number_verified", "picture", "preferred_username", "profile", "zoneinfo", 
    "updated_at", "website"]
  write_attributes = ["address", "birthdate", "email", "family_name", 
    "gender", "given_name", "locale", "middle_name", "name", "nickname", "phone_number",
    "picture", "preferred_username", "profile", "zoneinfo", "updated_at", "website"]
}