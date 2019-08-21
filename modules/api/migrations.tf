resource "aws_ecs_cluster" "database_migrations" {
  name = "tdr-content-db-migrations-${var.environment}"

  tags = merge(
    var.common_tags,
    map(
      "Name", "content-db-migration-cluster-${var.environment}",
    )
  )
}

resource "aws_ecs_task_definition" "run_database_migrations" {
  family                   = "content-database-migrations-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256 # CPU units
  memory                   = 512 # MiB
  container_definitions    = data.template_file.database_migrations.rendered
  execution_role_arn       = aws_iam_role.database_migration_task_excution_role.arn

  tags = merge(
    var.common_tags,
    map("Name", "content-db-migration-task-definition-${var.environment}")
  )
}

data "template_file" "database_migrations" {
 template = file("modules/api/templates/databaseMigrations.json.tpl")

 vars = {
   # TODO: Use environment tag
   image_id = "nationalarchives/tdr-prototype-db-migrations:latest"
   app_environment   = var.environment
   aws_region        = var.aws_region
   container_name    = "content-database-migrations-${var.environment}"
   db_url_param      = local.database_parameter_keys["url"]
   db_username_param = local.database_parameter_keys["username"]
   db_password_param = local.database_parameter_keys["password"]
 }
}

resource "aws_iam_role" "database_migration_task_excution_role" {
  name = "content_database_migration_task_execution_role_${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.database_migration_task_assume_role.json

  tags = merge(
    var.common_tags,
    map(
      "Name", "content-database-migration-task-execution-iam-role-${var.environment}",
    )
  )
}

data "aws_iam_policy_document" "database_migration_task_assume_role" {
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

resource "aws_iam_role_policy_attachment" "database_migration_task_execution_policy" {
  role       = aws_iam_role.database_migration_task_excution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_cloudwatch_log_group" "database_migration_task" {
  name              = "/ecs/tdr-db-migrations-${var.environment}"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_stream" "database_migration_task" {
  name           = "tdr-db-migrations-${var.environment}"
  log_group_name = aws_cloudwatch_log_group.database_migration_task.name
}
