#!/bin/bash
curl -X "POST" "http://10.8.0.40:8080/ble" \
     -H 'Content-Type: application/json; charset=utf-8' \
     -d $'{ "bluetoothState": "on" }'
echo ""
