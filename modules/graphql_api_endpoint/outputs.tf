output "integration_id" {
  value = aws_api_gateway_integration.graphql_api.id
}

output "path" {
  value = aws_api_gateway_resource.graphql_endpoint.path
}