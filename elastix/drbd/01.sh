#!/bin/bash

sh header.sh

# Actualizando la maquina
yum -y update

# Creando la particion
echo "
n
p
3

+100000M
t
3
83
w
" | fdisk /dev/sda

sh footer.sh 5 6 YES
echo "Se ha a reiniciar este nodo"
read -p "Pulse cualquier tecla para reiniciarlo"
reboot
