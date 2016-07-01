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

# Copying & Enabling Apache Configuration files

rm -f /etc/apache2/sites-available/*.conf
rm -f /etc/apache2/sites-enabled/*.conf

cp confs/apache2.conf /etc/apache2/apache2.conf
cp confs/web-application.conf /etc/apache2/sites-available/web-application.conf
cp confs/public-web-api.conf /etc/apache2/sites-available/public-web-api.conf

# Creating User File Upload Directories and set env variables
# edit .bashrc in user and something else in limited-user

echo 'IHS_DATA_DIR=/var/www/data/' >> /etc/environment
echo 'IHS_APP_DIR=/var/www/web-application/' >> /etc/environment

# INSTALL web-application and public-web-api

./web-application_installer.sh

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
