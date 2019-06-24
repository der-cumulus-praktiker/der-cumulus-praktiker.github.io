#!/bin/bash

# purpose: prepare Cumulus VMs for usage in VirtualBox

for id in {61,62} ; do
  VBoxManage import /data/vmware/images/cumulus-linux-3.6.2-vx-amd64.ova \
    --vsys 0 --ostype "Debian_64" --vmname sw${id} --vsys 0 --unit 14 \
    --disk "${HOME}/VirtualBox VMs/sw${id}/disk.vmdk"

  # console access
  VBoxManage modifyvm sw${id} --vrde on
  VBoxManage modifyvm sw${id} --vrdeport 81${id}
  VBoxManage modifyvm sw${id} --vrdeaddress "${HOSTNAME}"
  VBoxManage modifyvm sw${id} --uart1 0x3F8 4
  VBoxManage modifyvm sw${id} --uartmode1 server /tmp/${SW_NAME}.pipe

  # management adapter
  VBoxManage modifyvm sw${id} --nic1 bridged
  VBoxManage modifyvm sw${id} --bridgeadapter1 eth1
  VBoxManage modifyvm sw${id} --nictype1 virtio
  VBoxManage modifyvm sw${id} --macaddress1 \
    $(printf "0c1269%02d0101" ${id})

  # mlag adapter
  VBoxManage modifyvm sw${id} --nic2 bridged
  VBoxManage modifyvm sw${id} --nictype2 virtio
  VBoxManage modifyvm sw${id} --macaddress2 \
    $(printf "0c1269%02d0101" ${id})

  for PORT in {3..5} ; do
    VBoxManage modifyvm sw${id} --nic${PORT} intnet
    VBoxManage modifyvm sw${id} --nictype${PORT} virtio
  done

  VBoxManage modifyvm sw${id} --intnet3 "sw6x-cl5"
  VBoxManage modifyvm sw${id} --intnet4 "sw61-sw62-peerlink1"
  VBoxManage modifyvm sw${id} --intnet5 "sw61-sw62-peerlink2"
done

VBoxManage modifyvm sw61 --bridgeadapter2 eth1
VBoxManage modifyvm sw62 --bridgeadapter2 eth2
