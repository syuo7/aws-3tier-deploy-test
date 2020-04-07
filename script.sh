#!/bin/bash
sudo mkdir -p /etc/ssl/nginx
sudo wget -P /etc/ssl/nginx/ http://sourcebird.net/solution/temp/nginx/nginx-repo.crt
sudo wget -P /etc/ssl/nginx/ http://sourcebird.net/solution/temp/nginx/nginx-repo.key
sudo wget http://nginx.org/keys/nginx_signing.key && sudo apt-key add nginx_signing.key
sudo apt-get install -y apt-transport-https lsb-release ca-certificates
printf "deb https://plus-pkgs.nginx.com/ubuntu `lsb_release -cs` nginx-plus\n" | sudo tee /etc/apt/sources.list.d/nginx-plus.list
sudo wget -P /etc/apt/apt.conf.d https://cs.nginx.com/static/files/90nginx
sudo apt-get -y update
sudo apt-get install -y nginx-plus
sudo service nginx start
sudo sudo mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak
sudo wget -P $HOME/  http://sourcebird.net/solution/temp/nginx/app.conf
sudo wget -P $HOME/ http://sourcebird.net/solution/temp/nginx/demo-index.html
sudo mv $HOME/app.conf /etc/nginx/conf.d
sudo mv $HOME/demo-index.html /usr/share/nginx/html
sudo nginx -s reload
nginx -v

