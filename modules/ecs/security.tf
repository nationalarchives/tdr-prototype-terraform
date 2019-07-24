# ALB Security Group: Edit to restrict access to the application
resource "aws_security_group" "lb" {
  name        = "${var.app_name}-load-balancer-security-group"
  description = "Controls access to the TDR application load balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(
    var.common_tags,
    map(
      "Name", "${var.app_name}-load-balancer-security-group",      
      "CreatedBy", "${var.tag_created_by}"
    )
  )}"
}

# Traffic to the ECS cluster should only come from the application load balancer
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.app_name}-ecs-tasks-security-group"
  description = "Allow inbound access from the TDR application load balancer only"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol        = "tcp"
    from_port       = var.app_port
    to_port         = var.app_port
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(
    var.common_tags,
    map(
      "Name", "${var.app_name}-ecs-task-security-group",      
      "CreatedBy", "${var.tag_created_by}"
    )
  )}"
}
