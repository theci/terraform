output "deployment_invoke_url" {
  description = "Deployment invoke url"
  value       = module.lambda.invoke_url
}