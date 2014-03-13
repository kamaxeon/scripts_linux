#!/bin/bash

echo "Esto hay que hacerlo en los dos nodos antes de pasar al siguiente"
echo "- Configurar las interfaces"

echo "- Reiniciar las interfaces"
service network restart

echo "- Configurar el dhcpd.conf"
cp -a dchpd.conf /etc/
#cp -a /etc/fdsfsadf 

echo "- Instalar el mango statistic"
#yum install -y mangoanalytics.noarch
echo "- Instalar el endpoints configuration version 2"
yum install -y elastix-endpointconfig2.noarch
