#!/bin/bash

# purpose: install FreeRADIUS on lab server "labsrv"

# version
#  FreeRadius 3.0.13
#  CentOS Linux release 7.4.1708


# install
yum install -y freeradius freeradius-utils
systemctl enable radiusd

# configuration
cat <<EOF >> /etc/raddb/clients.conf
client cumulus_lab {
   ipaddr = 0.0.0.0/0
   secret = Cumulus22
}
EOF
echo "scooper    Cleartext-Password := 'Cumulus22'" >> /etc/raddb/users

# start
systemctl start radiusd

# logging
tail -n0 -f /var/log/radius/radius.log
