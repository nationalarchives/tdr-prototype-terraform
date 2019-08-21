resource "aws_lambda_function" "api" {
  function_name = "tdr-api-${var.environment}"
  runtime       = "java8"
  handler       = "uk.gov.nationalarchives.tdr.api.lambda.RequestHandler::handleRequest"
  role          = aws_iam_role.api_lambda.arn
  timeout       = 30 # seconds
  memory_size   = 512 # MB
  filename      = "./modules/api/api_lambda_placeholder.zip"

  vpc_config {
    subnet_ids         = var.private_subnet
    security_group_ids = [aws_security_group.api_lambda.id]
  }

  environment {
    # TODO: Commonise with database.tf
    variables = {
      "TDR_API_ENVIRONMENT" = "TEST",
      "DB_URL_PARAM_PATH" = "/tdr/${var.environment}/api/db/url",
      "DB_USERNAME_PARAM_PATH" = "/tdr/${var.environment}/api/db/username",
      "DB_PASSWORD_PARAM_PATH" = "/tdr/${var.environment}/api/db/password"
    }
  }

  tags = merge(
    var.common_tags,
    map(
      "Name", "api-lambda-${var.environment}",
    )
  )
}

resource "aws_iam_role" "api_lambda" {
  name = "api_lambda_role_${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.api_lambda_assume_role.json

  tags = merge(
    var.common_tags,
    map(
      "Name", "api-lambda-iam-role-${var.environment}",
    )
  )
}

data "aws_iam_policy_document" "api_lambda_assume_role" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions   = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "api_lambda_ssm_parameters" {
  name = "api_lambda_ssm_parameter_policy_${var.environment}"
  policy = data.aws_iam_policy_document.api_lambda_ssm_parameter_policy.json
}

data "aws_iam_policy_document" "api_lambda_ssm_parameter_policy" {
  version = "2012-10-17"

  statement {
    effect  =   "Allow"
    actions =   ["ssm:GetParameters"]
    # TODO: Generate ARN
    # TODO: Commonise param base path with database.tf
    resources = ["arn:aws:ssm:eu-west-2:247222723249:parameter/tdr/${var.environment}/*"]
  }
}

resource "aws_iam_role_policy_attachment" "api_lambda_role_policy" {
  role       = aws_iam_role.api_lambda.name
  policy_arn = aws_iam_policy.api_lambda_ssm_parameters.arn
}

resource "aws_iam_role_policy_attachment" "api_vpc_policy" {
  role       = aws_iam_role.api_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
