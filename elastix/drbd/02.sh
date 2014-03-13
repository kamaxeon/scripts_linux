#!/bin/bash

sh header.sh

mke2fs -j /dev/sda3
dd if=/dev/zero bs=1M count=500 of=/dev/sda3; sync
yum install heartbeat drbd83 kmod-drbd83


# Copiar drbd.conf a /etc/
cp -a drbd/drbd.conf /etc/

# Iniciamos los dos nodos
drbdadm create-md r0

# Iniciamos el servicio
service drbd start

echo "Comprobando el estado del drbd"

cat /proc/drbd

sh footer.sh 7 15 YES
