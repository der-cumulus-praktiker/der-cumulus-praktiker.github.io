#!/bin/bash

# purpose: restore script for CentOS 7 host "server2" in lab#35


# setup network configuration
for IF in $(seq 1 2) ; do
  cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-eth${IF}
TYPE=Ethernet
DEVICE=eth${IF}
ONBOOT=yes
NM_CONTROLLED=no
BOOTPROTO=none
MASTER=bond0
SLAVE=yes
USERCTL=no
EOF
done

cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-bond0
DEVICE=bond0
IPADDR=10.1.1.32
NETMASK=255.255.255.0
NM_CONTROLLED=no
BOOTPROTO=static
ONBOOT=yes
USERCTL=no
BONDING_OPTS="mode=4 miimon=100"
EOF

systemctl restart network
