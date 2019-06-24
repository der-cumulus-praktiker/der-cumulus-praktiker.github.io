#!/bin/bash

cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-eth1
TYPE=Ethernet
BOOTPROTO=static
NAME=eth1
ONBOOT=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPADDR=10.4.1.33
NETWORK=10.4.1.0
NETMASK=255.255.255.0
BROADCAST=10.4.1.255
IPV6ADDR=fd00:4::33/64
IPV6_AUTOCONF=no
IPV6_DEFROUTE=no
IPV6_FAILURE_FATAL=no
IPV6_PEERDNS=yes
IPV6_PEERROUTES=yes
EOF
systemctl restart network

# Apache web server
yum install -y httpd mod_ssl
cat <<EOF > /etc/httpd/conf.d/dummy.conf
# listen on additional tcp ports to fake some traffic for 
# sFlow/NetFlow reporting
Listen 81
Listen 82
Listen 83
Listen 84
Listen 85
EOF
systemctl enable httpd
systemctl start httpd

# start dummy services
yum install -y xinetd
sed -i -e 's/disable = .*/disable = no/' /etc/xinetd.d/*
systemctl enable xinetd
systemctl start xinetd
