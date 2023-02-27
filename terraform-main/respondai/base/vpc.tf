# Define a vpc
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.prefix}"
    createdBy = "infra-${var.prefix}/base"
  }
}

resource "aws_ssm_parameter" "vpc" {
  name = "/${var.prefix}/base/vpc_id"
  value = "${aws_vpc.vpc.id}"
  type  = "String"
}

# Routing table for public subnets
resource "aws_route_table" "public_subnet_routes" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
  tags = {
    Name = "Public subnet routing table"
    createdBy = "infra-${var.prefix}/base"
  }
}

# Internet gateway for the public subnet
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name = "Public gateway"
    createdBy = "infra-${var.prefix}/base"
  }
}

# For Public subnets

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr_blocks)
  cidr_block = var.public_subnet_cidr_blocks[count]
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.5.0.0/24"
  availability_zone = var.availability_zones[count]
  
  tags = {
    Name = "public-subnet-${count + 1}"
  }
}

resource "aws_ssm_parameter" "public_subnet" {
  name = "/${var.prefix}/base/subnet/public/id"
  value = "${aws_subnet.public.id}"
  type  = "String"
}


# For Private subnets

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr_blocks)
  cidr_block = var.private_subnet_cidr_blocks[count]
  vpc_id = aws_vpc.vpc.id
  availability_zone = var.availability_zones[count]

  tags = {
    Name = "private-subnet-${count + 1}"
  }
}

resource "aws_ssm_parameter" "private_subnet" {
  name = "/${var.prefix}/base/subnet/private/id"
  value = "${aws_subnet.public.id}"
  type  = "String"
}

# Create NAT gateway
resource "aws_nat_gateway" "main" {
  count = length(var.public_subnet_cidr_blocks)

  allocation_id = aws_eip.main[count].id
  subnet_id     = aws_subnet.public[count].id

  tags = {
    Name = "my-nat-gateway-${count + 1}"
  }
}

# Create Elastic IP for NAT gateway
resource "aws_eip" "main" {
  count = length(var.public_subnet_cidr_blocks)

  vpc = true

  tags = {
    Name = "my-eip-${count + 1}"
  }
}

# Create route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "private-route-table"
  }
}

# Associate the routing table to private subnet
resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidr_blocks)
  subnet_id      = aws_subnet.private[count].id
  route_table_id = aws_route_table.private.id
}

# Associate the routing table to public subnet 
resource "aws_route_table_association" "public" {
 count = length(var.public_subnet_cidr_blocks)

  subnet_id      = aws_subnet.public[count].id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "allow_http" {
  name_prefix = "allow-http"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-http"
  }
}

resource "aws_security_group" "allow_ssh" {
  name_prefix = "allow-ssh"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-ssh"
  }
}
