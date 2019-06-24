#!/bin/bash
## Virtuelle Maschine in VirtualBox aus Vorlage anlegen und einrichten

# Die Kommandos als "vbox"-User ausführen
if [ "$USER" != "vbox" ] ; then
  exit 1
fi

# Nummer und Name des Switches
SW_ID="${1:-01}"
SW_NAME=$(printf "sw%02d" ${SW_ID})

# VM erstellen und registrieren
VBoxManage import /data/vmware/images/cumulus-linux-3.7.4-vx-amd64-vbox.ova \
  --vsys 0 --ostype "Debian_64" --vmname ${SW_NAME} \
  --vsys 0 --unit 14 --disk "${HOME}/VirtualBox VMs/${SW_NAME}/disk.vmdk"
VBoxManage modifyvm ${SW_NAME} --description "Cumulus Linux VX lab"

# Netzwerkkarte 1 als Managementadapter einrichten
VBoxManage modifyvm ${SW_NAME} --nic1 bridged
VBoxManage modifyvm ${SW_NAME} --bridgeadapter1 eth1
VBoxManage modifyvm ${SW_NAME} --nictype1 virtio
VBoxManage modifyvm ${SW_NAME} --macaddress1 \
  $(printf "0c1224%02d00%02d" ${SW_ID} ${SW_ID})

# RDP-Konsole
VBoxManage modifyvm ${SW_NAME} --vrde on
VBoxManage modifyvm ${SW_NAME} --vrdeport 81${SW_ID}
VBoxManage modifyvm ${SW_NAME} --vrdeaddress "${HOSTNAME}"

# Serielle Konsole
VBoxManage modifyvm ${SW_NAME} --uart1 0x3F8 4
VBoxManage modifyvm ${SW_NAME} --uartmode1 server /tmp/${SW_NAME}.pipe

# VM starten
VBoxHeadless --startvm ${SW_NAME} &

# Mit RDP-Konsole verbinden
rdesktop ${HOSTNAME}:81${SW_ID} &
