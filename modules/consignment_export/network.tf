resource "aws_security_group" "consignment_export_task" {
  name        = "consignment-export-task-security-group-${var.environment}"
  description = "Security group for consignment export ECS task to use"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    map("Name", "consignment-export-task-security-group-${var.environment}")
  )
}

resource "aws_security_group_rule" "allow_export_to_pull_docker_image" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  # TODO: Can we limit this to just Docker?
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.consignment_export_task.id
}
