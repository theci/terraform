module "node-group" {
  source = "github.com/adwordshin/terraform_module/module/EKS/Node_Group"

  eks-cluster-name = "eks-cluster-seoul"
  node-group-name = "eks-cluster-seoul-node-group"

  pvt-2a-name = "seoul-pvt-2a"
  pvt-2c-name = "seoul-pvt-2c"

  node-group-capacity-type = "ON_DEMAND"
  node-group-instance-types = "t3.medium"

  node-group-desired-size = "4"
  node-group-min-size = "2"
  node-group-max-size = "5"
}
