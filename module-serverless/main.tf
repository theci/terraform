terraform {
  cloud {
    organization = "final_project"
#   hostname = "app.terraform.io"
#
    workspaces {
      name = "module-serverless"
    }
  }
}

provider "aws" {
#  profile = "default"
  region  = "ap-northeast-2"
}

module "s3" {
  source  = "./module/s3"
}


module "lambda" {
  source  = "./module/serverless/apigw"
}


module "dynamodb" {
  source  = "./module/serverless/dynamodb"
}

module "apigw" {
  source  = "./module/serverless/lambda"
}
