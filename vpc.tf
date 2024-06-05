# Virtual Private Cloud
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "pj_vpc"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count  = length(var.az)
  vpc_id = aws_vpc.vpc.id

  cidr_block        = "10.0.${var.cidr_num_public[count.index]}.0/24"
  availability_zone = element(var.az, count.index)

  map_public_ip_on_launch = true

  tags = {
    Name = "pj_public_${element(var.short_az, count.index)}"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count  = length(var.az)
  vpc_id = aws_vpc.vpc.id

  cidr_block        = "10.0.${var.cidr_num_private[count.index]}.0/24"
  availability_zone = element(var.az, count.index)

  #map_public_ip_on_launch = true

  tags = {
    Name = "pj_private_${element(var.short_az, count.index)}_1"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "pj_igw"
  }
}

# Elastic Internet Protocols for Network Address Translation Gateways
resource "aws_eip" "eip" {
  count  = length(var.az)
  domain = "vpc"

  lifecycle {
    create_before_destroy = true
  }
}

# Network Address Translation Gateways
resource "aws_nat_gateway" "natgw" {
  count         = length(var.az)
  allocation_id = element(aws_eip.eip.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "pj_NATGW_${element(var.short_az, count.index)}"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public_rt" {
  count  = length(var.az)
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "pj_public_rt_${element(var.short_az, count.index)}"
  }
}

# Route Table Association for Public Subnets to Internet Gateway
resource "aws_route" "public_igw_route" {
  count                  = length(var.az)
  route_table_id         = element(aws_route_table.public_rt.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Route Table Association for Public Subnets
resource "aws_route_table_association" "public_rt_ac" {
  count          = length(var.az)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public_rt.*.id, count.index)
}

# Route Table for First Private Subnets
resource "aws_route_table" "private_rt" {
  count  = length(var.az)
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "pj_private_rt_${element(var.short_az, count.index)}_1"
  }
}

# Route Table Association for Private Subnets
resource "aws_route_table_association" "private_rt_ac_1" {
  count          = length(var.az)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private_rt.*.id, count.index)
}
