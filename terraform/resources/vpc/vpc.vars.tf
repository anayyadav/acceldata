variable "env" {
  description = "env type ex: prod, qa, dev"
}

variable "service" {
  description = "name of the service"
}

variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
}

variable "aws_region" {
  description = "AWS Region Name"
}

variable "cidr_newbits" {
  description = "cidr Newbits for incrementing subnets cidr"
}
