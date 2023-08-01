terraform {
  cloud {
    organization = "final_project"
##   hostname = "app.terraform.io"
#
    workspaces {
      name = "module-serverless"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-2"
}

module "s3" {
  source  = "./module/s3"
}

module "serverless" {
  source  = "./module/serverless"
}
