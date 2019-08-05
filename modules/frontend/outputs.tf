output "app_port" {
  value = var.app_port
}

output "alb_hostname" {
  value = aws_alb.main.dns_name
}