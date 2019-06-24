#!/bin/bash

# Zugriff zur Telegram-API
API_KEY="514541725:AAGEb8xex_qoElQOItRwQ451ukSr5hxYNMm"
CHAT_ID=277114768

MESSAGE="$@"

# Proxyserver verwenden?
if [ -f /etc/profile.d/proxy.sh ] ; then
  . /etc/profile.d/proxy.sh
fi

# Nachricht an Telegram senden
/usr/bin/curl --silent --ipv4 \
  --data "chat_id=$CHAT_ID&text=$HOSTNAME:+$MESSAGE" \
  https://api.telegram.org/bot$API_KEY/sendMessage >/dev/null
