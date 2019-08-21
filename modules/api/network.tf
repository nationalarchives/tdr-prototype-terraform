locals {
  db_port = aws_rds_cluster.content_database.port
}

resource "aws_db_subnet_group" "content_database" {
  name = "content-db-subnet-group-${var.environment}"
  subnet_ids = var.private_subnet

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

resource "aws_security_group" "api_lambda" {
  name        = "api-lambda-security-group-${var.environment}"
  description = "Allow access to database"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    map("Name", "api-lambda-security-group-${var.environment}")
  )
}

resource "aws_security_group_rule" "allow_incoming_db_requests" {
  type                     = "ingress"
  from_port                = local.db_port
  to_port                  = local.db_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.content_database.id
  source_security_group_id = aws_security_group.api_lambda.id
}

resource "aws_security_group_rule" "allow_lambda_to_call_db" {
  type                     = "egress"
  from_port                = local.db_port
  to_port                  = local.db_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.api_lambda.id
  source_security_group_id = aws_security_group.content_database.id
}

resource "aws_security_group_rule" "allow_lambda_to_call_ssm" {
  type             = "egress"
  from_port        = 443
  to_port          = 443
  protocol         = "tcp"
  # TODO: Can we limit this to just SSM access?
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
  security_group_id = aws_security_group.api_lambda.id
}
