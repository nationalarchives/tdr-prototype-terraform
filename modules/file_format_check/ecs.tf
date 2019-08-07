 data "template_file" "file_format_check" {
  template = file("modules/file_format_check/templates/fileFormatCheck.json.tpl")

  vars = {
    file_format_check_image = var.file_format_check_image
    app_environment = var.environment
    aws_region      = var.aws_region
  }
}

resource "aws_ecs_task_definition" "file_format_check" {
  family                   = "${var.file_format_check_name}-${var.environment}"
  execution_role_arn       = var.ecs_task_execution_role
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.file_format_check.rendered
  task_role_arn            = var.ecs_task_execution_role

  tags = merge(
    var.common_tags,
    map(
      "Name", "${var.file_format_check_name}-task-definition",
    )
  )
}
