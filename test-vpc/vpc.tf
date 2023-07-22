#VPC(서브넷, 인터넷 게이트웨이, 라우팅 테이블) 스크립트 작성
# pwd    // /root/terraform/tf-test 위치에서 시작
#@ vi main.tf
provider "aws" {
  region = "ap-northeast-2"
}


### vpc start ###

resource "aws_vpc" "test_vpc" {
  cidr_block  = "192.168.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"

  tags = {
    Name = "test-vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "test-pub_2a" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = "192.168.0.0/20"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "test-pub-2a"
  }
}

resource "aws_subnet" "test-pub_2b" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = "192.168.16.0/20"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "test-pub-2b"
  }
}

resource "aws_subnet" "test-pub_2c" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = "192.168.32.0/20"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "test-pub-2c"
  }
}

resource "aws_subnet" "test-pub_2d" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = "192.168.48.0/20"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[3]
  tags = {
    Name = "test-pub-2d"
  }
}

