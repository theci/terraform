module "VPC" {
  source = "github.com/adwordshin/terraform_module/module/VPC"
  
  vpc-cidr = "10.10.0.0/16"
  vpc-name = "seoul-center"


  pub-2a-cidr = "10.10.0.0/20"
  pub-2a-name = "seoul-pub-2a"

  pub-2c-cidr = "10.10.32.0/20"
  pub-2c-name = "seoul-pub-2c"

  pvt-2a-cidr = "10.10.64.0/20"
  pvt-2a-name = "seoul-pvt-2a"

  pvt-2c-cidr = "10.10.96.0/20"
  pvt-2c-name = "seoul-pvt-2c"


  pub-rtb-name = "seoul-pub-rtb"
  pvt-rtb-name = "seoul-pvt-rtb"

  igw-name = "seoul-center-igw"
}
