# Traffic to the ECS cluster should only come from the application load balancer
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.app_name}-ecs-tasks-security-group"
  description = "Allow inbound access from the TDR application load balancer only"
  vpc_id      = var.ecs_vpc

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
  var.common_tags,
  map(
  "Name", "${var.app_name}-ecs-task-security-group",
  "CreatedBy", var.tag_created_by
  )
  )
}