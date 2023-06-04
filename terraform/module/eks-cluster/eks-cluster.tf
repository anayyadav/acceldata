resource "aws_iam_role" "cluster_iam_role" {
  name = "${var.env}-cluster-eks"

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

resource "aws_iam_role_policy_attachment" "cluster_iam_role_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_iam_role.name
}

resource "aws_iam_role_policy_attachment" "cluster_iam_role_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster_iam_role.name
}

resource "aws_eks_cluster" "cluster" {
  name                      = "${var.env}-cluster"
  enabled_cluster_log_types = ["audit"]
  version                   = "1.23"
  role_arn                  = aws_iam_role.cluster_iam_role.arn

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = false
    subnet_ids              = var.private_subnets
    security_group_ids      = [aws_security_group.eks_private_sg.id]
  }


  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_iam_role_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_iam_role_AmazonEKSServicePolicy,
    aws_security_group.eks_private_sg
  ]

  tags = {
    Name               = "${var.env}-cluster"
    "eks:cluster-name" = "${var.env}-cluster"
    infra-env          = var.env
    infra-product      = var.product
    infra-service      = var.service
  }
}

output "endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

