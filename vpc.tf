resource "aws_vpc" "vpc-name" {
  cidr_block = "10.0.0.0/16"
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
    for port in [22, 80, 443, 8080, 9000, 3000, 10250, 8081] : {
      description      = "Port Access"
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



resource "tls_private_key" "generated" {
  algorithm = "RSA"
}

resource "local_file" "private_key_pem" {
  content  = tls_private_key.generated.private_key_pem
  filename = "MyAWSKey.pem"
}

resource "aws_key_pair" "generated" {
  key_name   = "MyAWSKey"
  public_key = tls_private_key.generated.public_key_openssh
}

# Create the EC2 instance
resource "aws_instance" "runner_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.medium"
  subnet_id                   = aws_subnet.public-subnet2.id
  security_groups             = [aws_security_group.security-group-name.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.generated.key_name

  tags = {
    Name = "Ubuntu EC2 Server"
  }

  lifecycle {
    ignore_changes = [security_groups]
  }

  # File provisioner to copy tar file to the instance
  provisioner "file" {
    source      = "./actions.tar.gz"  
    destination = "/tmp/actions.tar.gz"            

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.generated.private_key_pem  
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "./setup.tar.gz"  
    destination = "/tmp/setup.tar.gz"            

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.generated.private_key_pem  
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.generated.private_key_pem
      host        = self.public_ip
    }

    inline = [
      "cd /tmp",
      "tar -xvf setup.tar.gz",
      "chmod +x /tmp/setup.tar.gz",
      "tar -xvf actions.tar.gz",         
      "chmod +x /tmp/actions.sh",    
      "sh /tmp/actions.sh"              
    ]
  }
}
