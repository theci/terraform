terraform {
  cloud {
    organization = "final_project"
    hostname = "app.terraform.io"

    workspaces {
      name = "serverless"
    }
  }
}

provider "aws" {
##  profile = "default"
  region  = "ap-northeast-2"
}
resource "aws_dynamodb_table" "product_table" {
  name         = "UserTable"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"
  attribute {
    name = "user_id"
    type = "S"
  }
}
