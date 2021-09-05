import Combine
import Foundation

/*
 noun: a location in a store of data, used for a specific purpose and with quick access time

 This object is used to store a collection of unique elements with fast access. Methods are provided to update registry with both new and existing elements, remove elements, clear all elements, and find elements.

 For example:

 ```
 let register: Register<Int> = Register()
 register.updateRegister(withElement: 1)
 register.updateRegister(withElement: 2)

 do {
     let value = try register.findRegistryItem(matching: 2)
 } catch {
     print(error)
 }
 ```
 */
final public class Register<Element>
where Element: Hashable {
    public init() { }
    
    fileprivate let kernel: Kernel<Set<Element>> = Kernel()
}

extension Register {
    /// A publisher that emits the values in the register
    ///
    /// The publisher will emit values on the `Main` thread
    public var publisher: AnyPublisher<Array<Element>, Never> {
        kernel
            .whenValueUpdates()
            .replaceNil(with: Set<Element>())
            .map { Array($0) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// A method to update the registry with an element
    ///
    /// Adding a new element will insert the item into the registry, while an exiting element will be updated to reflect the instance passed in
    public func updateRegister(withElement element: Element) {
        var currentValue = kernel.currentValue ?? Set()
        currentValue.update(with: element)
        Action(connector: SetValueConnector(value: currentValue),
               kernel: kernel)
            .execute()
    }
    
    /// A method to remove an item from the register
    public func removeFromRegister(element: Element) {
        var currentValue = kernel.currentValue
        currentValue?.remove(element)
        Action(connector: SetValueConnector(value: currentValue),
               kernel: kernel)
            .execute()
    }
    
    /// A method to remove all items in the register
    public func clearRegistry() {
        Action(connector: SetValueConnector(value: nil),
               kernel: kernel)
            .execute()
    }
    
    /// A method to find an item in the register
    public func findRegistryItem(matching element: Element) throws -> Element {
        guard let foundElement = kernel
                .currentValue?
                .first(where: { $0 == element })
        else { throw RegisterError.missingRegistryItem(element) }
        return foundElement
    }
    
    /// A method to find an item in the register based on a filter
    ///
    /// The filter will return an ambiguous error if it is unsuccessful or the filter yields more than a single result
    public func findRegistryItem(byMatching filter: (Element) -> Bool) throws -> Element {
        guard let foundElements = kernel
                .currentValue?
                .filter(filter),
              foundElements.count == 1,
              let foundElement = foundElements
                .first
        else { throw RegisterError.registryFilterAmbiguous }
        return foundElement
    }
}

extension Register {
    public enum RegisterError: Error {
        case missingRegistryItem(Element)
        case registryFilterAmbiguous
    }
}
