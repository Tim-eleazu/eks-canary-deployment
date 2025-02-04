# Keypair

resource "tls_private_key" "generated" {
  algorithm = "RSA"
}

resource "local_file" "private_key_pem" {
  content  = tls_private_key.generated.private_key_pem
  filename = var.keypair_file_name
}

resource "aws_key_pair" "generated" {
  key_name   = var.keypair_key_name
  public_key = tls_private_key.generated.public_key_openssh
}