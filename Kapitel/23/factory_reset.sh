#!/bin/bash

# Läuft dieses Skript als root-User?
if [ "$USER" != "root" ] ; then
  echo "Bitte Skript als root starten"
  echo "sudo $0"
  exit 1
fi
cd /tmp/

net add hostname cumulus
net commit

# Alle zusätzlichen Benutzerkonten löschen
U=$(getent passwd |awk -F : '$3 >= 1000 && $3 < 65534 {print $1}')
for user in $U ; do
  if [ "${user}" != "cumulus" ]; then
    userdel -r ${user}
  fi
done

# HOME-Verzeichnis von 'root' und 'cumulus' aufräumen und Kennwort setzen
for user in root cumulus ; do
  homedir=$(eval echo ~$user)
  rm -rf $homedir/
  mkdir --mode=700 $homedir
  cp -r /etc/skel/. $homedir/
  chown -R $user.$user $homedir
  echo -e "CumulusLinux"'!'"\nCumulusLinux"'!' | (passwd $user)
done

rm -f /etc/network/interfaces
rm -rf /var/log/*
rm -f /etc/frr/*

# SSH-Schlüssel neu erstellen
rm -f /etc/ssh/*_key
dpkg-reconfigure openssh-server
