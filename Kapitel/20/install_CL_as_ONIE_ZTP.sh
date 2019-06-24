#!/bin/bash

# Zweck: Webserver für ONIE und ZTP unter Cumulus VX installieren
# getestet mit Cumulus VX version 3.6.1


# vorhandenen Nginx Webserver nutzen
cd /etc/nginx/sites-enabled/
ln -s /etc/nginx/sites-available/default
mkdir /var/www/html/ztp/
mkdir /var/www/html/license/
wget -O /var/www/html/ztp/setup.sh https://raw.githubusercontent.com/der-cumulus-praktiker/der-cumulus-praktiker.github.io/master/Kapitel/20/setup.sh

systemctl restart nginx


# Cumulus VX Binärdatei via Web bereit stellen
cd /var/www/html/
wget http://cumulusfiles.s3.amazonaws.com/cumulus-linux-3.5.3-vx-amd64.bin
wget http://cumulusfiles.s3.amazonaws.com/CumulusLinux-3.6.1/cumulus-linux-3.6.1-vx-amd64.bin
ln -s cumulus-linux-3.5.3-vx-amd64.bin onie-installer
ln -s cumulus-linux-3.5.3-vx-amd64.bin onie-installer-x86_64
