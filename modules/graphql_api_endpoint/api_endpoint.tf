resource "aws_api_gateway_resource" "graphql_endpoint" {
  path_part   = var.relative_path
  parent_id   = var.parent_resource_id
  rest_api_id = var.rest_api_id
}

resource "aws_api_gateway_method" "graphql_api" {
  rest_api_id   = var.rest_api_id
  resource_id   = aws_api_gateway_resource.graphql_endpoint.id
  http_method   = "POST"
  authorization = var.authorization_type
  authorizer_id = var.authorizer_id
}

resource "aws_api_gateway_method_response" "graphql_api_response_200" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.graphql_endpoint.id
  http_method = aws_api_gateway_method.graphql_api.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration" "graphql_api" {
  rest_api_id             = var.rest_api_id
  resource_id             = aws_api_gateway_resource.graphql_endpoint.id
  http_method             = aws_api_gateway_method.graphql_api.http_method
  integration_http_method = "POST"
  type                    = "HTTP"
  connection_type = "VPC_LINK"
  connection_id   = var.vpc_link_id
  uri             = "https://graphql.tdr-prototype.co.uk"
}

resource "aws_api_gateway_integration_response" "graphql_api" {
  rest_api_id         = var.rest_api_id
  resource_id         = aws_api_gateway_resource.graphql_endpoint.id
  http_method         = aws_api_gateway_integration.graphql_api.http_method
  status_code         = aws_api_gateway_method_response.graphql_api_response_200.status_code
  response_parameters = {
    // TODO: Lock down to TDR frontend once we have a domain
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_api_gateway_method" "graphql_options" {
  rest_api_id   = var.rest_api_id
  resource_id   = aws_api_gateway_resource.graphql_endpoint.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "graphql_options_response_200" {
  rest_api_id         = var.rest_api_id
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
  rest_api_id           = var.rest_api_id
  resource_id           = aws_api_gateway_resource.graphql_endpoint.id
  http_method           = aws_api_gateway_method.graphql_options.http_method
  type                  = "MOCK"
  passthrough_behavior  = "WHEN_NO_MATCH"
  request_templates     = {
    "application/json" = "{ 'statusCode': 200 }"
  }
}

resource "aws_api_gateway_integration_response" "graphql_options" {
  rest_api_id         = var.rest_api_id
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