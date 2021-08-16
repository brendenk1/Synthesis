import Combine
import Foundation

/*
 noun: a system that controls or organizes processes

 These objects represent formatted values for presentation
 
 The Manager instances are designed to be interfaces for UI presentation. Any values published by the instance will be on the `DispatchQueue.Main`.
 
 For example: suppose there is a view interested in presenting localized dates, the view can observe the `value` property of the Manager.
 
 let manager: Manager<String> = Manager()
 manager.whenFormattedValueReceived(from: someFormatter)
 */

public final class Manager<V>: ObservableObject
where V: Equatable,
      V: Identifiable
{
    public typealias Source = AnyPublisher<V?, Never>
    
    @Published public private(set) var value: V?
    
    public func whenFormattedValueReceived(from source: Source) {
        source
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: &$value)
    }
}
