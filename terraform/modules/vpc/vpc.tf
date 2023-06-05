#################################################
## Private Subnets: 3                          ##
## Public Subnet: 3                            ##
## Internet Gateway: 1                         ##
## EIP : 1                                     ##
## Nat Gateway: 1                              ##
## Route Tables: 2                             ##
## Routes for NG & IG                          ##
## Subnet and Route Table Association          ##
## S3 VPC endpoint: 1                          ##
## S3 VPC endpoint and Rote Table Association  ##
#################################################


data "aws_availability_zones" "azs" {}



locals {
  azs_regions = tolist(setsubtract(data.aws_availability_zones.azs.names, ["us-east-1d", "us-east-1e", "us-east-1f"]))
}

## Creating VPC ##


resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name          = "${var.env}-vpc"
    infra-env     = var.env
    infra-service = var.service
  }
}

resource "aws_default_route_table" "default-rt" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  tags = {
    Name          = "${var.env}-default-rt"
    infra-env     = var.env
    infra-service = var.service
  }
}

resource "aws_default_security_group" "default-sg-vpc" {
  vpc_id     = aws_vpc.main.id
  depends_on = [aws_vpc.main]

  tags = {
    Name          = "${var.env}-sg-vpc"
    infra-env     = var.env
    infra-service = var.service
  }
}

resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.main.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = 6
    rule_no    = 1
    action     = "allow"
    cidr_block = aws_vpc.main.cidr_block
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = 6
    rule_no    = 2
    action     = "allow"
    cidr_block = aws_vpc.main.cidr_block
    from_port  = 3389
    to_port    = 3389
  }

  ingress {
    protocol   = 6
    rule_no    = 3
    action     = "allow"
    cidr_block = aws_vpc.main.cidr_block
    from_port  = 5432
    to_port    = 5432
  }

  ingress {
    protocol   = 6
    rule_no    = 4
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = 6
    rule_no    = 5
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 3389
    to_port    = 3389
  }


  ingress {
    protocol   = 6
    rule_no    = 6
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 5432
    to_port    = 5432
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  lifecycle {
    ignore_changes = [subnet_ids]
  }
  tags = {
    Name          = "${var.env}-nacl"
    infra-env     = var.env
    infra-service = var.service
  }
}

