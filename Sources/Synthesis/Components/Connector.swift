import Combine
import Foundation

/*
 noun: a thing which links two or more things together

 These objects are responsible for connecting outside sources to a subscription via a publisher
 
 For example: we might have a connector that can publish the results of a URL data request.
 
 struct URLConnector: Connector {
     typealias Element = Data
     
     let session: URLSession
     
     func connect() -> Output {
         session
             .dataTaskPublisher(for: URL(string: "https://foobar.bar")!)
             .map(\.data)
             .map { Optional<Data>($0) }
             .mapError { $0 }
             .eraseToAnyPublisher()
     }
 }
 */
protocol Connector {
    typealias Output = AnyPublisher<Element?, Error>
    
    associatedtype Element
    
    func connect() -> Output
}
