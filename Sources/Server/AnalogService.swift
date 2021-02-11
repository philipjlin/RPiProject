//
//  AnalogService.swift
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

struct AnalogService: Service {
    typealias InputType = AnalogInput
    typealias OutputType = AnalogOutput
    
    static let jsonEncoder = JSONEncoder()
    static let jsonDecoder = JSONDecoder()

    /*
     Question 2.1 return the value of GPIOInput.potOn when requested
     */
    static var analogState: Bool {
        get { return GPIOInput.potOn }
        /*
         Question 2.2 set the value of GPIOInput.pot to be equal to the AnalogState
         */
        set {
            print("setting potOn to \(analogState)")
            GPIOInput.potOn = analogState
        }
    }
    
    static let inputDecoder = { (request: SmokeHTTP1RequestHead, data: Data?) throws -> AnalogInput in
        Log.info("Handling AnalogService request: \(request)")
        guard let data = data, let decoded = AnalogInput(data: data) else {
            Log.error("No request body for request \(request)")
            throw ApplicationContext.allowedErrors[0].0
        }
        Log.info("AnalogService decoded request: \(decoded)")
        return decoded
    }
    
    // transform the input into the output
    typealias AnalogResultHandler = (SmokeResult<AnalogOutput>) -> Void
    static let transform = { (input: AnalogInput, context: ApplicationContext) -> AnalogOutput in
        /*
         Question 2.3 Make output show the current analog state AND the last captured
         value of the analog input
         */
        let output = AnalogOutput(analogState: input.analogState,
                                  analogValue: "\(GPIOInput.potValue)")
        
        Log.info("Transforming AnalogService Input: \(input)")
        /*
         Question 2.4 set the value of analog state appropriately for the received value
         */
        AnalogService.analogState = input.analogState.lowercased() == "on"
        
        Log.info("Finished Transforming AnalogService Input: \(input) to Output: \(output)")
        return output
    }
    
    // encode the output into the response
    static let outputEncoder = { (request: SmokeHTTP1RequestHead, output: AnalogOutput, responseHandler: HTTP1ResponseHandler) in
        var body = ( contentType: "application/json", data: Data() )
        var responseCode = HTTPResponseStatus.ok
        /*
         Question 2.5 return the current value of the output as a string
         */
        if let encoded = output.description.data(using: .utf8)  {
            body = ( contentType: "application/json", data: encoded )
        } else {
            responseCode = HTTPResponseStatus.internalServerError
            body = ( contentType: "application/json", data: try! jsonEncoder.encode(["message": "output failure"]) )
        }
        let response = HTTP1ServerResponseComponents(
            additionalHeaders: [],
            body: body
        )
        Log.info("Encoding AnalogService Output: \(response)")
        responseHandler.completeInEventLoop(status: responseCode, responseComponents: response)
    }
    
    static let serviceHandler = OperationHandler<ApplicationContext, SmokeHTTP1RequestHead, HTTP1ResponseHandler>(
        inputProvider: AnalogService.inputDecoder,
        operation: AnalogService.transform,
        outputHandler: AnalogService.outputEncoder,
        allowedErrors: ApplicationContext.allowedErrors,
        operationDelegate: ApplicationContext.operationDelegate
    )
}
