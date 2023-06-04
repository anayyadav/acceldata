

####### general purpose node group ########

resource "aws_eks_node_group" "cluster_node_group_eks_tools" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = var.node_group_eks_tools.name
  node_role_arn   = aws_iam_role.cluster_node_group_iam_role.arn
  subnet_ids      = var.private_subnets

  launch_template {
    name    = aws_launch_template.lt_node_group_eks_tools.name
    version = aws_launch_template.lt_node_group_eks_tools.latest_version
  }

  scaling_config {
    desired_size = var.node_group_eks_tools.desired_size
    max_size     = var.node_group_eks_tools.max_size
    min_size     = var.node_group_eks_tools.min_size
  }

  labels = {
    Name             = var.node_group_eks_tools.name
    tool             = "terraform"
    infra-env        = var.service
    infra-product    = var.product
    infra-service    = var.service
    infra-node-group = var.node_group_eks_tools.name
  }

  tags = {
    Name               = var.node_group_eks_tools.name
    "eks:cluster-name" = aws_eks_cluster.cluster.name
    tool               = "terraform"
    infra-env          = var.service
    infra-product      = var.product
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

resource "aws_autoscaling_group_tag" "cluster_node_group_eks_tools" {
  for_each = { for k, v in local.asg-tags : k => v }

  autoscaling_group_name = aws_eks_node_group.cluster_node_group_eks_tools.resources[0].autoscaling_groups[0].name

  tag {
    key   = each.value.tagKey
    value = each.value.tagValue

    propagate_at_launch = true
  }
}

resource "aws_launch_template" "lt_node_group_eks_tools" {
  name = "eks-tools-LT"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 10
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }
  capacity_reservation_specification {
    capacity_reservation_preference = "none"
  }

  credit_specification {
    cpu_credits = "unlimited"
  }
  disable_api_stop        = false
  disable_api_termination = false
  ebs_optimized           = true

  image_id      = data.aws_ami.linux_eks_ami.image_id
  instance_type = "t3a.micro"
  key_name      = "ec2-prod"

  vpc_security_group_ids = [aws_security_group.eks-cluster-worker-node-sg.id]

  dynamic "tag_specifications" {
    for_each = toset(var.to_tag)
    content {
      resource_type = tag_specifications.key
      tags = {
        Name          = "eks-tools-node-group"
        infra-env     = var.env
        infra-product = var.product
        infra-service = var.service
      }
    }
  }
  user_data = base64encode(templatefile("${path.module}/user-data/node_group_eks_tools_user_data.tftpl", { env = var.env, product = var.product, aws_eks_cluster_cluster_endpoint = aws_eks_cluster.cluster.endpoint, aws_eks_cluster_cluster_certificate_authority_data = aws_eks_cluster.cluster.certificate_authority[0].data }))
}