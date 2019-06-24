#!/bin/bash

# beende moeglichen Identifizierung-Prozess
killall ethtool

# lasse Switchports 1 bis 24 fuer eine Sekunde aufblinken
for nic in {1..24} ; do
  swp=swp${nic}
  echo "LED von $swp blinkt"
  ethtool --identify $swp 1
done
