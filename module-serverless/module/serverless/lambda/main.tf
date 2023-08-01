terraform {
  cloud {
    organization = "final_project"
    hostname = "app.terraform.io"

    workspaces {
      name = "module-serverless"
    }
  }
}

provider "aws" {
##  profile = "default"
  region  = "ap-northeast-2"
}

### lambda
resource "aws_iam_role" "ProductLambdaRole" {
  name               = "ProductLambdaRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
data "template_file" "productlambdapolicy" {
  template = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "logs:CreateLogStream",
              "logs:CreateLogGroup",
              "logs:PutLogEvents"
          ],
          "Resource": "arn:aws:logs:*:*:*"
      },
      {
          "Effect": "Allow",
          "Action": [
              "dynamodb:*"
          ],
          "Resource": [ 
              "*"
          ]
      }
    ]
}
EOF
}
resource "aws_iam_policy" "ProductLambdaPolicy" {
  name        = "ProductLambdaPolicy"
  path        = "/"
  description = "IAM policy for Product lambda functions"
  policy      = data.template_file.productlambdapolicy.rendered
}
resource "aws_iam_role_policy_attachment" "ProductLambdaRolePolicy" {
  role       = aws_iam_role.ProductLambdaRole.name
  policy_arn = aws_iam_policy.ProductLambdaPolicy.arn
}

resource "aws_lambda_function" "CreateProductHandler" {
  function_name = "CreateProductHandler"
  filename = "./product_lambda.zip"
  handler = "createproduct.lambda_handler"
  runtime = "python3.8"
  environment {
    variables = {
      REGION        = "ap-northeast-2"
      PRODUCT_TABLE = aws_dynamodb_table.product_table.name
   }
  }
  source_code_hash = filebase64sha256("module/serverless/lambda/product_lambda.zip")
  role = aws_iam_role.ProductLambdaRole.arn
  timeout     = "5"
  memory_size = "128"
}



resource "aws_lambda_permission" "apigw-CreateProductHandler" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.CreateProductHandler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.product_apigw.execution_arn}/*"
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
  stage_name    = "run" # Any Name you wish
}
