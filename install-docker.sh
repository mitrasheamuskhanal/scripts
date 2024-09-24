#!/bin/bash
#Author : MSK
#Date of creation: 2024-03-15
#Date of modification: 2024-03-15
#Description: This script is used to install docker
# Exit on any error
set -e

# Update the package list
echo "Updating package list..."
apt-get update

# Install required packages
echo "Installing prerequisites..."
apt-get install -y ca-certificates curl gnupg lsb-release

# Create the keyrings directory if it doesn't exist
echo "Creating keyrings directory..."
mkdir -p /etc/apt/keyrings

# Add Docker’s official GPG key
echo "Adding Docker GPG key..."
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up the stable repository for Docker
echo "Setting up Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the package list again
echo "Updating package list with Docker repository..."
apt-get update

echo "Docker repository added successfully."
# Install Docker packages
echo "Installing Docker and related packages..."
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start Docker service
echo "Starting Docker service..."
systemctl start docker

# Enable Docker to start on boot
echo "Enabling Docker to start on boot..."
systemctl enable docker

echo "Docker installation completed successfully."