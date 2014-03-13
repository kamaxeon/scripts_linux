#!/bin/bash

echo "Script para montar dos maquinas Elastix"
echo "en cluster usando drbd"
echo "Basados en http://www.theserverexpert.com/elastix_2.4_ha_cluster-updated.pdf"

if [ "$(id -u)" != "0" ]; then
   echo "Este script debe ser ejecutado como root" 1>&2
   exit 1
fi