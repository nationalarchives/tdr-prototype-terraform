output "virus_check_task_arn" {
  value = aws_ecs_task_definition.virus_check.arn
}

output "virus_check_container_name" {
  value = "${var.container_name}-${var.environment}"
}

output "virus_check_topic_arn" {
  value = aws_sns_topic.virus_check_result.arn
}