import Combine
import Foundation

/*
 noun: the fact or process of doing something, typically to achieve an aim

 These objects are responsible for connecting a Kernel to a Connector object
 
 For example: we might have a connector that is responsible for fetching data from a remote source and that connector should then update the Kernel with the results.
 
 Where:
 
 let kernel: Kernel<Data> = Kernel()
 let connector = SomeDataConnector()
 let action = Action(connector: connector, kernel: kernel)
 
 The action object allows for the execution and the subsequent connection to the kernel via two methods:
 * `execute()`
 * `execute(onError:)`
 
 Calling `execute()` on the action serves to immediately form the connection and the underlying subscription to perform the work, ignoring any errors that might result from the connection.
 
 Calling `execute(with:)` on the action serves to immediately form the connection and the underlying subscription to perform the work, allowing for the subscriber to be notified of any errors encountered. Any Errors received will be published on the `Main` thread.
 */
public struct Action<C, T>
where C: Connector,
      C.Element == T
{
    public init(connector: C, kernel: Kernel<T>) {
        self.connector = connector
        self.kernel = kernel
    }
    
    let connector: C
    let kernel: Kernel<T>
    
    private func connection<S>(errorSubscription: S) -> AnyPublisher<T?, Error>
    where S: Subscriber,
          S.Input == Error,
          S.Failure == Never
    {
        connector
            .connect()
            .handleEvents(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    Just(error)
                        .receive(on: DispatchQueue.main)
                        .subscribe(errorSubscription)
                }
            })
            .eraseToAnyPublisher()
    }
    
    /// Calling `execute(with:)` on the action serves to immediately form the connection and the underlying subscription to perform the work, allowing for the subscriber to be notified of any errors encountered. Any Errors received will be published on the `Main` thread.
    public func execute(with subscriber: Subscribers.ErrorSubscription) {
        kernel.subscribeTo(connection(errorSubscription: subscriber))
    }
    
    /// Calling `execute()` on the action serves to immediately form the connection and the underlying subscription to perform the work, ignoring any errors that might result from the connection.
    public func execute() {
        kernel.subscribeTo(connector.connect())
    }
}
