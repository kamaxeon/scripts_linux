#!/bin/bash

NODO=$1

echo $NODO


echo "Esto hay que hacerlo en los dos nodos antes de pasar al siguiente"
echo "- Configurar las interfaces"

cp -a net/ifcfg-eth0-$NODO /etc/sysconfig/network-scripts/ifcfg-eth0
cp -a net/ifcfg-eth1-$NODO /etc/sysconfig/network-scripts/ifcfg-eth1
cp -a net/ifcfg-eth2-$NODO /etc/sysconfig/network-scripts/ifcfg-eth2
cp -a net/ifcfg-eth3-$NODO /etc/sysconfig/network-scripts/ifcfg-eth3
cp -a net/ifcfg-eth4-$NODO /etc/sysconfig/network-scripts/ifcfg-eth4
cp -a net/ifcfg-eth5-$NODO /etc/sysconfig/network-scripts/ifcfg-eth5
cp -a net/ifcfg-bond0-$NODO /etc/sysconfig/network-scripts/ifcfg-bond0

chown root:root /etc/sysconfig/network-scripts/ifcfg-eth0
chown root:root /etc/sysconfig/network-scripts/ifcfg-eth1
chown root:root /etc/sysconfig/network-scripts/ifcfg-eth2
chown root:root /etc/sysconfig/network-scripts/ifcfg-eth3
chown root:root /etc/sysconfig/network-scripts/ifcfg-eth4
chown root:root /etc/sysconfig/network-scripts/ifcfg-eth5
chown root:root /etc/sysconfig/network-scripts/ifcfg-bond0

chmod 644 /etc/sysconfig/network-scripts/ifcfg-eth0
chmod 644 /etc/sysconfig/network-scripts/ifcfg-eth1
chmod 644 /etc/sysconfig/network-scripts/ifcfg-eth2
chmod 644 /etc/sysconfig/network-scripts/ifcfg-eth3
chmod 644 /etc/sysconfig/network-scripts/ifcfg-eth4
chmod 644 /etc/sysconfig/network-scripts/ifcfg-eth5
chmod 644 /etc/sysconfig/network-scripts/ifcfg-bond0


echo "- Configurar el resolv.conf"
cp -a net/resolv.conf /etc/resolv.conf
chown root:root /etc/resolv.conf
cmod 644 /etc/resolv.conf


echo "- Configurar los hosts"
cat net/hosts >> /etc/hosts


echo "- Configurar fichero network"
cp -a net/network-$NODO /etc/sysconfig/network
chown root:root /etc/sysconfig/network
chmod 644 /etc/sysconfig/network

echo "- Reiniciar las interfaces"
service network restart

echo "- Configurar el dhcpd.conf"
cp -a net/dchpd.conf-$NODO /etc/dchpd.conf
chown root:root /etc/dhcpd.conf
chmod 644 /etc/dhcpd.conf

cp -a net/dhcpd /etc/sysconfig/dhcpd
chown root:root /etc/sysconfig/dhcpd
chmod 644 /etc/sysconfig/dhcpd

echo "- Personalizando la plantilla de dhcpconfig"
cp -a net/dhcpconfig /usr/share/elastix/privileged/dhcpconfig
chown root:root /usr/share/elastix/privileged/dhcpconfig
chmod 755 /usr/share/elastix/privileged/dhcpconfig

echo "- Configurar el cortafuegos"
cp -a iptables/iptables /etc/sysconfig/iptables
chown root:root /etc/sysconfig/iptables
chmod 644 /etc/sysconfig/iptables
service iptables restart

echo "- Cambiando reglas itpables web"
cp -a /root/elastix/drbd/iptables/iptables.db /var/www/db/iptables.db
chown asterisk:asterisk /var/www/db/iptables.db
chmod 644 /var/www/db/iptables.db

echo "- Configurar el fichero de ntp.conf"
cp -a net/ntp.conf /etc/ntp.conf
chown root:root /etc/ntp.conf
chmod 644 /etc/ntp.conf



echo "- Instalar el modulo fail2ban para elastix"
yum install -y elastix-anti_hacker.noarch

echo "- Reglas web fail2ban"
cp -a fail2ban/settings.conf /var/www/html/modules/anti_hacker/configs/settings.conf
chown root:root /var/www/html/modules/anti_hacker/configs/settings.conf
chmod 644 /var/www/html/modules/anti_hacker/configs/settings.conf

echo "- Configurar fail2ban"
cp -a fail2ban/fail2ban.php /usr/share/elastix/privileged/fail2ban
chown root:root /usr/share/elastix/privileged/fail2ban
cmhod 755 /usr/share/elastix/privileged/fail2ban



echo "- Instalar el endpoints configuration version 2"
yum install -y elastix-endpointconfig2.noarch



service fail2ban stop

rm -fr /etc/fail2ban/
cp -a fail2ban/fail2ban/ /etc/
chown -R root:root /etc/fail2ban/
chmod 644  /etc/fail2ban/*conf
chmod 755 /etc/fail2ban/action.d
chmod 644 /etc/fail2ban/action.d/*conf
chmod 755 /etc/fail2ban/filter.d
chmod 644 /etc/fail2ban/filter.d/*conf

echo "- Configurar mango analytics"
yum install -y mangoanalytics.noarch
cp -a mango/rc.local /etc/rc.d/rc.local
chown root:root /etc/rc.d/rc.local
chmod 755 /etc/rc.d/rc.local

echo "Copiando el script de arranque de mango-analytics"
cp -a mango/mango-analytics /etc/init.d/
chown root:root /etc/init.d/mango-analytics
chmod +x /etc/init.d/mango-analytics

echo "Copiando fop_start del apendice B"
cp -a fop/fop_start /etc/init.d/
chown root:root /etc/init.d/fop_start
chmod 755 /etc/init.d/fop_start

echo "Configuracion ssh entre nodos"
ssh-keygen -t rsa

echo "Ejecuta ssh-copy-id -i ~/.ssh/id_rsa.pub 192.168.229.X"