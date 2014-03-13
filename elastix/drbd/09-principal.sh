#!/bin/bash

sh header.sh

echo "Ejecuantdo drbdadm, debe estar Primary/Secondary"
drbdadm role r0

echo "Ejecutando df -h"
df -h

sh footer.sh 37 38 

echo "Ejecuata ahora el paso 39"
