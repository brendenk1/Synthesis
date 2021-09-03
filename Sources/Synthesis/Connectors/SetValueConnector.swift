import Combine
import Foundation

/*
 A default connect suitable for setting a value on a `Kernel` instance.
 
 For example:
 
 ```
 Action(connector: SetValueConnector(value: true),
        kernel: someKernel)
    .execute()
 ```
 */
public struct SetValueConnector<Value>: Connector {
    /// A default connect suitable for setting a value on a `Kernel` instance.
    public init(value: Value?) {
        self.value = value
    }
    
    public typealias Element = Value
    
    let value: Value?
    
    public func connect() -> Output {
        Just(value)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
