### apigw
resource "aws_api_gateway_rest_api" "product_apigw" {
  name        = "product_apigw"
  description = "Product API Gateway"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_method" "createproduct" {
  rest_api_id   = aws_api_gateway_rest_api.product_apigw.id
  resource_id   = aws_api_gateway_rest_api.product_apigw.root_resource_id
  http_method   = "POST"
  authorization = "NONE"
}




resource "aws_api_gateway_method" "test_options" {
  rest_api_id             = aws_api_gateway_rest_api.product_apigw.id
  resource_id             = aws_api_gateway_rest_api.product_apigw.root_resource_id
  http_method   = "OPTIONS"
  authorization = "NONE"
}


resource "aws_api_gateway_method_response" "test_options_200" {
  rest_api_id             = aws_api_gateway_rest_api.product_apigw.id
  resource_id             = aws_api_gateway_rest_api.product_apigw.root_resource_id
  http_method = aws_api_gateway_method.test_options.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "test_options" {
  rest_api_id             = aws_api_gateway_rest_api.product_apigw.id
  resource_id             = aws_api_gateway_rest_api.product_apigw.root_resource_id

  http_method = aws_api_gateway_method.test_options.http_method
  status_code = aws_api_gateway_method_response.test_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

resource "aws_api_gateway_integration" "test_options_mock" {
  rest_api_id             = aws_api_gateway_rest_api.product_apigw.id
  resource_id             = aws_api_gateway_rest_api.product_apigw.root_resource_id
  http_method = aws_api_gateway_method.test_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOF
{
  "statusCode": 200
}
EOF
  }
}




resource "aws_api_gateway_integration" "createproduct-lambda" {
  rest_api_id             = aws_api_gateway_rest_api.product_apigw.id
  resource_id             = aws_api_gateway_rest_api.product_apigw.root_resource_id
  http_method             = aws_api_gateway_method.createproduct.http_method
  integration_http_method = "POST" #  Lambda function can only be invoked via POST
  type                    = "AWS"
  uri                     = aws_lambda_function.CreateProductHandler.invoke_arn
  content_handling        = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_method_response" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.product_apigw.id
  resource_id = aws_api_gateway_rest_api.product_apigw.root_resource_id
  http_method = aws_api_gateway_method.createproduct.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.product_apigw.id
  resource_id = aws_api_gateway_rest_api.product_apigw.root_resource_id
  http_method = aws_api_gateway_method.createproduct.http_method
  status_code = aws_api_gateway_method_response.lambda.status_code
  depends_on  = [aws_api_gateway_integration.createproduct-lambda]
}




resource "aws_api_gateway_deployment" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.product_apigw.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_method.createproduct.id,
      aws_api_gateway_integration.createproduct-lambda.id,
      aws_api_gateway_method_response.lambda,
      aws_api_gateway_integration_response.lambda,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "lambda" {
  deployment_id = aws_api_gateway_deployment.lambda.id
  rest_api_id   = aws_api_gateway_rest_api.product_apigw.id
  stage_name    = var.stage_name # Any Name you wish
}