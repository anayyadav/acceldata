
locals {
  asg-tags = [
    {
      tagKey   = "env"
      tagValue = var.env
    },
    {
      tagKey   = "infra-service"
      tagValue = var.service
    },
  ]
}
## creating IAM role for node group
resource "aws_iam_role" "cluster_node_group_iam_role" {
  name = "${var.env}-cluster-eks-node-group"

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

  tags = {
    Name               = "${var.env}-cluster-eks-node-group"
    "eks:cluster-name" = "${var.env}-cluster"
    infra-env          = var.env
    infra-service      = var.service
  }
}

resource "aws_iam_policy" "eks_cluster_autoscaling_policy" {
  name        = "EKSClusterNodeGroupAutoscalingPolicy"
  path        = "/"
  description = "EKSClusterNodeGroupAutoscalingPolicy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeScalingActivities",
        "autoscaling:DescribeTags",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeLaunchTemplateVersions"
      ],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeImages",
        "ec2:GetInstanceTypesFromInstanceRequirements",
        "eks:DescribeNodegroup"
      ],
      "Resource": ["*"]
    },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AttachVolume",
                "ec2:CreateSnapshot",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:DeleteSnapshot",
                "ec2:DeleteTags",
                "ec2:DeleteVolume",
                "ec2:DescribeInstances",
                "ec2:DescribeSnapshots",
                "ec2:DescribeTags",
                "ec2:DescribeVolumes",
                "ec2:DetachVolume"
            ],
            "Resource": "*"
        }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cluster_node_group_iam_role_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.cluster_node_group_iam_role.name
}

resource "aws_iam_role_policy_attachment" "cluster_node_group_iam_role_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.cluster_node_group_iam_role.name
}

resource "aws_iam_role_policy_attachment" "cluster_node_group_iam_role_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.cluster_node_group_iam_role.name
}

resource "aws_iam_role_policy_attachment" "cluster_node_group_iam_role_ssm_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.cluster_node_group_iam_role.name
}

resource "aws_iam_role_policy_attachment" "cluster_node_group_eks_cluster_autoscaling_policy" {
  policy_arn = aws_iam_policy.eks_cluster_autoscaling_policy.arn
  role       = aws_iam_role.cluster_node_group_iam_role.name
}

resource "aws_iam_policy" "eks_node_group_policy" {
  name        = "EKSNodeGroupPolicy"
  path        = "/"
  description = "EKSNodeGroupPolicy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AttachVolume",
                "ec2:DetachVolume",
                "ec2:CreateVolume"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cluster_node_group_iam_role_EKSNodeGroupPolicy" {
  policy_arn = aws_iam_policy.eks_node_group_policy.arn
  role       = aws_iam_role.cluster_node_group_iam_role.name
}

####### node group ########

resource "aws_eks_node_group" "cluster_node_group_general_purpose" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = var.node_group_general_purpose.name
  node_role_arn   = aws_iam_role.cluster_node_group_iam_role.arn
  subnet_ids      = var.private_subnets

  launch_template {
    name    = aws_launch_template.lt_node_group_general_purpose.name
    version = aws_launch_template.lt_node_group_general_purpose.latest_version
  }

  scaling_config {
    desired_size = var.node_group_general_purpose.desired_size
    max_size     = var.node_group_general_purpose.max_size
    min_size     = var.node_group_general_purpose.min_size
  }

  labels = {
    Name             = var.node_group_general_purpose.name
    tool             = "terraform"
    infra-env        = var.env
    infra-service    = var.service
    infra-node-group = var.node_group_general_purpose.name
  }

  tags = {
    Name               = var.node_group_general_purpose.name
    "eks:cluster-name" = aws_eks_cluster.cluster.name
    tool               = "terraform"
    infra-env          = var.env
    infra-service      = var.service
  }

  lifecycle {
    ignore_changes = [
      scaling_config
    ]
  }
  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_node_group_iam_role_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.cluster_node_group_iam_role_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.cluster_node_group_iam_role_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.cluster_node_group_iam_role_EKSNodeGroupPolicy,
    aws_iam_role_policy_attachment.cluster_node_group_iam_role_ssm_access,
    # aws_security_group.cluster_nodes_sg
    aws_eks_cluster.cluster
  ]
}

resource "aws_autoscaling_group_tag" "cluster_node_group_general_purpose" {
  for_each = { for k, v in local.asg-tags : k => v }

  autoscaling_group_name = aws_eks_node_group.cluster_node_group_general_purpose.resources[0].autoscaling_groups[0].name

  tag {
    key   = each.value.tagKey
    value = each.value.tagValue

    propagate_at_launch = true
  }
}
