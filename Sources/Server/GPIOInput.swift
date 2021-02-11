//
//  GPIOInput.swift
//  Bluetooth
//
//  Created by Van Simmons on 4/21/19.
//

import Foundation
import SwiftyLinkerKit
import HeliumLogger
import LoggerAPI

struct GPIOInput {
    static let logger = HeliumLogger()
    static let touchSensor = LKButton2()
    static let shield = LKRBShield.default
    static let display: LKDigi? = {
        guard let shield = shield else { return nil }
        let d = LKDigi()
        shield.connect(d, to: .digital2324)
        return d
    }()
    static let df: DateFormatter = {
        let d = DateFormatter()
        d.dateFormat = "mmss"
        return d
    }()

    static var potOn: Bool = false {
        didSet {
            if potOn {
                /*
                 Question 1.1 (10 points) Implement didSet such that it only takes effect for
                 changes bigger than 5% just return otherwise */
                pot.onChange { (temperature) in
                    guard fabs( ((temperature - potValue)/potValue) * 100.0 ) > 5 else { return }
                    potValue = temperature
                    display?.show(Int(potValue * 100.0))
                    Log.info("Potentiometer raw value is \(potValue)")
                    /*
                     Question 1.2 (10 points) After verifying the change is significant, update the
                     custom BLE Service to notify any subscribers of the new value.
                     The new value will need to be in string format
                     */
                    (BLEServer.serviceController as? GATTCustomServiceController)?.notifyValue = "\(temperature)"
                }
            } else {
                /*
                 Question 1.3 (10 points) stop handling updates from the potentiometer
                 */
                pot.removeAllListeners()
                pot.onChange { _ in }
            }
        }
    }
    static let pot = LKTemp(interval: 0.2, valueType: .voltage)
    static var potValue = 0.0

    static func handleGPIOInput() {
        guard let shield = shield else { return }
        Log.logger = logger

        shield.connect(touchSensor, to: .digital1718)

        touchSensor.onPress1 { () in
            Log.info("Button 1 pressed")
            /*
             Question 1.4 (10 points) if the touch sensor is pressed turn the LED on
             */
            LEDService.led.on = !LEDService.led.on
        }

        // Display
        if let display = display {
            display.show(9999)
        }

        // Analog device
        shield.connect(pot, to: .analog01)
        /*
         Question 1.5 (10 points) start gathering information from the potentiometer
         */
        potOn = true
    }
}
