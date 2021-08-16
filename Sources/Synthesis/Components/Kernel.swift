import Combine
import Foundation

/*
 noun: the most basic level or core

 These objects represent the source of truth over time
 
 The Kernel can publish updates on any thread as the connections the Kernel is connected to will update its value. Any connections that emit an error are dropped by the Kernel leaving the existing value in tact.
 
 By design the Kernel instance always publishes `Swift.Optional` types. This allows for more nuanced expression of any source of truth. For example if the instance is representing some value from a remote source, then at time of initialization that value from the remote source might be unknown.
 
 For example: a source of truth for some date value
 
 let kernel: Kernel<Date> = Kernel()
 */
final class Kernel<T>: ObservableObject
{
    @Published private var value: T?
    
    /// A publisher that will emit the current value and any updates as received by the Kernel
    func whenValueUpdates() -> AnyPublisher<T?, Never> {
        $value
            .eraseToAnyPublisher()
    }
    
    /// A method that allows the Kernel to receive a connection
    func subscribeTo<P>(_ connection: P)
    where P: Publisher,
          P.Output == T?,
          P.Failure == Error
    {
        connection
            .replaceError(with: value)
            .assign(to: &$value)
    }
}
