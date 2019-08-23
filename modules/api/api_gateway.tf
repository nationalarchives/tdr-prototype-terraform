resource "aws_api_gateway_resource" "graphql_endpoint" {
  path_part   = "graphql"
  parent_id   = aws_api_gateway_rest_api.graphql_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.graphql_api.id
}

resource "aws_api_gateway_rest_api" "graphql_api" {
  name = "tdr-graphql-api-${var.environment}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "graphql_api" {
  rest_api_id = aws_api_gateway_rest_api.graphql_api.id
  depends_on  = ["aws_api_gateway_integration.graphql_api"]

  # You must update the version if you make any changes that require a
  # redeployment of the API Gateway.
  # Terraform doesn't provide a good way to automatically redeploy the Gateway,
  # but we could look into less manual workarounds, e.g.:
  # https://github.com/terraform-providers/terraform-provider-aws/issues/162
  # https://medium.com/coryodaniel/til-forcing-terraform-to-deploy-a-aws-api-gateway-deployment-ed36a9f60c1a
  variables = {
    version = 5
  }

  lifecycle {
      create_before_destroy = true
  }
}

resource "aws_api_gateway_method" "graphql_api" {
  rest_api_id   = aws_api_gateway_rest_api.graphql_api.id
  resource_id   = aws_api_gateway_resource.graphql_endpoint.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.graphql_api_auth.id
}

resource "aws_api_gateway_method_response" "graphql_api_response_200" {
  rest_api_id = aws_api_gateway_rest_api.graphql_api.id
  resource_id = aws_api_gateway_resource.graphql_endpoint.id
  http_method = aws_api_gateway_method.graphql_api.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration" "graphql_api" {
  rest_api_id             = aws_api_gateway_rest_api.graphql_api.id
  resource_id             = aws_api_gateway_resource.graphql_endpoint.id
  http_method             = aws_api_gateway_method.graphql_api.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.api.arn}/invocations"
}

resource "aws_api_gateway_integration_response" "graphql_api" {
  rest_api_id         = aws_api_gateway_rest_api.graphql_api.id
  resource_id         = aws_api_gateway_resource.graphql_endpoint.id
  http_method         = aws_api_gateway_integration.graphql_api.http_method
  status_code         = aws_api_gateway_method_response.graphql_api_response_200.status_code
  response_parameters = {
    // TODO: Lock down to TDR frontend once we have a domain
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_api_gateway_method" "graphql_options" {
  rest_api_id   = aws_api_gateway_rest_api.graphql_api.id
  resource_id   = aws_api_gateway_resource.graphql_endpoint.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "graphql_options_response_200" {
  rest_api_id         = aws_api_gateway_rest_api.graphql_api.id
  resource_id         = aws_api_gateway_resource.graphql_endpoint.id
  http_method         = aws_api_gateway_method.graphql_options.http_method
  status_code         = "200"
  response_models     = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration" "graphql_options" {
  rest_api_id           = aws_api_gateway_rest_api.graphql_api.id
  resource_id           = aws_api_gateway_resource.graphql_endpoint.id
  http_method           = aws_api_gateway_method.graphql_options.http_method
  type                  = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates     = {
    "application/json" = "{ 'statusCode': 200 }"
  }
}

resource "aws_api_gateway_integration_response" "graphql_options" {
  rest_api_id         = aws_api_gateway_rest_api.graphql_api.id
  resource_id         = aws_api_gateway_resource.graphql_endpoint.id
  http_method         = aws_api_gateway_integration.graphql_options.http_method
  status_code         = aws_api_gateway_method_response.graphql_options_response_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    # TODO: Lock down to TDR frontend once we have a domain
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_api_gateway_stage" "graphql_api_deployed_stage" {
  stage_name    = "deployed"
  rest_api_id   = aws_api_gateway_rest_api.graphql_api.id
  deployment_id = aws_api_gateway_deployment.graphql_api.id

  tags = var.common_tags
}

resource "aws_lambda_permission" "graphql_api" {
  statement_id  = "GraphQLApi-${var.environment}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${var.account_id}:${aws_api_gateway_rest_api.graphql_api.id}/*/${aws_api_gateway_method.graphql_api.http_method}${aws_api_gateway_resource.graphql_endpoint.path}"
}

resource "aws_api_gateway_authorizer" "graphql_api_auth" {
  name          = "graphql-api-authorizer-${var.environment}"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.graphql_api.id
  provider_arns = [var.user_pool_arn]
}
