### Seoul Center VPC Bastion Host
resource "aws_instance" "seoul-center-bastion" {
  ami                    = "ami-0ea4d4b8dc1e46212"
  instance_type          = "t2.large"
  subnet_id              = aws_subnet.seoul-pub-2a.id
  vpc_security_group_ids = [aws_security_group.seoul-center-bastion-sg.id]
  key_name  = "seoul-center-bastion-key"
  root_block_device {
    volume_size = "8"
    volume_type = "gp3"
    delete_on_termination = true
    tags = {
      Name = "seoul-center-bastion-block-device"
    }
  }
  user_data = <<-EOF
              #! /bin/bash
              hostnamectl set-hostname seoul-center-bastion
              yum -y update
	      yum install -y bash-completion tree jq git htop go
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip >/dev/null 2>&1
              sudo ./aws/install
              echo "export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION" >> /etc/profile
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
              sudo amazon-linux-extras install docker -y
              systemctl start docker && systemctl enable docker
              curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
              chmod 700 get_helm.sh
              ./get_helm.sh
              curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
              mv /tmp/eksctl /usr/local/bin
	      EOF
  tags = {
    Name = "seoul-center-bastion"
  }
}
