output "id" {
  value = module.test_vpc.VPCID
}

output "cidr_block" {
  value = module.test_vpc.VPC_cidr_block
}

output "private_subnets_id" {
  value = module.test_vpc.PrivateSubnetsinVPC
}

output "public_subnets_id" {
  value = module.test_vpc.PublicSubnetsinVPC
}
