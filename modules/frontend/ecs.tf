resource "aws_ecs_cluster" "tdr-prototype-ecs" {
  name = "tdr-prototype-ecs-${var.environment}"

  tags = merge(
    var.common_tags,
    map("Name", var.tag_name)
  )
}

 data "template_file" "app" {
  template = file("modules/frontend/templates/tdrApplication.json.tpl")

  vars = {
    app_image       = var.app_image
    app_port        = var.app_port
    app_environment = var.environment
    fargate_cpu     = var.fargate_cpu
    fargate_memory  = var.fargate_memory
    aws_region      = var.aws_region
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.app_name}-${var.environment}"
  execution_role_arn       = aws_iam_role.frontend_ecs_execution.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.app.rendered
  task_role_arn            = aws_iam_role.frontend_ecs_task.arn

  tags = merge(
    var.common_tags,
    map("Name", "${var.app_name}-task-definition")
  )
}

resource "aws_ecs_service" "app" {
  name                              = "${var.app_name}-service-${var.environment}"
  cluster                           = aws_ecs_cluster.tdr-prototype-ecs.id
  task_definition                   = aws_ecs_task_definition.app.arn
  desired_count                     = var.app_count
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = "360"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = var.ecs_private_subnet
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = var.app_name
    container_port   = var.app_port
  }

  depends_on = [aws_alb_listener.front_end]
}

resource "aws_iam_role" "frontend_ecs_execution" {
  name = "frontend_ecs_execution_role_${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json

  tags = merge(
    var.common_tags,
    map(
      "Name", "frontend-ecs-execution-iam-role-${var.environment}",
    )
  )
}

resource "aws_iam_role" "frontend_ecs_task" {
  name = "frontend_ecs_task_role_${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json

  tags = merge(
    var.common_tags,
    map(
      "Name", "frontend-ecs-task-iam-role-${var.environment}",
    )
  )
}

data "aws_iam_policy_document" "ecs_assume_role" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions   = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "frontend_ecs_execution_ssm" {
  role       = aws_iam_role.frontend_ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "frontend_ecs_execution" {
  role       = aws_iam_role.frontend_ecs_execution.name
  policy_arn = aws_iam_policy.frontend_ecs_execution.arn
}

resource "aws_iam_policy" "frontend_ecs_execution" {
  name   = "frontend_ecs_execution_policy_${var.environment}"
  path   = "/"
  policy = data.aws_iam_policy_document.frontend_ecs_execution.json
}

data "aws_iam_policy_document" "frontend_ecs_execution" {
  statement {
    actions   = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [aws_cloudwatch_log_group.tdr_application_log_group.arn]
  }
}
