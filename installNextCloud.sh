#!/bin/bash
#Author : MSK
#Date of creation: 2024-03-15
#Date of modification: 2024-03-15
#Description: This script is used to install nextcloud


# Step 1: Install Nginx and PHP
echo "Installing Nginx and PHP..."
sudo apt install nginx  php-fpm php-mysql php-zip php-gd -y
sudo apt update
sudo apt install php8.2-dom php8.2-xmlwriter php8.2-xmlreader php8.2-mbstring php8.2-simplexml php8.2-curl -y
sudo systemctl enable nginx
#sudo systemctl enable php-fpm
# Step 2: Downloading Nextcloud
echo "Downloading Nextcloud..."
#sudo wget https://download.nextcloud.com/server/releases/latest.zip 
apt install unzip -y
sudo unzip latest.zip
mv nextcloud /var/www/html/nextcloud
sudo chown -R www-data:www-data /var/www/html/nextcloud
sudo chmod -R 777 /var/www/html/nextcloud
# Define the Nginx configuration using a here document
nginx_config=$(cat <<EOF
# Nginx configuration
server {
    listen 8090 default_server;
    listen [::]:8090 default_server;

    root /var/www/html/nextcloud;
    index index.html index.htm index.php index.nginx-debian.html;

    server_name _;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF
)
# Write the Nginx configuration to a file
echo "$nginx_config" > /etc/nginx/conf.d/nextcloud.conf
sudo systemctl restart nginx
#sudo systemctl restart php8.2-fpm



# Step 3: Install MariaDB
echo "Installing MariaDB..."
sudo apt install mariadb-server -y
sudo systemctl restart mariadb

# Step 4: Creating Database
echo "Creating Database..."
echo "Give UsernameName For Your DATABASE ;"
read dbuser
echo "Give Name For Your DATABASE ;"
read dbname
echo "Give Password For Your DATABASE ;"
read dbpass
sudo mysql -u root <<EOF
CREATE DATABASE $dbname;
CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$dbpass';
GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'localhost';
FLUSH PRIVILEGES;
EOF

# Step 5: Setting up Nextcloud
echo "Setting up Nextcloud..."
sudo chmod -R 777 /var/www/html/nextcloud
echo "Acess to Nextcloud..."
echo  "http://$(hostname -I | awk '{print $1}'):8090"
echo  "Give username and password for nextcloud"
echo Database User: $dbuser
echo Database Password: $dbpass
echo Database Name: $dbname
echo Database Host : localhost:5432


