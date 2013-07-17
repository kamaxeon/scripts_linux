#!/bin/bash

# Autor: Israel Santana <isra@miscorreos.org>

# Versión: 0.1

# Licencia: GPL v2

# El motivo de este script es descargar las voces de español
# neutro desde la web de voip novatos y ponerla en el directorio
# correspondiente .Están basados en asterisk 1.4 y hay que cambiar la 
# estructura de los directorios

# Está adaptado a Elastix

# Variables

WEB='http://www.voipnovatos.es/voces/'
CORE='voipnovatos-core-sounds-es-'
EXTRAS='voipnovatos-extra-sounds-es-'
FINAL='-1.4.tar.gz'
CODECS='alaw g729 ulaw gsm'

EPOCH=`date +%s`

DIR_TMP='/tmp/'${EPOCH}

DIR_SOUNDS_ES='dictate digits followme letters phonetic silence'

DIR_FINAL='/var/lib/asterisk/sounds/es'

USER='asterisk'
GROUP='asterisk'



 
read -p "Pulse cualquier tecla para descargar los ficheros de audio "

# Bajamos todos los ficheros a un directorio temporal y los descomprimimos
mkdir -p ${DIR_TMP}

cd ${DIR_TMP}

for codec in ${CODECS}
do 
	# Ficheros core
	wget ${WEB}${CORE}${codec}${FINAL}

	echo 'Descomprimiendo ' ${CORE}${codec}${FINAL} '\n\n\n'
	tar -zvxf ${CORE}${codec}${FINAL}

	# Ficheros extras
	wget ${WEB}${EXTRAS}${codec}${FINAL}

	echo 'Descomprimiendo ' ${EXTRAS}${codec}${FINAL} '\n\n\n'
	tar -zvxf ${EXTRAS}${codec}${FINAL}
done



read -p "Pulse cualquier tecla para reemplazar los ficheros de audio "
# Ahora ponemos los ficheros en la estructura actual de asterisk
for dir in ${DIR_SOUNDS_ES}
do
	# Creamos el directorio
	mkdir es/${dir}

	# Ponemos los ficheros en su sitio
	cp -a ${dir}/es/*.* es/${dir}
done


# Movemos lo que hay en el directorio es
mv ${DIR_FINAL} %{DIR_FINAL}.old

mkdir -p ${DIR_FINAL}

cp -a es/* ${DIR_FINAL}


# Le ponemos los permisos necesarios

chown -R ${USER}:${GROUP} ${DIR_FINAL}

cd /tmp

rm -fr ${DIR_TMP}


echo 'Se han cambiado los ficheros de audio'