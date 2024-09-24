#!/bin/bash
# Author: MSK
# Date of creation: 2024-06-24
# Date of modification: 2024-06-24
# Description: This script is used to install Docker

# Exit on any error
set -e

echo "Your distro information:"
cat /etc/*release

# Ask the user for the distribution type
echo "Select your distribution:"
echo "1. Ubuntu"
echo "2. Debian"
read -p "Enter the number corresponding to your distribution (1 for Ubuntu, 2 for Debian): " distro_choice

# Update the package list
echo "Updating package list..."
apt-get update

# Install required packages
echo "Installing prerequisites..."
apt-get install -y ca-certificates curl gnupg lsb-release

# Create the keyrings directory if it doesn't exist
echo "Creating keyrings directory..."
mkdir -p /etc/apt/keyrings

# Add Docker’s official GPG key and set up the repository based on user choice
if [ "$distro_choice" -eq 1 ]; then
    # For Ubuntu
    echo "Adding Docker GPG key for Ubuntu..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    echo "Setting up Docker repository for Ubuntu..."
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
elif [ "$distro_choice" -eq 2 ]; then
    # For Debian
    echo "Adding Docker GPG key for Debian..."
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo "Setting up Docker repository for Debian..."
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
else
    echo "Invalid selection. Please run the script again and select either 1 or 2."
    exit 1
fi

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
