#!/bin/bash
## Virtuelle Maschinen herunterfahren und löschen

# Switches stoppen und löschen
for SWITCH_ID in {01,02,11,12,13,14} ; do
  vmrun -T ws stop ~/vmware/sw${SWITCH_ID}/sw${SWITCH_ID}.vmx
  vmrun -T ws deleteVM ~/vmware/sw${SWITCH_ID}/sw${SWITCH_ID}.vmx
done
