#!/bin/bash
curl -X "POST" "http://10.8.0.40:8080/analog" \
     -H 'Content-Type: application/json; charset=utf-8' \
     -d $'{ "analogState": "off" }'
echo ""
