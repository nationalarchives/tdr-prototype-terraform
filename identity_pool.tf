locals {
    frontend_provider_name = "cognito-idp.${local.aws_region}.amazonaws.com/${module.frontend.user_pool_id}"
}

resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = "${local.environment}TDRIdentityPool"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = module.frontend.app_client_authenticate_id
    provider_name           = "${local.frontend_provider_name}"
    server_side_token_check = false
  }

  cognito_identity_providers {
    client_id               = module.frontend.app_client_upload_id
    provider_name           = "${local.frontend_provider_name}"
    server_side_token_check = false
  } 
}

resource "aws_cognito_identity_pool_roles_attachment" "main" {
      identity_pool_id = "${aws_cognito_identity_pool.main.id}"

      roles = {
           "authenticated"   = "arn:aws:iam::247222723249:role/Cognito_devTDRIdentityPoolAuth_Role"
           "unauthenticated" = "arn:aws:iam::247222723249:role/Cognito_devTDRIdentityPoolUnauth_Role"
      }
 }

/* 
resource "aws_iam_role" "unauth_role" {
      name = "unauth_role"     
      assume_role_policy = <<EOF
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Action": [
                        "mobileanalytics:PutEvents",
                        "cognito-sync:*"
                    ],
                    "Resource": [
                        "*"
                    ]                               
                }
            ]
        }
    EOF
 }

 resource "aws_iam_role" "auth_role" {
      name = "auth_role"      
      assume_role_policy = <<EOF
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Action": [
                        "mobileanalytics:PutEvents",
                        "cognito-sync:*",
                        "cognito-identity:*"
                    ],
                    "Resource": [
                        "*"
                        ]
                }
            ]
        }
    EOF
 } 

 resource "aws_iam_role_policy_attachment" "auth_role_attach" {
  role       = "${aws_iam_role.auth_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_cognito_identity_pool_roles_attachment" "main" {
      identity_pool_id = "${aws_cognito_identity_pool.main.id}"

      roles = {
           "authenticated"   = "${aws_iam_role.auth_role.arn}"
           "unauthenticated" = "${aws_iam_role.unauth_role.arn}"
      }
 } */