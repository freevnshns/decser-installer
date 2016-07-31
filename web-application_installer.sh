#!/bin/bash

# set environment variables

set -e

export IHS_DATA_DIR=/var/www/data/
export IHS_APP_DIR=/var/www/web-application/

if (( $(grep IHS_DATA_DIR /etc/environment -c) == 0 )); then
	apt-get --assume-yes install python-virtualenv python-pip libapache2-mod-wsgi python-dev imagemagick
	mkdir -p ${IHS_APP_DIR}
	mkdir -p ${IHS_DATA_DIR}
	virtualenv --no-site-packages ${IHS_APP_DIR}../virtenv
	echo 'export IHS_DATA_DIR=/var/www/data/' >> /etc/apache2/envvars
	echo 'export IHS_APP_DIR=/var/www/web-application/' >> /etc/apache2/envvars
	echo 'IHS_DATA_DIR=/var/www/data/' >> /etc/environment
	echo 'IHS_APP_DIR=/var/www/web-application/' >> /etc/environment
fi

# Extract Main Application to apache web server root

tar -xvf web-application.tar -C ${IHS_APP_DIR}

echo "<VirtualHost *:80>
    ServerName example.com

    WSGIDaemonProcess web-application
    WSGIScriptAlias / ${IHS_APP_DIR}web-application.wsgi

    <Directory /var/www/web-application>
        WSGIProcessGroup web-application
        WSGIApplicationGroup %{GLOBAL}
        Require all granted
    </Directory>
</VirtualHost>" > /etc/apache2/sites-available/web-application.conf

# Fix Permissions

chown -R www-data:www-data ${IHS_DATA_DIR}

chmod -R 740 ${IHS_DATA_DIR}

chown -R www-data:www-data ${IHS_APP_DIR}

chmod -R 740 ${IHS_APP_DIR}

chmod +x ${IHS_APP_DIR}scripts/*

# Install requirements to virtualenv

source ${IHS_APP_DIR}../virtenv/bin/activate

pip install -r ${IHS_APP_DIR}requirements.txt

deactivate

service apache2 restart

# web-application module install end
