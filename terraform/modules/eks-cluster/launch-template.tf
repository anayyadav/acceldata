data "aws_ami" "linux_eks_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amazon-eks-node-1.23-v*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["602401143452"]
}

locals {
  node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh  --kubelet-extra-args '--node-labels=infra-env='${var.env}',infra-service=kubernetes,infra-node-group=node-group-general-purpose,eks.amazonaws.com/capacityType=ON_DEMAND,eks.amazonaws.com/nodegroup=node-group-general-purpose,Name=new-node-group-general-purpose'  --apiserver-endpoint '${aws_eks_cluster.cluster.endpoint}' --b64-cluster-ca '${aws_eks_cluster.cluster.certificate_authority[0].data}' '${var.env}'
USERDATA
}

resource "aws_launch_template" "lt_node_group_general_purpose" {
  name = "LT-node-group-general-purpose"

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
        Name          = "new-node-group-general-purpose"
        infra-env     = var.env
        infra-service = var.service
      }
    }
  }
  user_data = base64encode(templatefile("${path.module}/user-data/node_group_general_purpose_user_data.tftpl", { env = var.env, aws_eks_cluster_cluster_endpoint = aws_eks_cluster.cluster.endpoint, aws_eks_cluster_cluster_certificate_authority_data = aws_eks_cluster.cluster.certificate_authority[0].data }))
}
