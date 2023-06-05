terraform {
  backend "s3" {
    bucket  = "acceldata-prod-terraform-state"
    key     = "acceldata/test/rds/terraform.tfstate"
    region  = "us-east-1"
    profile = "test"
  }
}


provider "aws" {
  region                   = var.region
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "test"
}


data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket  = "acceldata-prod-terraform-state"
    key     = "acceldata/test/vpc/terraform.tfstate"
    region  = "us-east-1"
    profile = "test"
  }
}



####### RDS #####
module "rds_acceldata" {
  source                          = "../../modules/rds"
  database_identifier             = "acceldata-db"
  env = var.env
  allocated_storage               = 20
  max_allocated_storage           = 100
  iops                            = 3000
  engine_version                  = "13.6"
  multi_az                        = false
  instance_type                   = "db.t4g.micro"
  storage_type                    = "gp3"
  vpc_id                          = data.terraform_remote_state.vpc.outputs.id
  backup_retention_period         = 1
  database_name                   = "python_app"
  deletion_protection             = true
  database_password               = var.password
  database_username               = "python_app"
  infra-env                       = "test"
  infra-service                   = "python-service"
  backup_window                   = "22:50-23:20"
  auto_minor_version_upgrade      = "false"
  maintenance_window              = "sat:08:15-sat:08:45"
  VPC_cidr_block = data.terraform_remote_state.vpc.outputs.cidr_block
}
