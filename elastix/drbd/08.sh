#!/bin/bash

sh header.sh

chkconfig drbd on
chkconfig dhcpd off
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

echo "Copiando ha.cf"
cp -a ha.cf /etc/ha.d/ha.cf

echo "Copiando authkeys"
cp -a authkeys /etc/ha.d/authkeys

echo "Copiando haresources"
cp -a haresources /etc/ha.d/haresources

echo "Arrancando heartbeat"
service heartbeat start

echo "Configurando el nivel de arranque de heartbeat"
chkconfig --add heartbeat
chkconfig heartbeat on

echo "Copiando fop_start del apendice B"
cp -a fop_start /etc/init.d/

sh footer.sh 28 35 YES