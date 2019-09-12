output "app_port" {
  value = var.app_port
}

output "alb_hostname" {
  value = aws_alb.main.dns_name
}

output "user_pool_arn" {
  value = aws_cognito_user_pool.pool.arn
}

output "app_client_authenticate_id" {
  value = aws_cognito_user_pool_client.authenticate.id
}

output "app_client_upload_id" {
  value = aws_cognito_user_pool_client.upload.id
}

output "app_cluster_arn" {
  value = aws_ecs_cluster.tdr-prototype-ecs.arn
}

output "load_balancer_listener" {
  value = aws_alb_listener.front_end_tls.arn
}