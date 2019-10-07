resource "aws_cloudwatch_log_group" "consignment_export_task" {
  name              = local.export_task_log_group_name
  retention_in_days = 30
}
