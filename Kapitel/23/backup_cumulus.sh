#!/bin/bash

# Läuft dieses Skript als root-User?
if [ "$USER" != "root" ] ; then
  echo "Bitte Skript als root starten"
  echo "sudo $0"
  exit 1
fi

# Wie heisst die Backup-Datei?
backup_file=${HOSTNAME}-$(date +%Y-%m-%dT%H-%M-%S%Z).tar

# Konfiguration per NCLU-Befehl erstellen
net show configuration commands > /tmp/startup-config

tar --create --file=${backup_file} \
  /tmp/startup-config \
  /etc/network/interfaces /etc/network/interfaces.d/* \
  /etc/resolv.conf /etc/frr/* /etc/hostname \
  /etc/cumulus/acl/* /etc/cumulus/ports.conf \
  /etc/cumulus/switchd.conf  2>/dev/null

# Zusätzliche Dateien sichern
tar --append --file=${backup_file} \
  /etc/motd /etc/passwd /etc/shadow /etc/group /etc/lldpd.conf \
  /etc/lldpd.d/* /etc/nsswitch.conf /etc/ssh/* \
  /etc/sudoers /etc/sudoers.d/*  2>/dev/null

# Backup-Datei komprimieren
gzip ${backup_file}
rm -f /tmp/startup-config

# Feedback für den Admin: Name der Backupdatei
echo ${backup_file}
exit 0
