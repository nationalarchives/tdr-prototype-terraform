
resource "aws_cognito_user_pool" "pool" {
  name = "${var.cognito_user_pool}"

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  password_policy {
    minimum_length = "8"
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  tags = {
    Name = "${var.tag_name}"
  }
}

resource "aws_cognito_user_pool_client" "TransferDigitalRecordsApp" {
  name = "TransferDigitalRecordsApp"
  user_pool_id = "${aws_cognito_user_pool.pool.id}"
  refresh_token_validity = "30"
  generate_secret = false
}

resource "aws_cognito_user_pool_client" "FileValidationApp" {
  name = "FileValidationApp"
  user_pool_id = "${aws_cognito_user_pool.pool.id}"
  refresh_token_validity = "30"
  generate_secret = true
}

resource "aws_cognito_user_pool_client" "TestSignIn" {
  name = "Test Sign in"
  user_pool_id = "${aws_cognito_user_pool.pool.id}"
  refresh_token_validity = "30"
  generate_secret = false
}