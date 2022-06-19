#! /bin/bash
sudo apt-get update
sudo apt-get -y install nginx
echo 'Hello World... EC2 working!!!' > /var/www/html/index.html
echo 'Hello World... EC2 working!!!' > /var/www/html/api/index.html