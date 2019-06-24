#!/bin/bash

# Zweck: Labor-Server für "Zero Touch Provisioning" ausstatten


# DHCP-Dienst
yum install -y dhcp
wget -O /etc/dhcp/dhcpd.conf https://raw.githubusercontent.com/der-cumulus-praktiker/der-cumulus-praktiker.github.io/master/Kapitel/20/dhcpd.conf
systemctl enable dhcpd
systemctl start dhcpd


# Apache Webserver
yum install -y httpd
mkdir /var/www/html/ztp/
mkdir /var/www/html/license/
wget -O /var/www/html/ztp/setup.sh https://raw.githubusercontent.com/der-cumulus-praktiker/der-cumulus-praktiker.github.io/master/Kapitel/20/setup.sh
systemctl enable httpd
systemctl start httpd


# Cumulus VX Binärdatei anbieten
cd /var/www/html/
wget http://cumulusfiles.s3.amazonaws.com/cumulus-linux-3.3.2-vx-amd64.bin
wget http://cumulusfiles.s3.amazonaws.com/cumulus-linux-3.4.3-vx-amd64.bin
wget http://cumulusfiles.s3.amazonaws.com/cumulus-linux-3.5.3-vx-amd64.bin
wget http://cumulusfiles.s3.amazonaws.com/CumulusLinux-3.6.0/cumulus-linux-3.6.0-vx-amd64.bin
wget http://cumulusfiles.s3.amazonaws.com/CumulusLinux-3.6.1/cumulus-linux-3.6.1-vx-amd64.bin
ln cumulus-linux-3.5.3-vx-amd64.bin onie-installer
ln cumulus-linux-3.5.3-vx-amd64.bin onie-installer-x86_64
ln cumulus-linux-3.5.3-vx-amd64.bin onie-updater
ln cumulus-linux-3.5.3-vx-amd64.bin onie-updater-x86_64

# Der Download von Cumulus Linux Binärdateien benötigt eine Anmeldung.
# Die Binärdateien für ARM mit Broadcom-Chipsatz händisch laden und in
# /var/www/html/ ablegen.
wget https://cumulusnetworks.com/downloads/bin/cumuluslinuxpackage/85/cumulus-linux-3.3.2-bcm-armel.bin
wget https://cumulusnetworks.com/downloads/bin/cumuluslinuxpackage/97/cumulus-linux-3.4.3-bcm-armel.bin
wget https://cumulusnetworks.com/downloads/bin/cumuluslinuxpackage/109/cumulus-linux-3.5.3-bcm-armel.bin
wget https://cumulusnetworks.com/downloads/bin/cumuluslinuxpackage/112/cumulus-linux-3.6.0-bcm-armel.bin
wget https://cumulusnetworks.com/downloads/bin/cumuluslinuxpackage/115/cumulus-linux-3.6.1-bcm-armel.bin
