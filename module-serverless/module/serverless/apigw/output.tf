output "deployment_invoke_url" {
  description = "Deployment invoke url"
  value       = aws_api_gateway_stage.lambda.invoke_url
}