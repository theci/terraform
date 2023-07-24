### Seoul Center VPC EKS Cluster addon
resource "aws_eks_addon" "eks-cluster-seoul-vpc-cni" {
  cluster_name = aws_eks_cluster.eks-cluster-seoul.name
  addon_name   = "vpc-cni"
  addon_version = "v1.12.6-eksbuild.2"
  service_account_role_arn = aws_iam_role.eks-cluster-seoul-vpc-cni-role.arn
}

resource "aws_eks_addon" "eks-cluster-seoul-coredns" {
  cluster_name = aws_eks_cluster.eks-cluster-seoul.name
  addon_name = "coredns"
  addon_version = "v1.10.1-eksbuild.1"
  service_account_role_arn = aws_iam_role.eks-cluster-seoul-vpc-cni-role.arn
}

resource "aws_eks_addon" "eks-cluster-seoul-kube-proxy" {
  cluster_name = aws_eks_cluster.eks-cluster-seoul.name
  addon_name   = "kube-proxy"
  addon_version = "v1.27.1-eksbuild.1"
  service_account_role_arn = aws_iam_role.eks-cluster-seoul-vpc-cni-role.arn
}