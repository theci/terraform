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

module "acm" {
  source  = "./module/s3"
}


module "cloudfront" {
  source  = "./module/s3"
}


module "s3" {
  source  = "./module/s3"
}


module "lambda" {
  source  = "./module/serverless"
}


module "dynamodb" {
  source  = "./module/serverless"
}

module "apigw" {
  source  = "./module/serverless"
}
