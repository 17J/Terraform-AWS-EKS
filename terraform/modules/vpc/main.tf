resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "subnet" {
  count             = length(var.subnet_cidrs)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_cidrs[count.index]
  availability_zone = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.subnet_name}-${count.index}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.igw_name
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.route_table_name
  }
}

resource "aws_route_table_association" "route_table_association" {
  count          = length(var.subnet_cidrs)
  subnet_id      = aws_subnet.subnet[count.index].id
  route_table_id = aws_route_table.route_table.id
}
