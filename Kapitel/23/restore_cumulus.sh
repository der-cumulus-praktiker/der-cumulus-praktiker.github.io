#!/bin/bash

# Welche Backup-Datei soll wiederhergestellt werden?
if [ -f "$1" ] ; then
  backup_file=$1
else
  echo "Bitte gueltige Backupdatei angeben"
  exit 2
fi

# Läuft dieses Skript als root-User?
if [ "$USER" != "root" ] ; then
  echo "Bitte Skript als root starten"
  echo "sudo $0 $1"
  exit 1
fi

tar xfz ${backup_file} -C /
source /tmp/startup-config
net commit
