#!/bin/bash
#Author : MSK
#Date of creation: 2024-03-15
#Date of modification: 2024-03-15
#Description: This script is used to install jenkins
apt update && apt upgrade -y
apt install wget unzip -y
sudo apt install default-jdk -y
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y
sudo systemctl start jenkins
sudo systemctl enable jenkins
 echo "The Jenkins URL is: http://$(hostname -I | awk '{print $1}'):8080"
 echo "Jenkins Password is: $(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)"