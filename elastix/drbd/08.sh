#!/bin/bash

sh header.sh

chkconfig drbd on
chkconfig dhcpd off
chkconfig ntp off
chkconfig asterisk off
chkconfig mysqld off
chkconfig httpd off
chkconfig elastix-updaterd off
chkconfig elastix-portknock off
service dhcpd stop
service mysqld stop
service asterisk stop
service httpd stop
service elastix-portknock stop
service elastix-updaterd stop
service ntp stop

echo "Copiando ha.cf"
cp -a ha/ha.cf /etc/ha.d/ha.cf
chown root:root /etc/ha.d/ha.cf
chmod 644 /etc/ha.d/ha.cf

echo "Copiando authkeys"
cp -a ha/authkeys /etc/ha.d/authkeys
chown root:root /etc/ha.d/authkeys
chmod 600 /etc/ha.d/authkeys

echo "Copiando haresources"
cp -a ha/haresources /etc/ha.d/haresources
chown root:root /etc/ha.d/haresources
chmod 644 /etc/ha.d/haresources

echo "Arrancando heartbeat"
service heartbeat start

echo "Configurando el nivel de arranque de heartbeat"
chkconfig --add heartbeat
chkconfig heartbeat on

sh footer.sh 28 35 YES
