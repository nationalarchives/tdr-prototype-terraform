locals {
  db_port = aws_rds_cluster.content_database.port
}

resource "aws_db_subnet_group" "content_database" {
  name = "content-db-subnet-group-${var.environment}"
  subnet_ids = var.ecs_private_subnet

  tags = merge(
    var.common_tags,
    map("Name", "content-db-subnet-group-${var.environment}")
  )
}

resource "aws_security_group" "content_database" {
  name        = "content-db-security-group-${var.environment}"
  description = "Allow inbound access from the API and migration tasks"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    map("Name", "content-db-security-group-${var.environment}")
  )
}

resource "aws_security_group" "database_migration_task" {
  name        = "migration-task-security-group-${var.environment}"
  description = "Allow access to database"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    map("Name", "migration-task-security-group-${var.environment}")
  )
}

resource "aws_security_group_rule" "allow_db_requests_from_migration_task" {
  type                     = "ingress"
  from_port                = local.db_port
  to_port                  = local.db_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.content_database.id
  source_security_group_id = aws_security_group.database_migration_task.id
}

resource "aws_security_group_rule" "allow_db_requests_from_ecs_task" {
  type                     = "ingress"
  from_port                = local.db_port
  to_port                  = local.db_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.content_database.id
  source_security_group_id = aws_security_group.ecs_tasks.id
}

resource "aws_security_group_rule" "allow_ecs_task_to_call_db" {
  type                     = "egress"
  from_port                = local.db_port
  to_port                  = local.db_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.content_database.id
  source_security_group_id = aws_security_group.ecs_tasks.id
}

resource "aws_security_group_rule" "allow_migrations_to_call_db" {
  type                     = "egress"
  from_port                = local.db_port
  to_port                  = local.db_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.database_migration_task.id
  source_security_group_id = aws_security_group.content_database.id
}

resource "aws_security_group_rule" "allow_migrations_to_pull_docker_image" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  # TODO: Can we limit this to just Docker?
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.database_migration_task.id
}
