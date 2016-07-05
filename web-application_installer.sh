#!/bin/bash

# set environment variables

if (( $(grep IHS_DATA_DIR /etc/environment -c) == 0 )); then
        echo 'IHS_DATA_DIR=/var/www/data/' >> /etc/environment
		echo 'IHS_APP_DIR=/var/www/web-application/' >> /etc/environment
		mkdir ${IHS_APP_DIR}
		mkdir ${IHS_DATA_DIR}
		virtualenv --no-site-packages ${IHS_APP_DIR}../virtenv
fi

# Extract Main Application to apache web server root

tar -xf web-appliaction.tar -C ${IHS_APP_DIR}
cp confs/web-application.conf /etc/apache2/sites-available/web-application.conf

# Fix Permissions

chown -R www-data:www-data ${IHS_DATA_DIR}

chmod -R 740 ${IHS_DATA_DIR}

chmod +x ${IHS_APP_DIR}scripts/*

# Packages install python

source ${IHS_APP_DIR}../virtenv/bin/activate

pip install -r ${IHS_APP_DIR}requirements.txt

# Enable wshi mod

a2enmod wsgi

# Enable Sites

a2ensite web-application

# web-application install end