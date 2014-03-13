#!/bin/bash

sh header.sh

# Formateando y creando la replica
mkfs.ext3 /dev/drbd0
mkdir /replica
mount /dev/drbd0 /replica

echo "Estado drdb"
drbdadm role r0

sh footer.sh 15 16
