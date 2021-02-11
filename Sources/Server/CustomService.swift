//
//  CustomService.swift
//  Server
//
//  Created by Van Simmons on 4/22/19.
//

import Foundation
import Bluetooth
import GATT
import BluetoothLinux

public final class GATTCustomServiceController: GATTServiceController {
    public static let service: BluetoothUUID = BluetoothUUID(uuid: UUID(uuidString: "FB21F3C1-654B-49DD-98CF-184D0F157D50")!)
    public static let notifyUuid = BluetoothUUID(uuid: UUID(uuidString: "4808D7EF-8AA6-4D85-9667-0604C144695B")!)
    public static let writeUuid = BluetoothUUID(uuid: UUID(uuidString: "E8EDFF7A-D97B-4AE3-8333-FC7FF7371276")!)

    
    public let peripheral: PeripheralManager
    
    public var notifyValue = "" {
        didSet {
            peripheral[characteristic: notifyHandle] = notifyValue.data(using: .utf8)!
        }
    }
    
    public var writeValue: UInt8 = 0 {
            didSet {
                /*
                 Question 4 (30 points): Turn on the LED when the input value is
                 non zero, turn it off if zero
                 */
                LEDService.ledState = writeValue != 0
                
                print("did set writeValue \(writeValue)")
                notifyValue = "\(writeValue)"
            }
        }
    internal let serviceHandle: UInt16
    internal let notifyHandle: UInt16
    internal let writeHandle: UInt16
    
    // MARK: - Initialization
    
    public init(peripheral: PeripheralManager) throws {
        self.peripheral = peripheral
        let serviceUUID = type(of: self).service
        
        let descriptors = [GATTClientCharacteristicConfiguration().descriptor]
        
        let characteristics = [
            GATT.Characteristic(uuid: GATTCustomServiceController.notifyUuid,
                                value: notifyValue.data(using: .utf8)!,
                                permissions: [.read],
                                properties: [.notify],
                                descriptors: descriptors),
            
            GATT.Characteristic(uuid: GATTCustomServiceController.writeUuid,
                                value: Data([0]),
                                permissions: [.read, .write],
                                properties: [.read, .write],
                                descriptors: descriptors)
        ]
        
        let service = GATT.Service(uuid: serviceUUID,
                                   primary: true,
                                   characteristics: characteristics)
        
        self.serviceHandle = try peripheral.add(service: service)
        self.notifyHandle = peripheral.characteristics(for: GATTCustomServiceController.notifyUuid)[0]
        self.writeHandle = peripheral.characteristics(for: GATTCustomServiceController.writeUuid)[0]
        
        self.peripheral.willWrite = { [weak self] (request) -> ATT.Error? in
            guard let self = self else { return nil }
            switch request.uuid {
            case GATTCustomServiceController.writeUuid:
                let value = request.newValue[0]
                self.writeValue = value
                return nil
                
            default:
                return nil
            }
        }
    }
    
    deinit {
        self.peripheral.remove(service: serviceHandle)
    }
}

