output "VPCID" {
  value = aws_vpc.main.id
}

output "VPC_cidr_block" {
  value = aws_vpc.main.cidr_block
}

output "AZsinVPC" {
  value = local.azs_regions
}

output "PrivateSubnetsinVPC" {
  value = aws_subnet.private_subnet.*.id
}

output "PublicSubnetsinVPC" {
  value = aws_subnet.public_subnet.*.id
}

output "DefaultRTofVPC" {
  value = aws_default_route_table.default-rt.id
}

output "DefaultSGofVPC" {
  value = aws_default_security_group.default-sg-vpc.id
}

output "RTofPublicSubnet" {
  value = aws_route_table.public_rt.id
}

output "RTofPrivateSubnet" {
  value = aws_route_table.private_rt.*.id
}

output "VPCEnv" {
  value = var.env
}

output "VPCService" {
  value = var.service
}

output "VPCProduct" {
  value = var.product
}