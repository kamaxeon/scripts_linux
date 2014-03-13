#!/bin/bash

sh header.sh

drbdadm -- --overwrite-data-of-peer primary r0

echo "Debes ejecutar watch -n 1 cat /proc/drbd"
echo "Espera hasta que termine para seguir por 04-principal.sh"

sh footer.sh 16 17
