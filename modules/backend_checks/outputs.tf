output "backend_check_task_arn" {
  value = aws_ecs_task_definition.checksum_check.arn
}

output "container_name" {
  value = "${var.container_name}-${var.environment}"
}

output "topic_arn" {
  value = aws_sns_topic.backend_check_result.arn
}