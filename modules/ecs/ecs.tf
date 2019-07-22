
resource "aws_ecs_cluster" "tdr-prototype-ecs" {
  name = "tdr-prototype-ecs-${var.environment}"

  tags = {
    Name        = var.tag_name
    Service     = "tdr_ecs"
    Environment = var.environment
    Owner       = "TDR"
    CreatedBy   = var.tag_created_by
    Terraform   = true
  }
}

 data "template_file" "tdrApplication" {
  template = file("modules/ecs/templates/tdrApplication.json.tpl")

  vars = {
    app_image      = var.app_image
    app_port       = var.app_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
  }
}

resource "aws_ecs_task_definition" "tdr-application" {
  family                   = "tdr-application"
  execution_role_arn       = "arn:aws:iam::247222723249:role/ecsTaskExecutionRole"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.tdrApplication.rendered
  task_role_arn            = "arn:aws:iam::247222723249:role/ecsTaskExecutionRole"
}

resource "aws_ecs_service" "tdr-application" {
  name                              = "tdr-application-service"
  cluster                           = aws_ecs_cluster.tdr-prototype-ecs.id
  task_definition                   = aws_ecs_task_definition.tdr-application.arn
  desired_count                     = var.app_count
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = "360"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = "tdrApplication"
    container_port   = var.app_port
  }

  depends_on = [aws_alb_listener.front_end]
}