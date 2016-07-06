#!/bin/bash

set -e

# Adding users

useradd user -m -s /bin/bash
useradd limited-user -m -s /sbin/nologin

# SSH Configuration

ssh-keygen -t rsa -f user_key -P ""
mkdir -p /home/user/.ssh
cat user_key.pub > /home/user/.ssh/authorized_keys

ssh-keygen -t rsa -f limited-user_key -P ""
mkdir -p /home/limited-user/.ssh
cat limited-user_key.pub > /home/limited-user/.ssh/authorized_keys

chown -R user:user /home/user/.ssh
chown -R limited-user:limited-user /home/limited-user/.ssh

# SSH Configuration END

# web-application

apt-get update

# Install Dependencies and Applications

apt-get --assume-yes install apache2 apache2-mpm-prefork apache2-utils libexpat1

# Copying & Enabling Apache Configuration files

rm -f /etc/apache2/sites-available/*
rm -f /etc/apache2/sites-enabled/*
rm -rf /var/www/*

# INSTALL web-application

chmod +x web-application_installer.sh

./web-application_installer.sh

a2enmod wsgi

a2ensite web-application

# Owncloud Installation

wget -nv https://download.owncloud.org/download/repositories/stable/Debian_8.0/Release.key -O Release.key
apt-key add - < Release.key
sh -c "echo 'deb http://download.owncloud.org/download/repositories/stable/Debian_8.0/ /' >> /etc/apt/sources.list.d/owncloud.list"
apt-get update
apt-get install owncloud

service apache2 restart

OUTAPACHE=$?
if [[ $OUTSAPACHE -eq 1 ]]; then
	echo "Apache Error"
	exit 1
fi

# END-OF-SCRIPT
