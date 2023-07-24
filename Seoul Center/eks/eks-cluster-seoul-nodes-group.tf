### Seoul Center VPC EKS Cluster Node Group
resource "aws_eks_node_group" "eks-cluster-seoul-nodes-group" {
  cluster_name    = aws_eks_cluster.eks-cluster-seoul.name
  node_group_name = "eks-cluster-seoul-nodes-group"
  node_role_arn   = aws_iam_role.eks-cluster-seoul-nodes-group-role.arn
  subnet_ids = [
    aws_subnet.seoul-pvt-2a.id,
    aws_subnet.seoul-pvt-2c.id
  ]

  remote_access {
    ec2_ssh_key = "seoul-eks-cluster-node-key"
  }

  capacity_type = "ON_DEMAND"
  instance_types = ["t3.medium"]
  disk_size = 30
  ami_type = "AL2_x86_64"

  scaling_config {
    desired_size = 4
    min_size     = 2
    max_size     = 10
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-seoul-nodes-group-aws-eks-worker-node-policy,
    aws_iam_role_policy_attachment.eks-cluster-seoul-nodes-group-aws-eks-cni-policy,
    aws_iam_role_policy_attachment.eks-cluster-seoul-nodes-group-aws-ec2-container-registry-read-only
  ]
  
  tags = {
    Name = "eks-cluster-seoul-nodes-group"
  }
}
