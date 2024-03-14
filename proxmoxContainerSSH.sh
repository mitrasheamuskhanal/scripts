#!/bin/bash
#Author : MSK
#Date of creation: 2024-03-14
#Date of modification: 2024-03-14
#Description: This script is used to setup ssh connection in proxmox container
# Step 1: Setup root password
echo "Setting up root password..."
sudo passwd root

# Step 2: Enable SSH
echo "Enabling SSH..."
sudo sed -i 's/^#PermitRootLogin prohibit-password*/PermitRootLogin yes/' /etc/ssh/sshd_config


# Step 3: Restart SSH
echo "Restarting SSH..."
sudo systemctl restart sshd

echo "SSH connection setup completed. Please Check if SSH is working?"
echo "Here is the command to check  ssh root@$(hostname -I | awk '{print $1}')"

# Prompt user to check SSH connection
read -p "Is SSH  working? (y/n): " response

if [[ $response =~ ^[Yy]$ ]]; then
   echo "Thanks for using my script" 
else
    echo "Restrating your system it will fix  After restart you can connect with"
    echo "ssh root@$(hostname -I | awk '{print $1}')"
    reboot
fi
