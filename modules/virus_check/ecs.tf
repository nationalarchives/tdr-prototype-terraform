 data "template_file" "virus_check" {
  template = file("modules/virus_check/templates/virusCheck.json.tpl")

  vars = {
    virus_check_image = var.virus_check_image
    app_environment = var.environment
    aws_region      = var.aws_region
  }
}

resource "aws_ecs_task_definition" "virus_check" {
  family                   = "${var.virus_check_name}-${var.environment}"
  execution_role_arn       = var.ecs_task_execution_role
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.virus_check.rendered
  task_role_arn            = var.ecs_task_execution_role

  tags = merge(
    var.common_tags,
    map(
      "Name", "${var.virus_check_name}-task-definition",
    )
  )
}
