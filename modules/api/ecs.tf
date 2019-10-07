resource "aws_ecs_cluster" "tdr_graphql_ecs" {
  name = "tdr-graphql-ecs-${var.environment}"

  tags = merge(
  var.common_tags,
  map("Name", "tdr-graphql-ecs-${var.environment}")
  )
}

data "template_file" "app" {
  template = file("modules/api/templates/graphql.json.tpl")

  vars = {
    app_image                = "${var.app_image}:${var.environment}"
    app_port                 = 8080
    app_environment          = var.environment
    aws_region               = var.aws_region
    url_path                 = local.database_parameter_keys.url
    username_path            = local.database_parameter_keys.username
    password_path            = local.database_parameter_keys.password
    export_task_id           = var.export_task_id
    export_container_id      = var.export_container_id
    export_cluster_arn       = var.export_cluster_arn
    export_security_group_id = var.export_security_group_id
    export_subnet_id         = var.ecs_private_subnet[0]
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.app_name}-${var.environment}"
  execution_role_arn       = aws_iam_role.api_ecs_execution.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.app.rendered
  task_role_arn            = aws_iam_role.api_ecs_task.arn

  tags = merge(
  var.common_tags,
  map("Name", "${var.app_name}-task-definition")
  )
}

resource "aws_ecs_service" "app" {
  name                              = "${var.app_name}-service-${var.environment}"
  cluster                           = aws_ecs_cluster.tdr_graphql_ecs.id
  task_definition                   = aws_ecs_task_definition.app.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = "360"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = var.ecs_private_subnet
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.graphql.id
    container_name   = var.app_name
    container_port   = var.app_port
  }
}

# Traffic to the ECS cluster should only come from the application load balancer
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.app_name}-ecs-tasks-security-group"
  description = "Allow inbound access from the TDR application load balancer only"
  vpc_id      = var.ecs_vpc

  ingress {
    protocol        = "tcp"
    from_port       = var.app_port
    to_port         = var.app_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
  var.common_tags,
  map("Name", "${var.app_name}-ecs-task-security-group-${var.environment}")
  )
}

resource "aws_iam_role" "api_ecs_execution" {
  name = "api_ecs_execution_role_${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json

  tags = merge(
    var.common_tags,
    map(
      "Name", "api-ecs-execution-iam-role-${var.environment}",
    )
  )
}

resource "aws_iam_role" "api_ecs_task" {
  name = "api_ecs_task_role_${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json

  tags = merge(
    var.common_tags,
    map(
      "Name", "api-ecs-task-iam-role-${var.environment}",
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

resource "aws_iam_role_policy_attachment" "api_ecs_execution_ssm" {
  role       = aws_iam_role.api_ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "api_ecs_execution" {
  role       = aws_iam_role.api_ecs_execution.name
  policy_arn = aws_iam_policy.api_ecs_execution.arn
}

resource "aws_iam_policy" "api_ecs_execution" {
  name   = "api_ecs_execution_policy_${var.environment}"
  path   = "/"
  policy = data.aws_iam_policy_document.api_ecs_execution.json
}

data "aws_iam_policy_document" "api_ecs_execution" {
  statement {
    actions   = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [aws_cloudwatch_log_group.tdr_graphql_log_group.arn]
  }
}

resource "aws_api_gateway_vpc_link" "graphql_vpc_link" {
  name        = "graphql-vpc-link-${var.environment}"
  description = "A link between api gateway and the private ecs container"
  target_arns = [aws_alb.main.arn]
}
