### Terraform Provider
provider "aws" {
  region = "ap-northeast-2"
}


### Seoul Center VPC
resource "aws_vpc" "seoul-center-vpc" {
  cidr_block  = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"

  tags = {
    Name = "seoul-center-vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}


### Seoul Center VPC Subnet
## seoul-pub-2a subnet
resource "aws_subnet" "seoul-pub-2a" {
  vpc_id = aws_vpc.seoul-center-vpc.id
  cidr_block = "10.10.0.0/20"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "seoul-pub-2a"
  }
}


## seoul-pub-2c subnet
resource "aws_subnet" "seoul-pub-2c" {
  vpc_id = aws_vpc.seoul-center-vpc.id
  cidr_block = "10.10.32.0/20"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "seoul-pub-2c"
  }
}


## seoul-pvt-2a subnet
resource "aws_subnet" "seoul-pvt-2a" {
  vpc_id = aws_vpc.seoul-center-vpc.id
  cidr_block = "10.10.64.0/20"
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "seoul-pvt-2a"
  }
}


## seoul-pvt-2c subnet
resource "aws_subnet" "seoul-pvt-2c" {
  vpc_id = aws_vpc.seoul-center-vpc.id
  cidr_block = "10.10.96.0/20"
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "seoul-pvt-2c"
  }
}


### Seoul Center VPC Internet Gateway
resource "aws_internet_gateway" "seoul-igw" {
  vpc_id = aws_vpc.seoul-center-vpc.id
  tags = {
    Name = "seoul-eks-igw"
  }
}


### Seoul Center VPC Route Table
resource "aws_route_table" "seoul-pub-rtb" {
  vpc_id = aws_vpc.seoul-center-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.seoul-igw.id
  }
  tags = {
    Name = "seoul-pub-rtb"
  }
}

resource "aws_route_table" "seoul-pvt-rtb" {
  vpc_id = aws_vpc.seoul-center-vpc.id
  tags = {
    Name = "seoul-pvt-rtb"
  }
}

resource "aws_route_table_association" "seoul-pub-2a-association" {
  subnet_id = aws_subnet.seoul-pub-2a.id
  route_table_id = aws_route_table.seoul-pub-rtb.id
}

resource "aws_route_table_association" "seoul-pub-2c-association" {
  subnet_id = aws_subnet.seoul-pub-2c.id
  route_table_id = aws_route_table.seoul-pub-rtb.id
}

resource "aws_route_table_association" "seoul-pvt-2a-association" {
  subnet_id = aws_subnet.seoul-pvt-2a.id
  route_table_id = aws_route_table.seoul-pvt-rtb.id
}

resource "aws_route_table_association" "seoul-pvt-2c-association" {
  subnet_id = aws_subnet.seoul-pvt-2c.id
  route_table_id = aws_route_table.seoul-pvt-rtb.id
}


### Seoul Center VPC EIP & NAT-GW
## EIP
resource "aws_eip" "eip-seoul-nat-gw" {
  vpc   = true

  lifecycle {
    create_before_destroy = true
  }
}


#NAT-GW
resource "aws_nat_gateway" "seoul-nat-gw" {
  allocation_id = aws_eip.eip-seoul-nat-gw.id

  # Private subnet이 아니라 public subnet을 연결하셔야 합니다.
  subnet_id = aws_subnet.seoul-pub-2a.id

  tags = {
    Name = "seoul-nat-gw"
  }
}


## NAT-GW & pvt routetable routing setting
resource "aws_route" "pvt-rtb-seoul-nat-gw" {
  route_table_id              = aws_route_table.seoul-pvt-rtb.id
  destination_cidr_block      = "0.0.0.0/0"
  nat_gateway_id              = aws_nat_gateway.seoul-nat-gw.id
}


### Private Client Server
resource "aws_instance" "seoul-center-client-server" {
  ami                    = "ami-0ea4d4b8dc1e46212"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.seoul-pvt-2a.id
  vpc_security_group_ids = [aws_security_group.seoul-eks-cluster-nodes-sg.id]
  key_name  = "seoul-eks-cluster-node-key"
  root_block_device {
    volume_size = "8"
    volume_type = "gp3"
    delete_on_termination = true
    tags = {
      Name = "seoul-center-client-server-block-device"
    }
  }
  user_data = <<-EOF
              #! /bin/bash
              hostnamectl set-hostname seoul-center-bastion
              yum -y update
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip >/dev/null 2>&1
              sudo ./aws/install
              curl -LO https://dl.k8s.io/release/v1.22.2/bin/linux/amd64/kubectl
              install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
              chmod +x ./kubectl
              mv ./kubectl /usr/local/bin
              source <(kubectl completion bash)
              echo "source <(kubectl completion bash)" >> ~/.bashrc
			  source /usr/share/bash-completion/bash_completion
              echo 'alias k=kubectl' >>~/.bashrc
              echo 'complete -o default -F __start_kubectl k' >>~/.bashrc
              exec bash
			  EOF
  tags = {
    Name = "seoul-center-client-server"
  }
}


### Seoul Center VPC Security Group
resource "aws_security_group" "seoul-center-bastion-sg" {
  vpc_id = aws_vpc.seoul-center-vpc.id
  name   = "seoul-center-bastion-sg"
  
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "seoul-center-bastion-sg"
  }
}

resource "aws_security_group" "seoul-eks-cluster-sg" {
  vpc_id = aws_vpc.seoul-center-vpc.id
  name   = "seoul-eks-cluster-sg"
  
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "seoul-eks-cluster-sg"
  }
}
