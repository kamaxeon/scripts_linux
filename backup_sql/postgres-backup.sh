#!/bin/sh
# ---------------------------------------
# Backup de las bases de datos PostgreSQL
# Version: 1.0.b               2013-01-31
# ---------------------------------------

# Uso
# PostgreSQL backup, every nigth at 01:00 a.m.
#0 1 * * * postgres /usr/local/bin/postgres-backup.sh 9.3 5432  >/dev/null 2>&1

set -x

BACKUP_FOLDER="/var/backups/postgresql"
PG_USER="postgres"

uso() {
  echo "$0 <version>"
  echo "Donde: "
  echo "  <version> es el número de versión de la instancia de PostgreSQL"
}

if [ $# -eq 0 ]
then
  uso
  exit 1
fi

# Obtener el número de version.
if [ "x$1" = "x" ]
then
  echo "ERROR: Se debe indicar el número de version de la instancia de PostgreSQL"
  uso
  exit 1
else
  version=$1
fi
BACKUP_FOLDER="$BACKUP_FOLDER/$version"
if [ ! -d $BACKUP_FOLDER ]
then
  mkdir -p $BACKUP_FOLDER
fi

# Obtener la fecha
fecha=`date +%Y%m%d`

# Obtener la lista de bases de datos
for db in `psql --command="SELECT datname FROM pg_database" --tuples-only`
do
  filename="$BACKUP_FOLDER/$db-$fecha.dump"
  echo -n "Copia de seguridad de la base de datos $db"
  if [ ! -f $filename ]
  then
    pg_dump ${db} > $filename 2>/dev/null
    if [ $? -eq 0 ]
    then
      echo " . echo"
    else
      echo "ERROR: Al generar la copia de seguridad de $filename se elimina el archivo"
      rm -f $filename
    fi
  else
    echo " . ya existe"
  fi
done

# Eliminar la copia de hace N días
rmfecha=`date --date='-10 day' +%Y%m%d`
num=`ls $BACKUP_FOLDER/*-$rmfecha.dump 2>/dev/null |wc -l`
if [ $? -eq 0 ]
then
  if [ $num -gt 0 ]
  then
    echo -n "Se eliminan las $num copias antiguas $BACKUP_FOLDER/*-$rmfecha.dump"
    rm -f $BACKUP_FOLDER/*-$rmfecha.dump
    if [ $? -eq 0 ]
    then
      echo " . hecho"
    else
      echo " . error"
      echo "ERROR: Se han encontrado errores al eliminar las copias antiguas"
    fi
  fi
fi
