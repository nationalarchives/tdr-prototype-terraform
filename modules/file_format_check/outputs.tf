output "file_format_check_task_arn" {
  value = aws_ecs_task_definition.file_format_check.arn
}

output "file_format_check_container_name" {
  value = "${var.container_name}-${var.environment}"
}

output "file_format_topic_arn" {
  value = aws_sns_topic.file_format_check_result.arn
}