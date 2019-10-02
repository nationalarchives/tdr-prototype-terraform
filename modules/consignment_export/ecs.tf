locals {
  export_task_log_group_name = "/ecs/tdr-consignment-export-${var.environment}"
}

resource "aws_ecs_cluster" "consignment_export" {
  name = "tdr-consignment-export-${var.environment}"

  tags = merge(
    var.common_tags,
    map(
      "Name", "consignment-export-${var.environment}",
    )
  )
}

resource "aws_ecs_task_definition" "run_consignment_export" {
  family                   = "tdr-consignment-export-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256 # CPU units
  memory                   = 512 # MiB
  container_definitions    = data.template_file.consignment_export_container.rendered
  execution_role_arn       = aws_iam_role.consignment_export_execution.arn
  task_role_arn            = aws_iam_role.consignment_export_task.arn

  tags = merge(
    var.common_tags,
    map("Name", "consignment-export-task-definition-${var.environment}")
  )
}

data "template_file" "consignment_export_container" {
 template = file("modules/consignment_export/templates/consignmentExportContainer.json.tpl")

 vars = {
   image_id             = "nationalarchives/tdr-prototype-file-export:${var.environment}"
   app_environment      = var.environment
   aws_region           = var.aws_region
   container_name       = "consignment-export-${var.environment}"
   graphql_server_param = var.graphql_invoke_url
   graphql_path_param   = var.graphql_path
   export_bucket_param  = aws_s3_bucket.consignment_export.id
   log_group_name       = local.export_task_log_group_name
 }
}

resource "aws_iam_role" "consignment_export_execution" {
  name = "consignment_export_execution_role_${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.consignment_export_execution_assume_role.json

  tags = merge(
    var.common_tags,
    map(
      "Name", "consignment-export-execution-iam-role-${var.environment}",
    )
  )
}

data "aws_iam_policy_document" "consignment_export_execution_assume_role" {
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

resource "aws_iam_role" "consignment_export_task" {
  name = "consignment_export_task_role_${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.consignment_export_task_assume_role.json

  tags = merge(
    var.common_tags,
    map(
      "Name", "consignment-export-task-iam-role-${var.environment}",
    )
  )
}

data "aws_iam_policy_document" "consignment_export_task_assume_role" {
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

resource "aws_iam_role_policy_attachment" "consignment_export_task" {
  role       = aws_iam_role.consignment_export_task.name
  policy_arn = aws_iam_policy.consignment_export_task.arn
}

resource "aws_iam_policy" "consignment_export_task" {
  name   = "consignment_export_task_policy_${var.environment}"
  path   = "/"
  policy = data.aws_iam_policy_document.consignment_export_task.json
}

data "aws_iam_policy_document" "consignment_export_task" {
  statement {
    actions   = ["execute-api:Invoke"]
    resources = [var.api_arn]
  }

  statement {
    actions   = ["s3:GetObject"]
    resources = ["${var.consignment_file_bucket_arn}/*"]
  }

  statement {
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.consignment_export.arn}/*"]
  }
}
