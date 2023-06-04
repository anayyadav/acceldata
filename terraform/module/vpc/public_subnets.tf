######################
## Public Subnets ##
######################


resource "aws_subnet" "public_subnet" {
  count                   = length(local.azs_regions)
  availability_zone       = element(local.azs_regions, count.index)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, var.cidr_newbits, length(local.azs_regions) + count.index)
  map_public_ip_on_launch = true

  tags = {
    Name          = "${var.env}-${var.product}-public-${count.index + 1}"
    infra-env     = var.env
    infra-product = var.product
    infra-service = var.service
  }
  depends_on = [aws_vpc.main]
}



################################################
## Public Subnets, IG, Route table & Routes ##
################################################

## Creating Internet Gateway  ##

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name          = "${var.env}-${var.product}-igw"
    infra-env     = var.env
    infra-product = var.product
    infra-service = var.service
  }
}


## Creating route table ##

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name          = "${var.env}-${var.product}-public-rt"
    infra-env     = var.env
    infra-product = var.product
    infra-service = var.service
  }
}


## Adding Internet gateway to the route ##

resource "aws_route" "internet_igw" {
  route_table_id         = aws_route_table.public_rt.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
  depends_on             = [aws_route_table.public_rt, aws_internet_gateway.igw]
}





resource "aws_route_table_association" "public_subnet_to_route" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
  depends_on     = [aws_subnet.public_subnet, aws_route_table.public_rt]
}
