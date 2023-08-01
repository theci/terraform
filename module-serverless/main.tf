terraform {
  cloud {
    organization = "final_project"
    
    workspaces {
      name = "module-serverless"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-2"
}

module "s3" {
  source  = "./module/frontend"
}

module "serverless" {
  source  = "./module/backend"
}
