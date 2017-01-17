#!/bin/bash
wget -c $1
tar -xf update
cp -r web_update/* /var/www/web-application/
cp system-manager.py /system-manager/system-manager.py
