resource "aws_cloudwatch_log_group" "database_migration_task" {
  name              = local.export_task_log_group_name
  retention_in_days = 30
}
