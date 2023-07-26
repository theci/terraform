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
  template = "${file("${path.module}/policy.json")}"
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
  source_code_hash = filebase64sha256("module/serverless/product_lambda.zip")
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



## dynamodb
resource "aws_dynamodb_table" "product_table" {
  name         = "UserTable"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"
  attribute {
    name = "user_id"
    type = "S"
  }
}