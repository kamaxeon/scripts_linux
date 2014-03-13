#!/bin/bash

sh header.sh

# Creando la estructura de replica
cd /replica
amportal chown
tar -zcvf etc-asterisk.tgz /etc/asterisk
tar -zxvf etc-asterisk.tgz
tar -zcvf var-lib-asterisk.tgz /var/lib/asterisk
tar -zxvf var-lib-asterisk.tgz
tar -zcvf usr-lib-asterisk.tgz /usr/lib/asterisk/
tar -zcvf var-www.tgz /var/www/
tar -zxvf usr-lib-asterisk.tgz
tar -zcvf var-spool-asterisk.tgz /var/spool/asterisk/
tar -zxvf var-spool-asterisk.tgz
tar -zcvf var-lib-mysql.tgz /var/lib/mysql/
tar -zxvf var-lib-mysql.tgz
tar -zcvf var-log-asterisk.tgz /var/log/asterisk/
tar -zxvf var-log-asterisk.tgz
tar -zxvf var-www.tgz
tar -zcvf tftpboot.tgz /tftpboot/
tar -zxvf tftpboot.tgz

# Incluir fail2ban

# Incluir dhcpd.conf y options

# Mirar incluir var lib dhcp

rm -rf /etc/asterisk
rm -rf /var/lib/asterisk
rm -rf /usr/lib/asterisk/
rm -rf /var/spool/asterisk
rm -rf /var/www
rm -rf /var/lib/mysql/
rm -rf /var/log/asterisk/
rm -rf /tftpboot

ln -s /replica/etc/asterisk/ /etc/asterisk
ln -s /replica/var/lib/asterisk/ /var/lib/asterisk
ln -s /replica/usr/lib/asterisk/ /usr/lib/asterisk
ln -s /replica/var/spool/asterisk/ /var/spool/asterisk
ln -s /replica/var/lib/mysql/ /var/lib/mysql
ln -s /replica/var/log/asterisk/ /var/log/asterisk
ln -s /replica/var/www /var/www
ln -s /replica/tftpboot /tftpboot

cd /

# Para los servicios
service mysqld restart
service mysqld stop
service asterisk stop
service httpd stop
service elastix-updaterd stop
service elastix-portknock stop

umount /replica ; drbdadm secondary r0

sh footer.sh 20 22A
