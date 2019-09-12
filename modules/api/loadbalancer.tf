resource "aws_alb" "main" {
  name            = "tdr-graphql-load-balancer-${var.environment}"
  subnets         = var.ecs_public_subnet
  load_balancer_type = "network"
  tags = merge(
  var.common_tags,
  map("Name", "${var.app_name}-loadbalancer")
  )
}

resource "random_string" "alb_prefix" {
  length  = 4
  upper   = false
  special = false
}

resource "aws_alb_target_group" "graphql" {
  name        = "graphql-target-group-${random_string.alb_prefix.result}-${var.environment}"
  port        = 8080
  protocol    = "TCP"
  vpc_id      = var.ecs_vpc
  target_type = "ip"
  stickiness {
    enabled = false
    type = "lb_cookie"
  }

  tags = merge(
  var.common_tags,
  map("Name", "${var.app_name}-target-group")
  )
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "graphql" {
  load_balancer_arn = aws_alb.main.id
  port              = "80"
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_alb_target_group.graphql.id
    type             = "forward"
  }
}

resource "aws_alb_listener" "graphql_tls" {
  load_balancer_arn = aws_alb.main.id
  port              = "443"
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn = "arn:aws:acm:eu-west-2:247222723249:certificate/b82358e0-f0d9-489d-81b3-6300343cf21a"

  default_action {
    target_group_arn = aws_alb_target_group.graphql.id
    type             = "forward"
  }
}
