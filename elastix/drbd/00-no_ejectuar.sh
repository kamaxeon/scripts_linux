#!/bin/bash

NODO=$1

echo $NODO

exit 0
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
cp -a net/hosts /etc/hosts
chown root:root /etc/hosts
chmod 644 /etc/hosts

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

echo "- Configurar el cortafuegos"
cp -a iptables/iptables /etc/sysconfig/iptables
chown root:root /etc/sysconfig/iptables
chmod 644 /etc/sysconfig/iptables
service iptables restart

echo "- Configurar el fichero de ntp.conf"
cp -a net/ntp.conf /etc/ntp.conf
chown root:root /etc/ntp.conf
chmod 644 /etc/ntp.conf


echo "Configuracion ssh entre nodos"
ssh-keygen -t rsa
ssh-copy-id -i ~/.ssh/id_rsa.pub 192.168.229.$NODO


echo "Configuracion rsh entre nodos"
#to do

echo "- Instalar el modulo fail2ban para elastix"
yum install -y elastix-anti_hacker.noarch
echo "- Instalar el endpoints configuration version 2"
yum install -y elastix-endpointconfig2.noarch
