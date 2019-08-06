locals {
    frontend_provider_name = "cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.pool.id}"     
}

resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = "${var.environment}TDRIdentityPool"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.authenticate.id
    provider_name           = "${local.frontend_provider_name}"
    server_side_token_check = false
  }

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.upload.id
    provider_name           = "${local.frontend_provider_name}"
    server_side_token_check = false
  } 
}

resource "aws_cognito_identity_pool_roles_attachment" "main" {
      identity_pool_id = "${aws_cognito_identity_pool.main.id}"

      roles = {
           authenticated   = aws_iam_role.authenticated.arn
           unauthenticated = aws_iam_role.unauthenticated.arn
        }
 }

 resource "aws_iam_role" "authenticated" {
     name = "${var.environment}_Cognito_TDRIdentityPoolAuth_Role"     
    
     assume_role_policy = <<EOF
{
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "Federated": "cognito-identity.amazonaws.com"
                    },
                    "Action": "sts:AssumeRoleWithWebIdentity",
                    "Condition": {
                    "StringEquals": {
                            "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.main.id}"
                        },
                        "ForAnyValue:StringLike": {
                            "cognito-identity.amazonaws.com:amr": "authenticated"
                        }
                    }
                }
            ]
    }
    EOF

    tags = "${merge(
        var.common_tags,
        map(
          "Name", "${var.tag_name}",      
          "CreatedBy", "${var.tag_created_by}"
        )
    )}"
 }

 resource "aws_iam_role" "unauthenticated" {
      name = "${var.environment}_Cognito_TDRIdentityPoolUnauth_Role"     
      assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.main.id}"
        },
        "ForAnyValue:StringLike": {
          "cognito-identity.amazonaws.com:amr": "unauthenticated"
        }
      }
    }
  ]
}
    EOF

    tags = "${merge(
        var.common_tags,
        map(
          "Name", "${var.tag_name}",      
          "CreatedBy", "${var.tag_created_by}"
        )
    )}"
 }

/* Generate policies */
 data "aws_iam_policy_document" "oneClick_Auth_Role" {
     version = "2012-10-17"
     statement {
         effect = "Allow"
         actions = [
             "mobileanalytics:PutEvents",
             "cognito-sync:*",
             "cognito-identity:*"
        ]
        resources = [
            "*"
        ]
     }
 }

 resource "aws_iam_policy" "oneClick_Cognito_TDRIdentityPoolAuth_Role" {
     name = "oneClick_Cognito_TDRIdentityPoolAuth_Role"
     path = "/"
     policy = "${data.aws_iam_policy_document.oneClick_Auth_Role.json}"
 }

/* Attach policies to IAM roles */
resource "aws_iam_role_policy_attachment" "auth_role_attach-s3Access" {
  role       = "${aws_iam_role.authenticated.name}"  
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "auth_role_attach-oneClick" {
  role       = "${aws_iam_role.authenticated.name}"  
  policy_arn = "${aws_iam_policy.oneClick_Cognito_TDRIdentityPoolAuth_Role.arn}"
}

resource "aws_iam_role_policy_attachment" "unauth_role_attach-oneClick" {
  role       = "${aws_iam_role.unauthenticated.name}"  
  policy_arn = "${aws_iam_policy.oneClick_Cognito_TDRIdentityPoolAuth_Role.arn}"
}