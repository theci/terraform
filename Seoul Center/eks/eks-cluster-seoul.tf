### Seoul Center VPC EKS Cluster
resource "aws_eks_cluster" "eks-cluster-seoul" {
  name     = "eks-cluster-seoul"
  role_arn = aws_iam_role.eks-cluster-seoul-role.arn

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    security_group_ids = [aws_security_group.seoul-eks-cluster-sg.id]
    subnet_ids         = [
	  aws_subnet.seoul-pvt-2a.id,
	  aws_subnet.seoul-pvt-2c.id
	]
    endpoint_private_access = true
    endpoint_public_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-seoul-role-aws-eks-cluster-policy,
	aws_iam_role_policy_attachment.eks-cluster-seoul-role-aws-eks-VPCResourceController
  ]
}

output "endpoint" {
  value = aws_eks_cluster.eks-cluster-seoul.endpoint
}


### role for OIDC & CNI role
data "tls_certificate" "eks-cluster-seoul-tls-certificate" {
  url = aws_eks_cluster.eks-cluster-seoul.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks-cluster-seoul-aws-iam-openid-connect-provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks-cluster-seoul-tls-certificate.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks-cluster-seoul.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "eks-cluster-seoul-aws-iam-policy-document" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks-cluster-seoul-aws-iam-openid-connect-provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks-cluster-seoul-aws-iam-openid-connect-provider.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eks-cluster-seoul-vpc-cni-role" {
  assume_role_policy = data.aws_iam_policy_document.eks-cluster-seoul-aws-iam-policy-document.json
  name               = "eks-cluster-seoul-vpc-cni-role"
}

resource "aws_iam_role_policy_attachment" "eks-cluster-seoul-vpc-cni-role" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-cluster-seoul-vpc-cni-role.name
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks-cluster-seoul.certificate_authority[0].data
}
