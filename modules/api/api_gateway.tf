resource "aws_api_gateway_rest_api" "graphql_api" {
  name = "tdr-graphql-api-${var.environment}"

  endpoint_configuration {
    types = [
      "REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "graphql_api" {
  rest_api_id = aws_api_gateway_rest_api.graphql_api.id

  variables = {
    # You must update the version if you make any changes that require a
    # redeployment of the API Gateway.
    # Terraform doesn't provide a good way to automatically redeploy the
    # Gateway, but we could look into less manual workarounds, e.g.:
    # https://github.com/terraform-providers/terraform-provider-aws/issues/162
    # https://medium.com/coryodaniel/til-forcing-terraform-to-deploy-a-aws-api-gateway-deployment-ed36a9f60c1a
    version = 9

    # Force this resource to depend on the API Gateway integrations. We cannot
    # use 'depends_on' because 'depends_on' does not work with resources inside
    # modules. See: https://github.com/hashicorp/terraform/issues/17101
    dependencies = "${module.graphql_frontend_endpoint.integration_id}, ${module.graphql_file_checker_endpoint.integration_id}"
  }
}

resource "aws_api_gateway_stage" "graphql_api_deployed_stage" {
  stage_name = "deployed"
  rest_api_id = aws_api_gateway_rest_api.graphql_api.id
  deployment_id = aws_api_gateway_deployment.graphql_api.id
  tags = var.common_tags
}

resource "aws_api_gateway_authorizer" "graphql_api_auth" {
  name = "graphql-api-authorizer-${var.environment}"
  type = "COGNITO_USER_POOLS"
  rest_api_id = aws_api_gateway_rest_api.graphql_api.id
  provider_arns = [
    var.user_pool_arn]
}

module "graphql_frontend_endpoint" {
  source = "../graphql_api_endpoint"

  relative_path = "graphql"
  rest_api_id = aws_api_gateway_rest_api.graphql_api.id
  parent_resource_id = aws_api_gateway_rest_api.graphql_api.root_resource_id
  authorization_type = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.graphql_api_auth.id
  aws_region = var.aws_region
  environment = var.environment
  account_id = var.account_id
  vpc_link_id = aws_api_gateway_vpc_link.graphql_vpc_link.id
}

module "graphql_file_checker_endpoint" {
  source = "../graphql_api_endpoint"

  relative_path = "graphql-backend"
  rest_api_id = aws_api_gateway_rest_api.graphql_api.id
  parent_resource_id = aws_api_gateway_rest_api.graphql_api.root_resource_id
  authorization_type = "AWS_IAM"
  aws_region = var.aws_region
  environment = var.environment
  account_id = var.account_id
  vpc_link_id = aws_api_gateway_vpc_link.graphql_vpc_link.id
}



resource "aws_api_gateway_rest_api" "step_functions" {
  name        = "step-functions"
  description = "API for step function invocation"
}

resource "aws_api_gateway_resource" "invoke" {
  rest_api_id = aws_api_gateway_rest_api.step_functions.id
  parent_id   = aws_api_gateway_rest_api.step_functions.root_resource_id
  path_part   = "invoke"
 }

resource "aws_api_gateway_method" "StepFunctionMethod" {
  rest_api_id   = aws_api_gateway_rest_api.step_functions.id
  resource_id   = aws_api_gateway_resource.invoke.id
  http_method   = "POST"
  authorization = "AWS_IAM"
}


resource "aws_api_gateway_integration" "StepIntegration" {
  rest_api_id             = aws_api_gateway_rest_api.step_functions.id
  resource_id             = aws_api_gateway_resource.invoke.id
  http_method             = aws_api_gateway_method.StepFunctionMethod.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  credentials             =  "arn:aws:iam::247222723249:role/APIGatewayToStepFunctions"
  passthrough_behavior    = "WHEN_NO_MATCH"
  uri                     = "arn:aws:apigateway:eu-west-2:states:action/StartExecution"
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id             = aws_api_gateway_rest_api.step_functions.id
  resource_id             = aws_api_gateway_resource.invoke.id
  http_method             = aws_api_gateway_method.StepFunctionMethod.http_method
  status_code             = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "StepResponse" {
  rest_api_id    = aws_api_gateway_rest_api.step_functions.id
  resource_id    = aws_api_gateway_resource.invoke.id
  http_method    = aws_api_gateway_method.StepFunctionMethod.http_method
  status_code    = aws_api_gateway_method_response.response_200.status_code

}


resource "aws_api_gateway_deployment" "step_api" {
  depends_on     = ["aws_api_gateway_integration.StepIntegration"]
  rest_api_id    = aws_api_gateway_rest_api.step_functions.id
}

resource "aws_api_gateway_stage" "step_api_deployed_stage" {
  stage_name     = "deployed-step"
  rest_api_id    = aws_api_gateway_rest_api.step_functions.id
  deployment_id  = aws_api_gateway_deployment.step_api.id
  tags           = var.common_tags
}



