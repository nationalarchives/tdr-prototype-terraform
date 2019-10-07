output "task_id" {
  value = aws_ecs_task_definition.run_consignment_export.family
}

output "container_id" {
  value = local.container_name
}

output "cluster_arn" {
  value = aws_ecs_cluster.consignment_export.arn
}

output "security_group_id" {
  value = aws_security_group.consignment_export_task.id
}
