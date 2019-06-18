output "user_pool_id" {
  value = aws_cognito_user_pool.pool.id
}

output "file_validation_app_client_secret" {
  value = aws_cognito_user_pool_client.FileValidationApp.client_secret
}

