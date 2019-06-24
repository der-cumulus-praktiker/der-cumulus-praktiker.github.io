#!/bin/bash

function error() {
  echo -e "\e[0;33mERROR: The Zero Touch Provisioning script failed
  while running the command $BASH_COMMAND at line $BASH_LINENO.\e[0m" >&2
  exit 1
}

# [de] Kommandoausgaben in eine Logdatei umlenken
# [en] send all command output to log file
exec >> /var/log/autoprovision 2>&1
date "+%FT%T ztp starting script $0"
trap error ERR

# [de] Kurze Pause bis die NCLU nutzbar ist
# [en] wait for NCLU to become ready
for i in $(seq 1 20); do
  net show version >/dev/null
  if [ $? -eq 0 ] ; then
    break
  else
    sleep 5
  fi
done

# [de] NCLU ist bereit fuer Befehle
# [en] Now NCLU is ready to accept commands
net add time zone Europe/Berlin
net add hostname ${HOSTNAME}

# [de] Vorgegebenen DNS-Server entfernen
# [en] remove preconfigured DNS server
net del dns nameserver ipv4 10.20.249.1

# [de] Zugewiesene DHCP-Adresse als statische Adresse verwenden
# [en] use assigned DHCP address as static management address
IP_ETH0=$(ip addr show eth0 | grep "inet " | awk '{ print $2}')
DG_ETH0=$(netstat -nr4 | grep "^0.0.0.0" | awk '{ print $2 }')
NS_ETH0=$(grep -m1 "nameserver" /etc/resolv.conf | awk '{ print $2 }')
net add interface eth0 ip address ${IP_ETH0}
net add interface eth0 ip gateway ${DG_ETH0}
net add dns nameserver ipv4 ${NS_ETH0}
net commit

# [de] SSH-Login mit Schlüssel aber ohne Passwort
# [en] login with SSH key and without password
mkdir -p ~cumulus/.ssh/
cat << EOF >> ~cumulus/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEA1iCLr6uIu0S7btbOtaxpIATcUG+6Qbn/V/c7dxvpKHwD61xGCTpPRa7vosknCMKXG8LiMBSUdJVW/uEQlM8cP3aYIWF182yWiM1THtJCvxprd4yVCu0Arfsw+aPhrp9VE4h6pdHwpZ0qvszMnud55mpdQL1rviv3BNaxljY+Bmcw+37NNmzzWeYnB6EyeVscUTYqxz8Vl7GHD2cRSl/pRr4tH8odpeF9H1oTflZpnQyYGOLlMwAoFUuVxmQ1UMbWFgIx/SIFgbkuubyx4CyJ76edZjCJsVElvks6SDmNIxi6iSPQNDTw8qkTB4JYnI11Q8g1dRV5cPyTQmV/QGk9Vw== rsa-key-clb
EOF

# [de] Der "cumulus"-Benutzer darf ohne Kennwort root werden
# [en] user "cumulus" may become root without entering a password
echo "cumulus ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# [de] Ein paar Einträge für die Bequemlichkeit
# [en] some settings for easy typing
cat <<EOF >> ~cumulus/.bashrc
alias ll='ls -l'
set -o vi
PROMPT_COMMAND='printf "\033]0;%s@%s\007" "\${USER}" "\${HOSTNAME%%.*}"'
EOF
echo "?: complete" >> ~cumulus/.inputrc
cat <<EOF >> ~root/.bashrc
alias ll='ls -l'
set -o vi
PROMPT_COMMAND='printf "\033]0;%s@%s\007" "\${USER}" "\${HOSTNAME%%.*}"'
EOF
echo "?: complete" >> ~root/.inputrc

# [de] Passende Lizenz einspielen (Cumulus VX benötigt keine Lizenz)
# [en] install a license for this switch (Cumulus VX doesn't need a license)
if [ ! -e /etc/cumulus/.license.vx ] ; then
  /usr/cumulus/bin/cl-license -i http://10.5.2.7/license/${HOSTNAME}.lic
fi

# CUMULUS-AUTOPROVISIONING
date "+%FT%T ztp script $0 ended"
exit 0
