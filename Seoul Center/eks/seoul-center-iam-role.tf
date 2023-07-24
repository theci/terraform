### Seoul Center VPC EKS Cluster & Node group Role
## EKS Cluster IAM Role
resource "aws_iam_role" "eks-cluster-seoul-role" {
  name = "eks-cluster-seoul-role"

  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "eks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-cluster-seoul-role-aws-eks-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-seoul-role.name
}

resource "aws_iam_role_policy_attachment" "eks-cluster-seoul-role-aws-eks-VPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks-cluster-seoul-role.name
}


### EKS Node group IAM Role
resource "aws_iam_role" "eks-cluster-seoul-nodes-group-role" {
  name = "eks-cluster-seoul-nodes-group-role"

  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-cluster-seoul-nodes-group-aws-eks-worker-node-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-cluster-seoul-nodes-group-role.name
}

resource "aws_iam_role_policy_attachment" "eks-cluster-seoul-nodes-group-aws-eks-cni-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-cluster-seoul-nodes-group-role.name
}

resource "aws_iam_role_policy_attachment" "eks-cluster-seoul-nodes-group-aws-ec2-container-registry-read-only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-cluster-seoul-nodes-group-role.name
}