### Seoul Center VPC
resource "aws_vpc" "create-center-vpc" {
  cidr_block  = var.vpc-cidr-block
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"

  tags = {
    Name = var.vpc-name
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}