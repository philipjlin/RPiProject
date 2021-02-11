#!/bin/sh
echo "Running test of led server"
echo ""
echo "Output:"
curl -X "POST" "http://10.8.0.40:8080/led" -H 'Content-Type: text/plain; charset=utf-8' -d $'{ "ledState": "on" }'
echo ""
sleep 5
curl -X "POST" "http://10.8.0.40:8080/led" -H 'Content-Type: text/plain; charset=utf-8' -d $'{ "ledState": "off" }'
echo ""
sleep 1
curl -X "POST" "http://10.8.0.40:8080/led" -H 'Content-Type: text/plain; charset=utf-8' -d $'{ "ledState": "on" }'
sleep 1
curl -X "POST" "http://10.8.0.40:8080/led" -H 'Content-Type: text/plain; charset=utf-8' -d $'{ "ledState": "off" }'
sleep 1
curl -X "POST" "http://10.8.0.40:8080/led" -H 'Content-Type: text/plain; charset=utf-8' -d $'{ "ledState": "on" }'
sleep 1
curl -X "POST" "http://10.8.0.40:8080/led" -H 'Content-Type: text/plain; charset=utf-8' -d $'{ "ledState": "off" }'
