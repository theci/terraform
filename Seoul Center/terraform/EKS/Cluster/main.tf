terraform {
  cloud {
    organization = "final_project"
###   hostname = "app.terraform.io"
#
    workspaces {
      name = "seoul-EKS"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

module "eks-cluster" {
  source = "github.com/adwordshin/terraform_module/module/EKS/Cluster"

  cluster-name="eks-cluster-seoul"
  cluster-sg-name="seoul-center-eks-cluster-sg"
}
