#!/bin/bash

# use this script as "pass" script for snmpd.conf
# include via line in snmpd.conf:
# pass 1.3.6.1.4.1.2021.255 /usr/share/snmp/acl_tcam.sh

CMD="$1"
OID="$2"

echo $OID
echo integer

if [ -e /etc/cumulus/.license.vx ] ; then
  # Virtueller Switch / Cumulus VX: Nichts machen
else
  # Physikalischer Switch: Resourcen auswerten

  export IFS="\s"
  RESOURCES=`cl-resource-query | grep "% of"`
  for ACL in $RESOURCES ; do
    echo --$ACL--
  done


  for SETTING in ingress/v4mac_filter ingress/v4mac_mangle egress/slices ; do
    ALLOC=$(cat /cumulus/switchd/run/acl_info/$SETTING/entries_allocated)
    USED=$(cat /cumulus/switchd/run/acl_info/$SETTING/entries_used)
    MAX=$(cat /cumulus/switchd/run/acl_info/$SETTING/entries_max)
    echo $(expr $USED / $MAX)

    if [ $(expr $USED / $MAX) -gt 95 ] ; then # alert if above 95%
      echo $SETTING
    fi
  done
echo 0
