
# Define variables
variable "region" {
  default = "us-east-1"
}

variable "ami_id" {
  default = "ami-0c55b159cbfafe1f0"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "my-key"
}

variable "private_subnet_ids" {
  default = ["subnet-123456", "subnet-789012"]
}

variable "public_subnet_ids" {
  default = ["subnet-345678", "subnet-901234"]
}

variable "vpc_id" {
  default = "vpc-abcdef"
}

# Create VPC and subnets
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_ids)

  cidr_block = "10.0.${n count + 1}.0/24"
  vpc_id     = aws_vpc.main.id

  tags = {
    Name = "private-subnet-${count + 1}"
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_ids)

  cidr_block = "10.0.${count + 3}.0/24"
  vpc_id     = aws_vpc.main.id

  tags = {
    Name = "public-subnet-${count + 1}"
  }
}