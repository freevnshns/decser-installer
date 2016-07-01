tar -xf web-appliaction.tar.gz

# Copy Main Application to apache web server root

cp -rf web-application /var/www/

# Permissions

chown -R www-data:www-data ${IHS_DATA_DIR}

chmod -R 740 ${IHS_DATA_DIR}

chmod +x ${IHS_APP_DIR}scripts/*

# Virtual Environment Setup

virtualenv --no-site-packages ${IHS_APP_DIR}../virtenv

source ${IHS_APP_DIR}../virtenv/bin/activate

pip install -r ${IHS_APP_DIR}requirements.txt

#Enable SSL Module

a2enmod wsgi

#Enable Sites

a2ensite web-application

# web-application install end