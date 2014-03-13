#!/bin/bash

echo "Se ha finaizado el script, abarca los pasos desde el $1 hasta $2"
echo "Ambos inclusive"
if [ "$3" == "YES" ]; then
	echo "Este script se debe ejecutar en las dos maquinas"
	echo "No pases al siguiente hasta entonces"
fi
