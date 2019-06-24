#!/bin/bash

# purpose: install TACACS+ on lab server "labsrv"

# ==== prerequisit: MySQL server
yum install $YUM_OPT mariadb mariadb-server php-mysql
systemctl enable mariadb
systemctl start mariadb
mysqladmin -u root password ''
mysqladmin --user=root --character-set=utf8 create tacacs

# ==== prerequisit: Apache web server
yum install $YUM_OPT httpd
systemctl restart httpd
systemctl enable httpd

# ==== prerequisit: compile environment
yum install $YUM_OPT gcc-c++ mariadb-devel openldap-devel
yum install $YUM_OPT open-vm-tools


# === TACACS+ daemon
mkdir /usr/src/tac_plus-4.6b3-4
cd /usr/src/tac_plus-4.6b3-4
wget https://downloads.sourceforge.net/project/tac-plus/tac_plus-4.6b3-4.tgz
tar xfz tac_plus-4.6b3-4.tgz
make
cp tac_plus /usr/sbin/
cp tac_plus.init /etc/init.d/tac_plus
chmod 755 /etc/init.d/tac_plus

mysql tacacs < tac_plus.sql
mysql tacacs < tac_plus_uppass_1024.sql
echo "GRANT ALL ON tacacs.* TO tacacs@localhost IDENTIFIED BY 'password';" | mysql mysql

mkdir /etc/tacacs/
cat <<EOF >/etc/tacacs/tac_plus.cfg
options = {
        do_changepass = 0;
        do_expire = 0;
        warning_period = 7;
        expire_period = 90;
        minpasswdlen = 6;
        maxpasswdretry = 3;
        passwdcomplex = 0;
        maxsess = 0;
}
db = {
        default = mysql://tacacs:password@localhost/tacacs;
}
EOF
systemctl enable tac_plus
systemctl start tac_plus


# === TACACS+ Web-UI
yum install -y php
mkdir /var/www/html/tacacs/
cd /var/www/html/tacacs/
wget https://downloads.sourceforge.net/project/tac-plus/webui_v1.6b6-1.tar.gz
tar xfz webui_v1.6b6-1.tar.gz
rm -f webui_v1.6b6-1.tar.gz *.sql
sed -i -e 's/dbpass.*/dbpass = "password";/' config.php
sed -i -e 's/^$pass_size = 8/$pass_size = 4/' config.php
systemctl restart httpd
// http://10.5.1.7/tacacs/    U:admin  P:system
