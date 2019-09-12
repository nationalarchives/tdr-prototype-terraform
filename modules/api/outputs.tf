output "graphql_api_url" {
  value = aws_api_gateway_stage.graphql_api_deployed_stage.invoke_url
}

output "graphql_stage_name" {
  value = aws_api_gateway_stage.graphql_api_deployed_stage.stage_name
}

output "graphql_path" {
  value = module.graphql_file_checker_endpoint.path
}

output "graphql_stage_id" {
  value = aws_api_gateway_rest_api.graphql_api.id
}
