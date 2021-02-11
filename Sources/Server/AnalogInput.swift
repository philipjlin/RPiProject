import Foundation
import SmokeOperations

public struct AnalogInput: Codable, Validatable {
    static let jsonDecoder = JSONDecoder()
    
    public let analogState: String
    
    var isOn: Bool { return analogState == "on" }
    
    public init(analogState: String) {
        self.analogState = analogState.lowercased() == "on" ? "on" : "off"
    }
    
    public init?(data: Data) {
        guard let decodedSelf = try? AnalogInput.jsonDecoder.decode(AnalogInput.self, from: data) else {
            return nil
        }
        self = decodedSelf
    }
    
    public func validate() throws {
        return
    }
}

extension AnalogInput : Equatable {
    public static func ==(lhs: AnalogInput, rhs: AnalogInput) -> Bool {
        return lhs.analogState == rhs.analogState
    }
}

extension AnalogInput: CustomStringConvertible {
    public var description: String { return "AnalogInput(analogState: \"\(analogState)\")" }
}
