#!/bin/bash

# Load values from the secrets.tfvars file
access_key=$(grep 'key_id' secrets.tfvars | cut -d '=' -f2 | tr -d ' "')
secret_key=$(grep 'secret_acess_key' secrets.tfvars | cut -d '=' -f2 | tr -d ' "')

# Update and install Java
sudo apt update -y
sudo apt install -y fontconfig openjdk-17-jre 

mkdir actions-runner && cd actions-runner

# # Download the Github actions
curl -o actions-runner-linux-x64-2.319.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.319.1/actions-runner-linux-x64-2.319.1.tar.gz
tar xzf ./actions-runner-linux-x64-2.319.1.tar.gz

# Install Docker
sudo apt install -y docker.io
sudo usermod -aG docker bitbucketrunner
sudo usermod -aG docker $USER  # Assuming this script is run as the 'ubuntu' user.
sudo systemctl restart docker
sudo chmod 666 /var/run/docker.sock  #Doing this because it's just a test script

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install

# Set up AWS credentials
mkdir -p /home/ubuntu/.aws
cat <<EOL > /home/ubuntu/.aws/credentials
[default]
aws_access_key_id = ${access_key}
aws_secret_access_key = ${secret_key}
EOL

chown -R ubuntu:ubuntu /home/ubuntu/.aws
chmod 600 /home/ubuntu/.aws/credentials

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl version --client

# Install Terraform
sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update -y 
sudo apt-get install -y terraform