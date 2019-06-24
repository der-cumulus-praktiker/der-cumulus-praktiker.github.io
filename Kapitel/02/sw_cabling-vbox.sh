#!/bin/bash
## Alle virtuellen Maschinen miteinander verkabeln

# Die Kommandos als "vbox"-User ausführen
if [ "$USER" != "vbox" ] ; then
  exit 1
fi

for SWITCH_ID in {01,02,11,12,13,14} ; do
  for PORT_ID in {2..8} ; do
    VBoxManage modifyvm sw${SWITCH_ID} --nic${PORT_ID} intnet
    VBoxManage modifyvm sw${SWITCH_ID} --nictype${PORT_ID} virtio
  done
done

# Spine-Switches sw01 und sw02
VBoxManage modifyvm sw01 --intnet2 "sw01-sw11"
VBoxManage modifyvm sw01 --intnet3 "sw01-sw12"
VBoxManage modifyvm sw01 --intnet4 "sw01-sw13"
VBoxManage modifyvm sw01 --intnet5 "sw01-sw14"
VBoxManage modifyvm sw01 --intnet6 "sw01-sw02-link5"
VBoxManage modifyvm sw01 --intnet7 "sw01-sw02-link6"
VBoxManage modifyvm sw01 --nic8 hostonly
VBoxManage modifyvm sw01 --hostonlyadapter8 "vboxnet4"
VBoxManage modifyvm sw01 --macaddress8 0c1224010401

VBoxManage modifyvm sw02 --intnet2 "sw02-sw11"
VBoxManage modifyvm sw02 --intnet3 "sw02-sw12"
VBoxManage modifyvm sw02 --intnet4 "sw02-sw13"
VBoxManage modifyvm sw02 --intnet5 "sw02-sw14"
VBoxManage modifyvm sw02 --intnet6 "sw01-sw02-link5"
VBoxManage modifyvm sw02 --intnet7 "sw01-sw02-link6"
VBoxManage modifyvm sw02 --nic8 hostonly
VBoxManage modifyvm sw02 --hostonlyadapter8 "vboxnet4"
VBoxManage modifyvm sw02 --macaddress8 0c1224020402

# Uplinks der Leaf-Switches sw11 bis sw14
VBoxManage modifyvm sw11 --intnet2 "sw01-sw11"
VBoxManage modifyvm sw11 --intnet3 "sw02-sw11"
VBoxManage modifyvm sw12 --intnet2 "sw01-sw12"
VBoxManage modifyvm sw12 --intnet3 "sw02-sw12"
VBoxManage modifyvm sw13 --intnet2 "sw01-sw13"
VBoxManage modifyvm sw13 --intnet3 "sw02-sw13"
VBoxManage modifyvm sw14 --intnet2 "sw01-sw14"
VBoxManage modifyvm sw14 --intnet3 "sw02-sw14"

# Verbindungen der Leaf-Switches untereinander
VBoxManage modifyvm sw11 --intnet4 "sw11-sw12-link3"
VBoxManage modifyvm sw11 --intnet5 "sw11-sw12-link4"
VBoxManage modifyvm sw12 --intnet4 "sw11-sw12-link3"
VBoxManage modifyvm sw12 --intnet5 "sw11-sw12-link4"
VBoxManage modifyvm sw13 --intnet4 "sw13-sw14-link3"
VBoxManage modifyvm sw13 --intnet5 "sw13-sw14-link4"
VBoxManage modifyvm sw14 --intnet4 "sw13-sw14-link3"
VBoxManage modifyvm sw14 --intnet5 "sw13-sw14-link4"

# Access-Ports der Leaf-Switches
VBoxManage modifyvm sw11 --intnet6 "sw11-server1-vmnic1"
VBoxManage modifyvm sw11 --intnet7 "sw11-server2-eth1"
VBoxManage modifyvm sw12 --intnet6 "sw12-server1-vmnic2"
VBoxManage modifyvm sw12 --intnet7 "sw12-server2-eth2"
VBoxManage modifyvm sw12 --intnet8 "sw12-server2-eth3"
VBoxManage modifyvm sw13 --intnet6 "sw13-server3-eth1"
VBoxManage modifyvm sw13 --intnet7 "sw13-server4-nic1"
VBoxManage modifyvm sw14 --intnet6 "sw14-server3-eth2"
VBoxManage modifyvm sw14 --intnet7 "sw14-server4-nic2"
