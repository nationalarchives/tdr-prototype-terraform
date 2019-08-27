resource "aws_rds_cluster" "content_database" {
  cluster_identifier_prefix = "content-db-${var.environment}"
  engine                    = "aurora-postgresql"
  availability_zones        = var.database_availability_zones
  database_name             = "tdrapi"
  master_username           = "tdr_db_user"
  master_password           = var.database_password
  final_snapshot_identifier = "content-db-final-snapshot-${var.environment}"
  vpc_security_group_ids    = [aws_security_group.content_database.id]
  db_subnet_group_name      = aws_db_subnet_group.content_database.name

  tags = merge(
    var.common_tags,
    map(
      "Name", "content-db-cluster-${var.environment}"
    )
  )

  lifecycle {
    ignore_changes = [
      # Ignore changes to availability zones because AWS automatically adds the
      # extra availability zone "eu-west-2c", which is rejected by the API as
      # unavailable if specified directly.
      availability_zones,
    ]
  }
}

resource "aws_rds_cluster_instance" "content_database" {
  count                = 1
  identifier_prefix    = "content-db-instance-${var.environment}"
  cluster_identifier   = "${aws_rds_cluster.content_database.id}"
  engine               = "aurora-postgresql"
  instance_class       = "db.t3.medium"
  db_subnet_group_name = aws_db_subnet_group.content_database.name
}

resource "aws_ssm_parameter" "database_url" {
  name  = local.database_parameter_keys["url"]
  type  = "String"
  value = "jdbc:postgresql://${aws_rds_cluster.content_database.endpoint}:${aws_rds_cluster.content_database.port}/${aws_rds_cluster.content_database.database_name}"
}

resource "aws_ssm_parameter" "database_username" {
  name  = local.database_parameter_keys["username"]
  type  = "String"
  value = aws_rds_cluster.content_database.master_username
}

resource "aws_ssm_parameter" "database_password" {
  name  = local.database_parameter_keys["password"]
  type  = "String"
  value = var.database_password
}
