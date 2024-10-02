#!/bin/bash

# Load the token from secrets.tfvars
token=$(grep 'token' secrets.tfvars | cut -d '=' -f2 | tr -d ' "')

# Change to actions-runner directory
cd /home/ubuntu/actions-runner || { echo "Failed to change directory"; exit 1; }

# Make the script executable
chmod +x ./config.sh

# Install expect if not already installed
if ! command -v expect &> /dev/null; then
    sudo apt-get install -y expect
fi

# Create an expect script to automate the runner configuration
expect << EOF
set timeout -1

spawn ./config.sh --url https://github.com/Tim-eleazu/Test-Task --token ${token}

expect "Enter the name of the runner group to add this runner to: " {
    send "\r"
}

expect "Enter the name of runner: " {
    send "\r"
}

expect "Enter any additional labels (ex. label-1,label-2): " {
    send "\r"
}

expect "Enter name of work folder: " {
    send "\r"
}

expect eof
EOF

# Check if config was successful
if [ $? -ne 0 ]; then
    echo "Runner configuration failed"
    exit 1
fi

# Install the GitHub Actions runner service
sudo ./svc.sh install

# Start the service
sudo ./svc.sh start

# Check if the service started successfully
if [ $? -eq 0 ]; then
    echo "GitHub Actions runner service started successfully."
else
    echo "Failed to start the GitHub Actions runner service."
    exit 1
fi