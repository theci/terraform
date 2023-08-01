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