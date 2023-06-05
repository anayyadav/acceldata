variable "env" {
  description = "env type ex: prod, qa, dev"
}

variable "service" {
  description = "name of the service"
}

variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
}

variable "region" {
  description = "region name"
}



variable "public_subnet_cidr" {
  type    = list(any)
  default = ["0.0/20", "16.0/20", "32.0/20"]
}

variable "private_subnet_cidr" {
  type    = list(any)
  default = ["48.0/20", "64.0/20", "80.0/20"]
}


variable "cidr_newbits" {
  description = "cidr Newbits for incrementing subnets cidr"
}
