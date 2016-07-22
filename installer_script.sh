#!/bin/bash

set -e

apt-get update

# Install Supervisor

apt-get --assume-yes install supervisor

apt-get --assume-yes install mediatomb

# Install Dependencies and Applications

apt-get --assume-yes install apache2 apache2-mpm-prefork apache2-utils libexpat1

apt-get --assume-yes install aria2

# Adding users

useradd user -m -s /bin/bash
useradd limited-user -m -s /sbin/nologin

# SSH Configuration

ssh-keygen -t rsa -f user_key -P ""
mkdir -p /home/user/.ssh
mkdir -p /home/user/downloads
mkdir -p /home/user/media
cat user_key.pub > /home/user/.ssh/authorized_keys

ssh-keygen -t rsa -f limited-user_key -P ""
mkdir -p /home/limited-user/.ssh
cat limited-user_key.pub > /home/limited-user/.ssh/authorized_keys

chown -R user:user /home/user/.ssh
chown -R limited-user:limited-user /home/limited-user/.ssh

# SSH Configuration END

printf '\n[program:aria2]\ncommand=/usr/bin/aria2c --enable-rpc --rpc-listen-all --dir=/home/user/downloads --save-session=/home/user/downloads/session_aria --force-save=true --rpc-save-upload-metadata=true --follow-torrent=true --follow-metalink=true --force-save=true --on-download-error=/home/user/downloads/aria_dwnld_fail_hook.sh' >> /etc/supervisor/supervisord.conf

# web-application

# Copying & Enabling Apache Configuration files

rm -f /etc/apache2/sites-available/*
rm -f /etc/apache2/sites-enabled/*
rm -rf /var/www/*

# INSTALL web-application (with public-api endpoints)

chmod +x web-application_installer.sh

chmod +x public-api_installer.sh

./web-application_installer.sh

./public-api_installer.sh

a2enmod wsgi

a2ensite web-application

a2ensite public-api

# Owncloud Installation

wget -nv https://download.owncloud.org/download/repositories/stable/Debian_8.0/Release.key -O Release.key
apt-key add - < Release.key
sh -c "echo 'deb http://download.owncloud.org/download/repositories/stable/Debian_8.0/ /' >> /etc/apt/sources.list.d/owncloud.list"
apt-get update
apt-get --assume-yes install owncloud

service apache2 restart

OUTAPACHE=$?
if [[ $OUTSAPACHE -eq 1 ]]; then
	echo "Apache Error"
	exit 1
fi

apt-get --assume-yes install ddclient

# END-OF-SCRIPT
