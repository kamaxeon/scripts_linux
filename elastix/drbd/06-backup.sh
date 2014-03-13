#!/bin/bash

sh header.sh

mkdir /replica ; drbdadm primary r0 ; mount /dev/drbd0 /replica
rm -rf /etc/asterisk
rm -rf /var/lib/asterisk
rm -rf /usr/lib/asterisk/
rm -rf /var/spool/asterisk
rm -rf /var/lib/mysql/
rm -rf /var/log/asterisk/
rm -rf /var/www
rm -rf /tftpboot

# Incluir fail2ban

# Incluir dhcpd.conf y options

# Mirar incluir var lib dhcp


ln -s /replica/etc/asterisk/ /etc/asterisk
ln -s /replica/var/lib/asterisk/ /var/lib/asterisk
ln -s /replica/usr/lib/asterisk/ /usr/lib/asterisk
ln -s /replica/var/spool/asterisk/ /var/spool/asterisk
ln -s /replica/var/lib/mysql/ /var/lib/mysql
ln -s /replica/var/log/asterisk/ /var/log/asterisk
ln -s /replica/var/www /var/www
ln -s /replica/tftpboot /tftpboot


service mysqld restart
service mysqld stop
service asterisk stop
service httpd stop
service elastix-updaterd stop
service elastix-portknock stop

umount /replica/ ; drbdadm secondary r0

sh footer.sh 22B 27A
