#!bin/bash

echo "Hello" > /home/ubuntu/installapp.txt
sudo apt-get update -y
sudo apt-get install -y apache2
sudo systemctl enable apache2
sudo systemctl start apache2
sudo apt-get install -y git
git clone https://github.com/Javeria-Nasir/boostrap-website.git
cp -r boostrap-website/* /var/www/html/