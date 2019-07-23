resource "aws_alb" "main" {
  name            = "tdr-app-load-balancer-${var.environment}"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb.id]

  tags = "${merge(
    var.common_tags,
    map(
      "Name", "tdr-app-loadbalancer",
      "Service", "app-loadbalancer",
      "CreatedBy", "${var.tag_created_by}"
    )
  )}"
}

resource "aws_alb_target_group" "app" {
  name        = "tdr-app-target-group"
  port        = 9000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }

  tags = "${merge(
    var.common_tags,
    map(
      "Name", "tdr-app-target-group",
      "Service", "app-target-group",
      "CreatedBy", "${var.tag_created_by}"
    )
  )}"
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.main.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.app.id
    type             = "forward"
  }
}