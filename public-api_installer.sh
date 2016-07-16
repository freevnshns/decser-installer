set -e

export IHS_API_DIR=/var/www/public-api/

if (( $(grep IHS_API_DIR /etc/environment -c) == 0 )); then
	mkdir -p ${IHS_API_DIR}public_uploads
	echo 'IHS_API_DIR=/var/www/public-api/' >> /etc/apache2/envvars
	echo 'IHS_API_DIR=/var/www/public-api/' >> /etc/environment
fi

tar -xvf public-api.tar -C ${IHS_API_DIR}

echo "<VirtualHost *:10000>

    WSGIDaemonProcess public-api
    WSGIScriptAlias / ${IHS_API_DIR}public-api.wsgi

    <Directory /var/www/public-api>
        WSGIProcessGroup public-api
        WSGIApplicationGroup %{GLOBAL}
        Require all granted
    </Directory>
</VirtualHost>" > /etc/apache2/sites-available/public-api.conf

# Fix Permissions

chown -R www-data:www-data ${IHS_API_DIR}

chmod -R 740 ${IHS_API_DIR}

service apache2 restart
