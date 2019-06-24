#!/bin/bash
## Virtuelle Maschinen herunterfahren und löschen

# Die Kommandos als "vbox"-User ausführen
if [ "$USER" != "vbox" ] ; then
  exit 1
fi

# Switches stoppen
for SWITCH_ID in {01,02,11,12,13,14} ; do
  VBoxManage controlvm sw${SWITCH_ID} poweroff
  VBoxManage unregistervm sw${SWITCH_ID} --delete
done
