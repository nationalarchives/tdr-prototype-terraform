# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "tdr_file_format_check_log_group" {
  name              = "/ecs/tdr-file-format-check-${var.environment}"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_stream" "tdr_application_log_stream" {
  name           = "/ecs/tdr-file-format-check-${var.environment}"
  log_group_name = aws_cloudwatch_log_group.tdr_file_format_check_log_group.name
}