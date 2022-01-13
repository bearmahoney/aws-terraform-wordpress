data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  az1 = data.aws_availability_zones.available.names[0]
  az2 = data.aws_availability_zones.available.names[1]
}

resource "aws_vpc" "wordpress" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.wordpress.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = local.az1

  tags = {
    name = "private1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.wordpress.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = local.az2

  tags = {
    name = "private2"
  }
}

resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.wordpress.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = local.az1

  tags = {
    name = "public1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.wordpress.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = local.az2

  tags = {
    name = "public2"
  }
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.wordpress.id
}

resource "aws_nat_gateway" "nat_gateway" {
  subnet_id     = aws_subnet.public1.id
  allocation_id = aws_eip.nat.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.wordpress.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.wordpress.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}
