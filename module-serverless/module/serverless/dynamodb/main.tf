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

