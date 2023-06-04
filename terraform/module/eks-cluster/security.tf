
resource "aws_security_group" "eks_private_sg" {
  name   = "${var.env}-cluster-eks-private-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "open all ports internally"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${var.VPC_cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                       = "${var.env}-cluster-eks-private-sg"
    env                                        = var.env
    "eks:cluster-name"                         = "${var.env}-cluster"
    tool                                       = "terraform"
    "kubernetes.io/cluster/${var.env}-cluster" = "owned"
  }
}



resource "aws_security_group" "eks-cluster-worker-node-sg" {
  name        = "${var.env}-cluster-eks-worker-node-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                       = "${var.env}-cluster-eks-worker-node-sg"
    "kubernetes.io/cluster/${var.env}-cluster" = "owned"
  }
}

resource "aws_security_group_rule" "eks-worker-node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks-cluster-worker-node-sg.id
  source_security_group_id = aws_security_group.eks-cluster-worker-node-sg.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-worker-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks-cluster-worker-node-sg.id
  source_security_group_id = aws_security_group.eks_private_sg.id
  to_port                  = 65535
  type                     = "ingress"
}