#!/bin/bash

# Error Logging

# Adding users

useradd user -m
useradd limited-user -m -s /sbin/nologin

# SSH Configurations

ssh-keygen -t rsa -f user_key -P ""
mkdir -p /home/user/.ssh
cat user_key.pub > /home/user/.ssh/authorized_keys

ssh-keygen -t rsa -f limited-user_key -P ""
mkdir -p /home/limited-user/.ssh
cat limited-user_key.pub > /home/limited-user/.ssh/authorized_keys

chown -R user:user /home/user/.ssh
chown -R limited-user:limited-user /home/limited-user/.ssh

# SSH Conf END

# web-application

apt-get update

# Install Dependencies and Applications

apt-get --assume-yes install apache2 apache2-mpm-prefork apache2-utils libexpat1
apt-get --assume-yes install libapache2-mod-wsgi python-dev python-pip imagemagick

pip install Flask

# Extract Comslav Package Archive

tar -xf ihs.tar.gz

# Copying & Enabling Apache Configuration files

rm -f /etc/apache2/sites-available/*.conf
rm -f /etc/apache2/sites-enabled/*.conf

cp confs/apache2.conf /etc/apache2/apache2.conf
cp confs/web-application.conf /etc/apache2/sites-available/web-application.conf
cp confs/public-web-api.conf /etc/apache2/sites-available/public-web-api.conf

# Creating User File Upload Directories and set env variables
# edit .bashrc in user and something else in limited-user

#Set Permissions

chown -R www-data /home/ihs
chmod -R 755 /home/ihs

# Copy Main Application to apache web server root
cp -Rf ihs/* /var/www/

#Execution Permissions for scripts
chmod +x /var/www/web-application/scripts/*

#Enable SSL Module
a2enmod wsgi

#Enable Sites
a2ensite web-application
a2ensite public-web-api

# web-application Install End

service apache2 restart
OUTAPACHE=$?
if [[ $OUTSAPACHE -eq 1 ]]; then
	echo "Apache Error"
	exit 1
fi

# Owncloud Installation

wget -nv https://download.owncloud.org/download/repositories/stable/Debian_8.0/Release.key -O Release.key
apt-key add - < Release.key
sh -c "echo 'deb http://download.owncloud.org/download/repositories/stable/Debian_8.0/ /' >> /etc/apt/sources.list.d/owncloud.list"
apt-get update
apt-get install owncloud

# Apache Global Redirection Scripts

cp ports.conf /etc/apache2/ports.conf


# END-OF-SCRIPT
