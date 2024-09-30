resource "aws_vpc" "vpc-name" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = var.vpc-name
  }
}

resource "aws_subnet" "subnet-name" {
  vpc_id                  = aws_vpc.vpc-name.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
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
    for port in [22, 80, 443, 8080, 9000, 3000, 10250] : {
      description      = "Allowing sonarqube, SSH and docker access"
      from_port        = port
      to_port          = port
      ipv6_cidr_blocks = ["::/0"]
      self             = false
      prefix_list_ids  = []
      security_groups  = []
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
  ]

  egress {
    description      = "for all outgoing traffics"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

  }
}

resource "aws_subnet" "public-subnet2" {
  vpc_id                  = aws_vpc.vpc-name.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = var.subnet-name2
  }
}

resource "aws_route_table" "rt-name2" {
  vpc_id = aws_vpc.vpc-name.id
  route {
    cidr_block = "0.0.0.0/0"
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