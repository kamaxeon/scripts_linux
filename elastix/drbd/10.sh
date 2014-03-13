#!/bin/bash

# Copiar el script de sincronizacion
cp -a sync/sync_slave /usr/local/sbin/
chown root:root /usr/local/sbin/sync_slave
chmod 744 /usr/local/sbin/sync_slave

# Copiar el trabajo programado
cp -a sync/sync_slave.cron /etc/cron.d/sync_slave.cron
chown root:root /etc/cron.d/sync_slave.cron
chmod 644 /etc/cron.d/sync_slave.cron

sh footer.sh 100 100 YES
