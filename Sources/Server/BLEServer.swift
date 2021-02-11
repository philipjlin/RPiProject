//
//  main.swift
//  gattserver
//
//  Created by Alsey Coleman Miller on 6/29/18.
//
//

import Foundation
import CoreFoundation
import Bluetooth

import GATT
import BluetoothLinux
public typealias PeripheralManager = GATTPeripheral<HostController, L2CAPSocket>

public enum CommandError: Error {
    case bluetoothUnavailible
    case noCommand
    case invalidCommandType(String)
    case invalidOption(String)
    case missingOption(String)
    case optionMissingValue(String)
    case invalidOptionValue(option: String, value: String)
}

public protocol GATTServiceController: class {
    static var service: BluetoothUUID { get }
    var peripheral: PeripheralManager { get }
    init(peripheral: PeripheralManager) throws
}

internal let serviceControllers: [GATTServiceController.Type] = [
    GATTCustomServiceController.self
]

public extension Data {
    /// A hexadecimal string representation of the bytes.
    var hexEncodedString: String {
        let hexDigits = Array("0123456789abcdef".utf16)
        var hexChars = [UTF16.CodeUnit]()
        hexChars.reserveCapacity(count * 2)
        
        self.forEach { byte in
            let (index1, index2) = Int(byte).quotientAndRemainder(dividingBy: 16)
            hexChars.append(hexDigits[index1])
            hexChars.append(hexDigits[index2])
        }
        
        return String(utf16CodeUnits: hexChars, count: hexChars.count)
    }
}

public struct BLEServer {
    static var serviceController: GATTServiceController?
    
    static func stop(peripheral: PeripheralManager?) {
        if let peripheral = peripheral {
            peripheral.stop()
        }
    }
    
    static func setup() throws -> PeripheralManager {
        #if os(Linux)
        print("obtain Bluetooth Controller")
        guard let controller = HostController.default
            else {
                print("bluetooth unavailable")
                throw CommandError.bluetoothUnavailible
            }
        print("Bluetooth Controller: \(controller.address)")
        
        let peripheral = PeripheralManager(controller: controller)
        peripheral.removeAllServices()
        peripheral.newConnection = { [weak peripheral] () throws -> (L2CAPSocket, Central) in
            let serverSocket = try L2CAPSocket.lowEnergyServer(
                controllerAddress: controller.address,
                isRandom: false,
                securityLevel: .low
            )
            let socket = try serverSocket.waitForConnection()
            let central = Central(identifier: socket.address)
            peripheral?.log?("[\(central)]: New \(socket.addressType) connection")
            return (socket, central)
        }
        #endif
        
        peripheral.log = { print("PeripheralManager:", $0) }
        
        //let serviceUUIDString = "C31F15B2-2D21-48D6-A0E9-5FA168B78763"
        let serviceUUIDString = "FB21F3C1-654B-49DD-98CF-184D0F157D50"

        guard let service = BluetoothUUID(rawValue: serviceUUIDString),
            let controllerType = serviceControllers.first(where: { $0.service == service })
            else { throw CommandError.invalidCommandType(serviceUUIDString) }
        
        serviceController = try controllerType.init(peripheral: peripheral)
        print(controllerType) // RT
        
        return peripheral
    }
}
