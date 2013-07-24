#!/bin/bash

# Autor: Israel Santana <isra@miscorreos.org>

# Versión: 0.1

# Licencia: GPL v2

# El motivo de este script es detener una serie de servicios que no 
# usados habitualmente en Elastix. Está basado en Elastix 2.4 con lo que
# puede cambiar en versiones futuras

# Variables

# Ojo si usas tarjetas Sangoma, no debes para wanrouter, con lo que deberías quitarlo
# de la siguiente línea
SERVICIOS='kudzu netfs nfslock portmap restorecond rpcgssd rpcidmapd wanrouter'

for SERVICIO in ${SERVICIOS}
do
    echo "Parando el servicio " ${SERVICIO}

    service ${SERVICIO} stop

    echo "Deshabilitando el servicio " ${SERVICIO}

    chkconfig --level 345 ${SERVICIO} off
done

echo "Parando el arranque automático de asterisk, lo hace amportal"

chkconfig --level 345 asterisk off
