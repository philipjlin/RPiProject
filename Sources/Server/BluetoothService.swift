//
//  BluetoothService.swift
//  Server
//
//  Created by Van Simmons on 4/22/19.
//

import Foundation
import SmokeHTTP1
import SmokeOperations
import SmokeOperationsHTTP1
import LoggerAPI
import NIOHTTP1
import Dispatch

struct BluetoothService: Service {
    typealias InputType = BluetoothInput
    typealias OutputType = BluetoothOutput
    
    static let jsonEncoder = JSONEncoder()
    static let jsonDecoder = JSONDecoder()
    static var peripheral: PeripheralManager?

    static var bluetoothState: Bool = false {
        didSet {
            if bluetoothState {
                print("Trying BLEServer.setup()")
                peripheral = try? BLEServer.setup()
                if let peripheral = peripheral {
                    do { try peripheral.start() } // GATTPeripheral.swift
                    catch {
                        /*
                         Question 3: (30 points) Log a failure to start reason based on the error
                         and then exit the server
                         */
                        print("\(error.localizedDescription)")
                        Log.error("Bluetooth server failed to start")
                        exit(1)
                    }
                }
            } else {
                print("Trying BLEServer.stop()")
                BLEServer.stop(peripheral: peripheral)
            }
        }
    }
    
    // decode the input stream from the request
    static let inputDecoder = { (request: SmokeHTTP1RequestHead, data: Data?) throws -> BluetoothInput in
        Log.info("Handling BluetoothService request: \(request)")
        guard let data = data, let decoded = BluetoothInput(data: data) else {
            Log.error("No request body for request \(request)")
            throw ApplicationContext.allowedErrors[0].0
        }
        Log.info("BluetoothService decoded request: \(decoded)")
        return decoded
    }
    
    // transform the input into the output
    typealias BluetoothResultHandler = (SmokeResult<BluetoothOutput>) -> Void
    static let transform = { (input: BluetoothInput, context: ApplicationContext) -> BluetoothOutput in
        let output = BluetoothOutput(bluetoothState: input.bluetoothState)
        Log.info("Transforming BluetoothService Input: \(input)")
        BluetoothService.bluetoothState = input.bluetoothState.lowercased() == "on"
        Log.info("Finished Transforming BluetoothService Input: \(input) to Output: \(output)")
        return output
    }
    
    // encode the output into the response
    static let outputEncoder = { (request: SmokeHTTP1RequestHead, output: BluetoothOutput, responseHandler: HTTP1ResponseHandler) in
        var body = ( contentType: "application/json", data: Data() )
        var responseCode = HTTPResponseStatus.ok
        if let encoded = output.bluetoothState.data(using: .utf8)  {
            body = ( contentType: "application/json", data: encoded )
        } else {
            responseCode = HTTPResponseStatus.internalServerError
            body = ( contentType: "application/json", data: try! jsonEncoder.encode(["message": "output failure"]) )
        }
        let response = HTTP1ServerResponseComponents(
            additionalHeaders: [],
            body: body
        )
        Log.info("Encoding BluetoothService Output: \(response)")
        responseHandler.completeInEventLoop(status: responseCode, responseComponents: response)
    }
    
    static let serviceHandler = OperationHandler<ApplicationContext, SmokeHTTP1RequestHead, HTTP1ResponseHandler>(
        inputProvider: BluetoothService.inputDecoder,
        operation: BluetoothService.transform,
        outputHandler: BluetoothService.outputEncoder,
        allowedErrors: ApplicationContext.allowedErrors,
        operationDelegate: ApplicationContext.operationDelegate
    )
}
