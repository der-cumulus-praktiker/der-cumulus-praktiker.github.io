#!/bin/bash

# API-Kommando ermitteln
read -r http_get
command=$(echo $http_get | awk '{ print $2 }')

if [ -z {command+x} ] ; then
  echo -e 'HTTP/1.1 500\r\n\r'
else
  echo -e 'HTTP/1.1 200 OK\r\n\r'

  case "$command" in
    /my/uptime)
      uptime --pretty
      ;;
    /my/sensor)
      /usr/bin/sensors --no-adapter
      ;;
    /my/date)
      date --rfc-3339=seconds
      ;;
    *)
      echo "Unbekanntes Kommando"
  esac
fi
