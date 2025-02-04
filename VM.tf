# Create the EC2 instance
resource "aws_instance" "runner_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
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
