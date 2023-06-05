
terraform {
  backend "s3" {
    bucket  = "acceldata-prod-terraform-state"
    key     = "acceldata/test/eks/terraform.tfstate"
    region  = "us-east-1"
    profile = "test"
  }
}

provider "aws" {
  region                   = var.region
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "test"
}


### VPC module ####

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket  = "acceldata-prod-terraform-state"
    key     = "acceldata/test/vpc/terraform.tfstate"
    region  = "us-east-1"
    profile = "test"
  }
}


######### VPC ############


module "test_eks_cluster" {
  source       = "../../modules/eks-cluster"
  env          = var.env
  region       = var.region
  service      = var.service
  private_subnets = data.terraform_remote_state.vpc.outputs.private_subnets_id
  VPC_cidr_block = data.terraform_remote_state.vpc.outputs.cidr_block
  vpc_id = data.terraform_remote_state.vpc.outputs.id
}
