#!/bin/bash
apt-get update
apt-get -y install nginx
echo "I must regenerate : ${force_redeploy}"
#comment line below if you want to hide this function
echo "${force_redeploy}" >> /var/www/html/index.nginx-debian.html
echo "The current server is: " >> /var/www/html/index.nginx-debian.html
curl http://169.254.169.254/latest/meta-data/local-hostname >> /var/www/html/index.nginx-debian.html