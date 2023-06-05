
######################
## private Subnets  ##
######################

resource "aws_subnet" "private_subnet" {
  count             = length(local.azs_regions)
  availability_zone = element(local.azs_regions, count.index)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, var.cidr_newbits, count.index)

  tags = {
    Name          = "${var.env}-private-${count.index + 1}"
    infra-env     = var.env
    infra-service = var.service

  }
}

## Creating EIP  ##

resource "aws_eip" "eip" {
  public_ipv4_pool = "amazon"

  tags = {
    Name          = "${var.env}-eip"
    infra-env     = var.env
    infra-service = var.service
  }

}


## Creating NAT Gateway  ##

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet[0].id


  tags = {
    Name          = "${var.env}-ngw"
    infra-env     = var.env
    infra-service = var.service
  }
  depends_on = [aws_internet_gateway.igw, aws_subnet.public_subnet]
}


###########################################
## private Subnets Route table & Routes ##
###########################################

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name          = "${var.env}-private-rt"
    infra-env     = var.env
    infra-service = var.service
  }
}

## Adding Nat gateway to the route ##

resource "aws_route" "nat-gw" {
  route_table_id         = aws_route_table.private_rt.id
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
  destination_cidr_block = "0.0.0.0/0"
  depends_on             = [aws_route_table.private_rt, aws_nat_gateway.nat_gw]

}

resource "aws_route_table_association" "private_subnet_to_route" {
  count          = length(aws_subnet.private_subnet)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt.id
  depends_on     = [aws_subnet.private_subnet, aws_route_table.private_rt]
}
