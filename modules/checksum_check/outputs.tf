output "checksum_check_task_arn" {
  value = aws_ecs_task_definition.checksum_check.arn
}

output "checksum_check_container_name" {
  value = "${var.container_name}-${var.environment}"
}

output "checksum_topic_arn" {
  value = aws_sns_topic.checksum_check_result.arn
}