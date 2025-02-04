resource "aws_vpc" "vpc-name" {
  cidr_block = var.vpc-cidr-block
  tags = {
    Name = var.vpc-name
  }
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_subnet" "subnet-name" {
  vpc_id                  = aws_vpc.vpc-name.id
  cidr_block              = var.subnet_cidr1
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = var.subnet-name
  }
}

resource "aws_internet_gateway" "igw-name" {
  vpc_id = aws_vpc.vpc-name.id

  tags = {
    Name = var.igw-name
  }
}

resource "aws_security_group" "security-group-name" {
  name        = "security-group-name"
  vpc_id      = aws_vpc.vpc-name.id
  description = "SG for EC2"
  ingress = [
    for port in [22, 80, 443, 8080, 9000, 3000, 10250, 8081] : {
      description      = "Port Access"
      from_port        = port
      to_port          = port
      ipv6_cidr_blocks = ["::/0"]
      self             = false
      prefix_list_ids  = []
      security_groups  = []
      protocol         = "tcp"
      cidr_blocks      = [var.cidr]
    }
  ]

  egress {
    description      = "for all outgoing traffics"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.cidr]
    ipv6_cidr_blocks = ["::/0"]

  }
}

resource "aws_subnet" "public-subnet2" {
  vpc_id                  = aws_vpc.vpc-name.id
  cidr_block              = var.subnet_cidr
  availability_zone       = var.subnet2_availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = var.subnet-name2
  }
}

resource "aws_route_table" "rt-name2" {
  vpc_id = aws_vpc.vpc-name.id
  route {
    cidr_block = var.cidr
    gateway_id = aws_internet_gateway.igw-name.id
  }

  tags = {
    Name = var.rt-name2
  }
}


resource "aws_route_table_association" "rt-association" {
  route_table_id = aws_route_table.rt-name2.id
  subnet_id      = aws_subnet.subnet-name.id
}

resource "aws_route_table_association" "rt-association2" {
  route_table_id = aws_route_table.rt-name2.id
  subnet_id      = aws_subnet.public-subnet2.id
}