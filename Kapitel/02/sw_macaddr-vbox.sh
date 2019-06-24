#!/bin/bash
## MAC-Adresse aller Netzadapter der virtuellen Maschinen definieren

# Die Kommandos als "vbox"-User ausführen
if [ "$USER" != "vbox" ] ; then
  exit 1
fi

for SWITCH_ID in {01,02,11,12,13,14} ; do
  for PORT_ID in {02..08} ; do
    VBoxManage modifyvm sw${SWITCH_ID} --macaddress${PORT_ID} 0c1224${SWITCH_ID}ff${PORT_ID}
  done
done
