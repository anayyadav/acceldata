###########################################
## Gateway VPC Endpoint                  ##
###########################################

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.dynamodb"

  tags = {
    Name          = "${var.env}-${var.product}-vpc-endpoint-dynamodb"
    infra-env     = var.env
    infra-product = var.product
    infra-service = var.service
  }
}


resource "aws_vpc_endpoint_route_table_association" "dynamodb_private_rt" {
  route_table_id  = aws_route_table.private_rt.id
  vpc_endpoint_id = aws_vpc_endpoint.dynamodb.id
  depends_on      = [aws_route_table.private_rt, aws_vpc_endpoint.dynamodb]
}


resource "aws_vpc_endpoint_route_table_association" "dynamodb_public_rt" {
  route_table_id  = aws_route_table.public_rt.id
  vpc_endpoint_id = aws_vpc_endpoint.dynamodb.id
  depends_on      = [aws_route_table.public_rt, aws_vpc_endpoint.dynamodb]
}

resource "aws_vpc_endpoint_route_table_association" "dynamodb_main_rt" {
  route_table_id  = aws_vpc.main.default_route_table_id
  vpc_endpoint_id = aws_vpc_endpoint.dynamodb.id
  depends_on      = [aws_vpc_endpoint.dynamodb]
}