resource "aws_alb" "main" {
  name            = "tdr-app-load-balancer-${var.environment}"
  subnets         = var.ecs_public_subnet
  security_groups = [aws_security_group.lb.id]

  tags = merge(
    var.common_tags,
    map("Name", "${var.app_name}-loadbalancer")
  )
}

resource "aws_alb_target_group" "app" {
  name        = "tdr-app-target-group-${var.environment}"
  port        = 9000
  protocol    = "HTTP"
  vpc_id      = var.ecs_vpc
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200,303"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }

  tags = merge(
    var.common_tags,
    map("Name", "${var.app_name}-target-group")
  )
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

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end_tls" {
  load_balancer_arn = aws_alb.main.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn = "arn:aws:acm:eu-west-2:247222723249:certificate/b82358e0-f0d9-489d-81b3-6300343cf21a"

  default_action {
    target_group_arn = aws_alb_target_group.app.id
    type             = "forward"
  }
}
