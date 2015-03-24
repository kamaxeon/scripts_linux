#!/bin/bash

# Author: Israel Santana <isra@miscorreos.org>

# Version 0.1

# Backup a UniFi Controller using the API
# For more info see UniFi FAQ (http://wiki.ubnt.com/UniFi_FAQ#UniFi_Controller_API)

# This script needs internet access to download the UniFi API and wget


# Your settings (Change it !!!!!!)
# Unifi SH Api Setting
username=admin	
password=admin
baseurl=https://localhost:8443
site=default


WGET_BIN=/usr/bin/wget

UNIFI_VERSION=3.2.10
UNIFI_HOSTNAME=$(hostname) # if running this script on localhost,  
UNIFI_SH_API_DIR=/usr/local/bin
UNIFI_SH_API_NAME=unifi_sh_api
UNIFI_SH_API_PATH=${UNIFI_SH_API_DIR}/${UNIFI_SH_API_NAME}
UNIFI_SH_API_DOWNLOAD_URL=http://www.ubnt.com/downloads/unifi


KEEP_BACKUP=10 # Number of stored copies
BACKUP_DIR=/var/backups/unifi_controller
# End of your settings

# Don't change 
DATE=`date +%Y%m%d`
BACKUP_FILENAME=${BACKUP_DIR}/${DATE}-${UNIFI_HOSTNAME}.unf

# End of Settings

# Preparing to backup
if [ ! -f ${UNIFI_SH_API_PATH} ]; then
  ${WGET_BIN} -O ${UNIFI_SH_API_PATH} ${UNIFI_SH_API_DOWNLOAD_URL}/${UNIFI_VERSION}/${UNIFI_SH_API_NAME} 
fi

if [ ! -d ${BACKUP_DIR} ] ; then
 mkdir -p ${BACKUP_DIR}
fi

# Doing a backup
source ${UNIFI_SH_API_PATH}
unifi_login
unifi_backup ${BACKUP_FILENAME}
unifi_logout

# Cleaning old files

NUMBER_OF_COPIES=$(ls -1 ${BACKUP_DIR}/*-${UNIFI_HOSTNAME}.unf | wc -l)

if [ ${NUMBER_OF_COPIES} -gt ${KEEP_BACKUP} ]; then
  DELETE=$[${NUMBER_OF_COPIES} - ${KEEP_BACKUP}]
  ls -1 ${BACKUP_DIR}/*-${UNIFI_HOSTNAME}.unf | head -n $DELETE | xargs rm
fi
