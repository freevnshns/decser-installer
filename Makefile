SHELL := /bin/bash

default:
	echo "Here is help"

full: pkg-deps user apache aria mediatomb supervisor owncloud system-manager web-application xmpp
	echo "Successessfullllyy Installed Please reboot"

pkg-deps:
	apt-get update
	apt-get --assume-yes install sudo apache2 apache2-mpm-prefork apache2-utils libexpat1 libapache2-mod-wsgi python-pip python-dev supervisor aria2 mediatomb prosody libopencv-dev python-opencv python3-rpi.gpio cups

user:
	useradd user -m -s /bin/bash
	ssh-keygen -t rsa -f user_key -P ""
	mkdir -p /home/user/.ssh
	cat user_key.pub > /home/user/.ssh/authorized_keys
	chown -R user:user /home/user/.ssh

apache:
	a2enmod wsgi
	rm -rf /var/www/*

aria:
	mkdir -p /home/user/downloads/.conf
	touch /home/user/downloads/.conf/session_aria

owncloud:
	debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
	debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
	wget -nv https://download.owncloud.org/download/repositories/stable/Debian_8.0/Release.key -O Release.key
	apt-key add - < Release.key
	sh -c "echo 'deb http://download.owncloud.org/download/repositories/stable/Debian_8.0/ /' >> /etc/apt/sources.list.d/owncloud.list"
	apt-get update
	apt-get --assume-yes install owncloud

system-manager:
	mkdir -p /system-manager/
	cp system-manager.py /system-manager/system-manager.py

mediatomb:
	echo "Setup mediatomb"

web-application:
	pip install Flask
	printf "<VirtualHost *:80>\n\tWSGIDaemonProcess web-application\n\tWSGIScriptAlias / /var/www/web-application/web-application.wsgi\n\t\t<Directory /var/www/web-application>\n\t\tWSGIProcessGroup web-application\n\t\tWSGIApplicationGroup %%{GLOBAL}\n\t\tRequire all granted\n\t</Directory>\n</VirtualHost>" > /etc/apache2/sites-enabled/000-default.conf
	mkdir -p /var/www/web-application/
	cp web-application.py web-application.wsgi /var/www/web-application/
	chown -R www-data:www-data /var/www/web-application/
	chmod -R 740 /var/www/web-application/

printing:
	echo "Setup CUPS"

supervisor: envcheck
	printf '\n[program:aria2]\ncommand=/usr/bin/aria2c --enable-rpc --rpc-listen-all --dir=/home/user/downloads --save-session=/home/user/downloads/.conf/session_aria --force-save=true --rpc-save-upload-metadata=true --follow-torrent=true --follow-metalink=true --force-save=true --save-session-interval=60 --input-file=/home/user/downloads/.conf/session_aria --on-download-error=/home/user/downloads/.conf/aria_dwnld_fail_hook.sh' >> /etc/supervisor/supervisord.conf
	printf '\n[program:system-manager]\ncommand=/usr/bin/python3 /system-manager/system-manager.py\nenvironment = XMPP_HOST=%s , XMPP_DOMAIN_NAME=%s' "$(XMPP_HOST)" "$(HOSTNAME)" >> /etc/supervisor/supervisord.conf
	printf '\n[program:set-cam-perms]\ncommand=chmod 666 /dev/video0\nstartsecs=0\nstartretries=3' >> /etc/supervisor/supervisord.conf

xmpp: envcheck
	echo "Setting up prosody"
	sed -i -e '100, 103d' -e '170, 180d' -e 's/VirtualHost "example.com"/VirtualHost "'$(HOSTNAME)'.local"/' /etc/prosody/prosody.cfg.lua
	prosodyctl register $(XMPP_HOST) $(HOSTNAME).local abcd
	prosodyctl restart

envcheck:
	test -n "$(XMPP_HOST)"
	test -n "$(HOSTNAME)"
