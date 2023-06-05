terraform {
  backend "s3" {
    bucket  = "acceldata-prod-terraform-state"
    key     = "acceldata/test/vpc/terraform.tfstate"
    region  = "us-east-1"
    profile = "test"
  }
}

provider "aws" {
  region                   = var.aws_region
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "test"
}



######### VPC ############


module "test_vpc" {
  source       = "../../modules/vpc"
  env          = var.env
  region       = var.aws_region
  vpc_cidr     = var.vpc_cidr
  service      = var.service
  cidr_newbits = var.cidr_newbits
}
