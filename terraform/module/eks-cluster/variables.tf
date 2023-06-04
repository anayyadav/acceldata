variable "region" {
}

data "aws_availability_zones" "azs" {
}

variable "env" {
}

variable "product" {
}

variable "service" {
}

variable "cluster" {
  default = {
    name = "qa-cluster"
  }

  type = object({
    name = string
  })
}

variable "to_tag" {
  default     = ["instance", "volume"]
  description = "tags which need to implement in lauched template"
}

variable "node_group_general_purpose" {
  default = {
    name           = "general-purpose-node-group"
    instance_types = ["t3a.micro"]
    desired_size   = 1
    max_size       = 1
    min_size       = 1
  }

  type = object({
    name           = string
    instance_types = list(string)
    desired_size   = number
    max_size       = number
    min_size       = number
  })
}

variable "node_group_eks_tools" {
  default = {
    name           = "eks-tools-node-group"
    instance_types = ["t3a.micro"]
    desired_size   = 1
    max_size       = 1
    min_size       = 1
  }

  type = object({
    name           = string
    instance_types = list(string)
    desired_size   = number
    max_size       = number
    min_size       = number
  })
}

variable "private_subnets" {

}

variable "vpc_id" {

}

variable "VPC_cidr_block" {

}