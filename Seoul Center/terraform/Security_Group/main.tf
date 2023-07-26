terraform {
  cloud {
    organization = "final_project"
#   hostname = "app.terraform.io"
#
    workspaces {
      name = "seoul-sg"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}


module "security_group" {
  source = "github.com/adwordshin/terraform_module/module/Security_Group"

  vpc-name = "seoul-center"
  bastion-sg-name = "seoul-center-bastion-sg"
  eks-cluster-sg-name = "seoul-center-eks-cluster-sg"
}
