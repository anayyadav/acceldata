


###########################################
## Gateway VPC Endpoint                  ##
###########################################

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.s3"

  tags = {
    Name          = "${var.env}-${var.product}-vpc-endpoint-s3"
    infra-env     = var.env
    infra-product = var.product
    infra-service = var.service
  }
}



resource "aws_vpc_endpoint_route_table_association" "s3_private_rt" {
  route_table_id  = aws_route_table.private_rt.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  depends_on      = [aws_route_table.private_rt, aws_vpc_endpoint.s3]
}


resource "aws_vpc_endpoint_route_table_association" "s3_public_rt" {
  route_table_id  = aws_route_table.public_rt.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  depends_on      = [aws_route_table.public_rt, aws_vpc_endpoint.s3]
}

resource "aws_vpc_endpoint_route_table_association" "s3_main_rt" {
  route_table_id  = aws_vpc.main.default_route_table_id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  depends_on      = [aws_vpc_endpoint.s3]
}