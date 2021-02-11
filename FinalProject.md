# Instructions for your Final Project

1. If you have the large shield, in Package.swift change the commented dependency code as shown. If you have the small shield (this is almost everyone) this does not apply.
2. Physically connect your LED to .digital2722, Potentiometer to .analog01, and Touch Sensor to .digital1718\. (If you have the largeshield: LED to .digital1516, Potentiometer to .analog01, Touch Sensor to .digital2627)
3. Make sure that your bluetooth port is up using `hciconfig -a` and `sudo systemctl start hciuart.service` if need be.
4. Provide the code requested in GPIOInput.swift - 50 Points total as marked
5. Provide the code requested in AnalogService.swift - 50 points total as marked
6. Provide the code requested in BluetoothService.swift - 10 points
7. Provide the code requested in CustomService.swift - 10 points
8. Deploy your code to your Pi. Use the testBLE.sh script to turn on BLE. Capture a short video of using BlueSee to turn on and off LED and see the results of manipulation of the potentiometer and place check that into your assignment repo. 40 Points

## Graduate Student Requirement (Does not apply if you are an undergrad)

1. Using the techniques shown in class, and the watchtower.sh script provided in the Assignment repo use watchtower to update your deployment automatically. Capture output of `docker logs -tf watchtower` to verify updates (40 points)
