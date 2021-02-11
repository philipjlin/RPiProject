import Foundation
import SmokeOperations

public struct AnalogOutput: Codable, Validatable {
    public let analogState: String
    public let analogValue: String
    
    public init(analogState: String, analogValue: String = "0.0") {
        self.analogState = analogState
        self.analogValue = analogValue
    }
    
    public init(analogState: Bool, analogValue: Double = 0.0) {
        self.analogState = analogState ? "on" : "off"
        self.analogValue = "\(analogValue)"
    }
    
    public func validate() throws { }
}

extension AnalogOutput : Equatable {
    public static func ==(lhs: AnalogOutput, rhs: AnalogOutput) -> Bool {
        return lhs.analogState == rhs.analogState
        && lhs.analogValue == rhs.analogValue
    }
}

extension AnalogOutput: CustomStringConvertible {
    public var description: String {
        return "AnalogOutput(analogState: \"\(analogState)\", analogValue = \(analogValue))"
    }
}
