# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "tdrApplication_log_group" {
  name              = "/ecs/tdrApplication"
  retention_in_days = 30

  tags = {
    Name = "tdrApplication-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "tdrApplication_log_stream" {
  name           = "tdrApplication-log-stream"
  log_group_name = aws_cloudwatch_log_group.tdrApplication_log_group.name
}