#!/bin/bash
# Virtuelle Maschinen in VMware Workstation (Linux) aus Vorlage anlegen und einrichten
# Dieses Skript kann mehrfach ausgeführt werden. Die VMs werden nur einmal angelegt.

# VMX-Datei einer virtuellen Maschine verändern
vmxmod() {
  if [ -f $1 ] ; then
    VMX=$1
  else
    VMX=~/vmware/$1/$1.vmx
  fi
  ATTR=$2
  VALUE=$3

  egrep "^$ATTR\s*=" $VMX >/dev/null
  if [[ $? == 1 ]] ; then
    # Diesen Wert gibt es noch nicht => anlegen
    echo "$ATTR = \"$VALUE\"" >> $VMX
  else
    # Diesen Wert gibt es bereits => anpassen
    sed -i -e "s!^$ATTR\s*=.*!$ATTR = \"$VALUE\"!" $VMX
  fi
}


# LAN-Segmente anlegen
LINKS="sw01-sw11 sw01-sw12 sw01-sw13 sw01-sw14 sw01-sw02-link5 sw01-sw02-link6 sw02-sw11 sw02-sw12 sw02-sw13 sw02-sw14 sw11-sw12-link3 sw11-sw12-link4 sw11-sw12-link3 sw11-sw12-link4 sw13-sw14-link3 sw13-sw14-link4 sw13-sw14-link3 sw13-sw14-link4 sw11-server1-vmnic1 sw11-server2-eth1 sw12-server1-vmnic2 sw12-server2-eth2 sw12-server2-eth3 sw13-server3-eth1 sw13-server4-nic1 sw14-server3-eth2 sw14-server4-nic2"
PVN_COUNT=0
declare -A LAN_segment
for LINK in $LINKS ; do
  UUID=$(uuidgen | perl -ne '{ s/-//g; s/(.{2})/\1 /g; substr($_,23,1,"-"); print; }')
  vmxmod ~/.vmware/preferences  pref.namedPVNs${PVN_COUNT}.name $LINK
  vmxmod ~/.vmware/preferences  pref.namedPVNs${PVN_COUNT}.pvnID "$UUID"
  LAN_segment[$LINK]=$UUID
  ((PVN_COUNT++))
done
vmxmod ~/.vmware/preferences  pref.namedPVNs.count "${PVN_COUNT}"

# Switches anlegen
for SWITCH_ID in {01,02,11,12,13,14} ; do
  SW_NAME=$(printf "sw%02d" ${SWITCH_ID})

  # VM erstellen
  if [ ! -f ~/vmware/${SW_NAME}/${SW_NAME}.vmx ] ; then
    /usr/lib/vmware-ovftool/ovftool --name=$SW_NAME \
      /data/vmware/images/cumulus-linux-3.7.4-vx-amd64-vmware.ova ~/vmware/
  fi

  # Virtuelle Hardwareversion auf neusten Stand bringen
  vmrun -T ws upgradevm ~/vmware/${SW_NAME}/${SW_NAME}.vmx

  # Virtuelle Hardwarekomponenten anpassen
  vmxmod ${SW_NAME} floppy0.present FALSE
  vmxmod ${SW_NAME} numvcpus 1
  vmxmod ${SW_NAME} annotation "Cumulus VX lab"
  vmxmod ${SW_NAME} guestos "debian8-64"
  vmxmod ${SW_NAME} ide1:0.present FALSE

  # Netzwerkkarten einrichten (4 NICs sind in der Vorlage bereits vorhanden)
  vmxmod ${SW_NAME} ethernet0.vnet /dev/vmnet1
  vmxmod ${SW_NAME} ethernet0.connectionType custom
  vmxmod ${SW_NAME} ethernet0.addressType static
  vmxmod ${SW_NAME} ethernet0.address \
    $(printf "0c:12:24:%02d:00:%02d" ${SWITCH_ID} ${SWITCH_ID})

  for PORT_ID in {1..7} ; do
    vmxmod ${SW_NAME} ethernet${PORT_ID}.present TRUE
    vmxmod ${SW_NAME} ethernet${PORT_ID}.virtualDev e1000
    vmxmod ${SW_NAME} ethernet${PORT_ID}.connectionType pvn
    vmxmod ${SW_NAME} ethernet${PORT_ID}.startConnected TRUE
    vmxmod ${SW_NAME} ethernet${PORT_ID}.addressType static
    vmxmod ${SW_NAME} ethernet${PORT_ID}.address \
      $(printf "0c:12:24:%02d:ff:%02d" ${SWITCH_ID} ${PORT_ID})
  done
done

# Spine-Switches sw01 und sw02
vmxmod sw01 ethernet1.pvnID "${LAN_segment['sw01-sw11']}"
vmxmod sw01 ethernet2.pvnID "${LAN_segment['sw01-sw12']}"
vmxmod sw01 ethernet3.pvnID "${LAN_segment['sw01-sw13']}"
vmxmod sw01 ethernet4.pvnID "${LAN_segment['sw01-sw14']}"
vmxmod sw01 ethernet5.pvnID "${LAN_segment['sw01-sw02-link5']}"
vmxmod sw01 ethernet6.pvnID "${LAN_segment['sw01-sw02-link6']}"
vmxmod sw01 ethernet7.connectionType custom
vmxmod sw01 ethernet7.vnet /dev/vmnet4
vmxmod sw02 ethernet1.pvnID "${LAN_segment['sw02-sw11']}"
vmxmod sw02 ethernet2.pvnID "${LAN_segment['sw02-sw12']}"
vmxmod sw02 ethernet3.pvnID "${LAN_segment['sw02-sw13']}"
vmxmod sw02 ethernet4.pvnID "${LAN_segment['sw02-sw14']}"
vmxmod sw02 ethernet5.pvnID "${LAN_segment['sw01-sw02-link5']}"
vmxmod sw02 ethernet6.pvnID "${LAN_segment['sw01-sw02-link6']}"
vmxmod sw02 ethernet7.connectionType custom
vmxmod sw02 ethernet7.vnet /dev/vmnet4

# Uplinks der Leaf-Switches sw11 bis sw14
vmxmod sw11 ethernet1.pvnID "${LAN_segment['sw01-sw11']}"
vmxmod sw11 ethernet2.pvnID "${LAN_segment['sw02-sw11']}"
vmxmod sw12 ethernet1.pvnID "${LAN_segment['sw01-sw12']}"
vmxmod sw12 ethernet2.pvnID "${LAN_segment['sw02-sw12']}"
vmxmod sw13 ethernet1.pvnID "${LAN_segment['sw01-sw13']}"
vmxmod sw13 ethernet2.pvnID "${LAN_segment['sw02-sw13']}"
vmxmod sw14 ethernet1.pvnID "${LAN_segment['sw01-sw14']}"
vmxmod sw14 ethernet2.pvnID "${LAN_segment['sw02-sw14']}"

# Verbindungen der Leaf-Switches untereinander
vmxmod sw11 ethernet3.pvnID "${LAN_segment['sw11-sw12-link3']}"
vmxmod sw11 ethernet4.pvnID "${LAN_segment['sw11-sw12-link4']}"
vmxmod sw12 ethernet3.pvnID "${LAN_segment['sw11-sw12-link3']}"
vmxmod sw12 ethernet4.pvnID "${LAN_segment['sw11-sw12-link4']}"
vmxmod sw13 ethernet3.pvnID "${LAN_segment['sw13-sw14-link3']}"
vmxmod sw13 ethernet4.pvnID "${LAN_segment['sw13-sw14-link4']}"
vmxmod sw14 ethernet3.pvnID "${LAN_segment['sw13-sw14-link3']}"
vmxmod sw14 ethernet4.pvnID "${LAN_segment['sw13-sw14-link4']}"

# Access-Ports der Leaf-Switches
vmxmod sw11 ethernet5.pvnID "${LAN_segment['sw11-server1-vmnic1']}"
vmxmod sw11 ethernet6.pvnID "${LAN_segment['sw11-server2-eth1']}"
vmxmod sw12 ethernet5.pvnID "${LAN_segment['sw12-server1-vmnic2']}"
vmxmod sw12 ethernet6.pvnID "${LAN_segment['sw12-server2-eth2']}"
vmxmod sw12 ethernet7.pvnID "${LAN_segment['sw12-server2-eth3']}"
vmxmod sw13 ethernet5.pvnID "${LAN_segment['sw13-server3-eth1']}"
vmxmod sw13 ethernet6.pvnID "${LAN_segment['sw13-server4-nic1']}"
vmxmod sw14 ethernet5.pvnID "${LAN_segment['sw14-server3-eth2']}"
vmxmod sw14 ethernet6.pvnID "${LAN_segment['sw14-server4-nic2']}"

# ungenutzte Switchports deaktivieren
vmxmod sw11 ethernet7.present FALSE
vmxmod sw13 ethernet7.present FALSE
vmxmod sw14 ethernet7.present FALSE

# Switches starten
for SWITCH_ID in {01,02,11,12,13,14} ; do
  vmrun -T ws start ~/vmware/sw${SWITCH_ID}/sw${SWITCH_ID}.vmx
  sleep 2
done

# Switches in GUI öffnen
vmware --new-tab ~/vmware/sw01/sw01.vmx ~/vmware/sw02/sw02.vmx ~/vmware/sw11/sw11.vmx ~/vmware/sw12/sw12.vmx ~/vmware/sw13/sw13.vmx ~/vmware/sw14/sw14.vmx
