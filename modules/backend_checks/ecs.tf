 data "template_file" "checksum_check" {
  template = file("modules/backend_checks/templates/backendCheck.json.tpl")

  vars = {
    image = var.image
    app_environment = var.environment
    aws_region      = var.aws_region
    container_name = "${var.container_name}-${var.environment}"
    check_name = var.check_name
  }
}

resource "aws_ecs_task_definition" "checksum_check" {
  family                   = "${var.task_name}-${var.environment}"
  execution_role_arn       = var.ecs_task_execution_role
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.checksum_check.rendered
  task_role_arn            = var.ecs_task_execution_role

  tags = merge(
    var.common_tags,
    map("Name", "${var.task_name}-task-definition")
  )
}
