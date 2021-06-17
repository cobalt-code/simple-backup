#!/bin/bash
#
# /etc/cron.weekly/rooling-backup.sh - rooling backup of mysqldatabase and /var/www to local folders
#
# (c)2021 Hans-Helmar Althaus <althaus@m57.de>
#
# requires mysql credentials in /root/.my.cnf
#

BACKUPDIR="/backup"
BACKUPDATE=$(date +%Y%m%d)

mkdir -p ${BACKUPDIR}
SEQ=$(< ${BACKUPDIR}/.seq)
if [ "$(( SEQ + 1 ))" -eq 1 ]; then
  echo 0 > ${BACKUPDIR}/.seq
  SEQ=0
elif [ ${SEQ} -gt 9 ]; then
  SEQ=0
fi
echo $((SEQ+1)) > ${BACKUPDIR}/.seq

#echo "running with sequence: ${SEQ}"

SEQBKUPDIR="${BACKUPDIR}/rolling-${SEQ}"
rm -rf ${SEQBKUPDIR}
mkdir -p ${SEQBKUPDIR}
mysqldump --all-databases 2> ${SEQBKUPDIR}/${BACKUPDATE}.mysqldump.stderr | gzip > ${SEQBKUPDIR}/all-${BACKUPDATE}.mysql.gz
tar -cvz /var/www         2> ${SEQBKUPDIR}/${BACKUPDATE}.tar.stderr >              ${SEQBKUPDIR}/var-www-${BACKUPDATE}.tar.gz
