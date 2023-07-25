module "acm" {
  source  = "./module/acm"
}


module "cloudfront" {
  source  = "./module/cloudfront"
}


module "s3" {
  source  = "./module/s3"
}


module "lambda" {
  source  = "./module/serverless/lambda"
}


module "dynamodb" {
  source  = "./module/serverless/dynamodb"
}


module "apigw" {
  source  = "./module/serverless/apigw"
}
