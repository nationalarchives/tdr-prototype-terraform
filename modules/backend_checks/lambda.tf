resource "aws_lambda_function" "backend_check_lambda" {
  function_name = "tdr-${var.check_name}-${var.environment}"
  runtime = "java8"
  handler = "uk.gov.nationalarchives.tdr.${var.check_name}.RequestHandler::handleRequest"
  role = aws_iam_role.backend_check_lambda_role.arn
  timeout = 30
  # seconds
  memory_size = 512
  # MB
  filename      = "./modules/api/api_lambda_placeholder.zip"
  environment {
    variables = {
      "GRAPHQL_SERVER" = var.graphql_invoke_url,
      "PATH" = var.graphql_path
    }
  }

  tags = merge(
  var.common_tags,
  map(
  "Name", "${var.check_name}-check-lambda-${var.environment}",
  )
  )
}

resource "aws_iam_role" "backend_check_lambda_role" {
  name = "${var.check_name}_lambda_role_${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.invoke_graphql_api_assume_role.json

  tags = merge(
  var.common_tags,
  map(
  "Name", "${var.check_name}-lambda-iam-role-${var.environment}",
  )
  )
}

data "aws_iam_policy_document" "invoke_graphql_api_assume_role" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "invoke_backend_check_api_gateway_role" {
  name   = "invoke_${var.check_name}_api_gateway_${var.environment}"
  path   = "/"
  policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_iam_role_policy_attachment" "invoke_api_attach" {
  role       = aws_iam_role.backend_check_lambda_role.name
  policy_arn = aws_iam_policy.invoke_backend_check_api_gateway_role.arn
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions = [
      "execute-api:Invoke",
    ]

    resources = [
      "arn:aws:execute-api:eu-west-2:${var.account_id}:${var.api_id}/${var.api_stage}/POST${var.graphql_path}",
    ]
  }

  statement {
    actions = [
      "logs:PutLogEvents"
    ]

    resources = [
      aws_cloudwatch_log_stream.tdr_application_log_stream.arn
    ]
  }

}

# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "tdr_backend_check_lambda_log_group" {
  name              = "/lambda/${var.check_name}-check-${var.environment}"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_stream" "tdr_backend_check_lambda_log_stream" {
  name           = "/ecs/${var.check_name}-check-${var.environment}"
  log_group_name = aws_cloudwatch_log_group.tdr_backend_check_lambda_log_group.name
}