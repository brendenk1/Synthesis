# Synthesis

noun: The combination of ideas to form a theory or system.

After working with Apple's native frameworks Combine and SwiftUI, several different state and data flow ideas have been suggested and tried. 

Two main objectives to this system:
* Single source of truth over time
* Consistent, reliable data flow

While nothing here is novel, it is a selection of various approaches distilled to a single method.

## Components

* Action 

noun: the fact or process of doing something, typically to achieve an aim

These objects are responsible for connecting a Kernel to a Connector object

* Connector 

noun: a thing which links two or more things together

 These objects are responsible for connecting outside sources to a subscription via a publisher

* ErrorSubscription

_subscription_ noun: the action of making or agreeing to make an advance payment in order to receive something

This specialized Subscription is a part of `Combine.Subscribers` that allow for the receipt of errors

* Format

noun: a defined structure for the processing or display of data

These objects provide definitions on how to present data 

* Kernel

noun: the most basic level or core

These objects represent the source of truth over time

* Manager 

noun: a system that controls or organizes processes

These objects represent formatted values for presentation

## Diagram
```
+-------------------------------------------------------------------------+
|                                                                         |
|                                                                         |
|                                     +--------------------- UI           |
|                                     |                      ^            |
|                                     |                      |            |
|                                     +--------------------- Manager      |
|                                     |                      ^            |
|                                     v                      |            |
|                                   Action                   Format       | 
|                                     |                      ^            |
|                                     v                      |            |
|       Outside Sources ----------> Connector -------------> Kernel       |
|                                                                         |
|                                                                         |
|                                                                         |
+-------------------------------------------------------------------------+
```

## Connectors

* SetValueConnector

 A default connect suitable for setting a value on a `Kernel` instance.

## Register

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

## Logic Gate

_logic_ noun: a system or set of principles underlying the arrangements of elements in a computer or electronic device so as to perform a specified task.

This object is used to codify a method to evaluate a condition based on a `Bool` and then perform a given output based on that condition.

For example:

```
let trueCondition = { value in
    /// When true perform this
}

let falseCondition = { value in
    /// When false perform this
}

let gate: LogicGate<Int> = LogicGate(condition: some conditional method,
                                     trueCondition: trueCondition,
                                     falseCondition: falseCondition)
gate.evaluate(1)
/// The gate will evaluate the input and perform the specified method based on the condition
```

In addition a logic gate publisher has been provided that can be used in a publisher chain.

For example:

```
let trueCondition: (Int) -> AnyPublisher<Bool, Error> = { _ in
    Just(true)
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
}
let falseCondition: (Int) -> AnyPublisher<Bool, Error> = { _ in
    Just(false)
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
}

Just(1)
    .setFailureType(to: Error.self)
    .logicGatePublisher(condition: { $0 != 1 },
                        trueCondition: trueCondition,
                        falseCondition: falseCondition)
    .sink(receiveCompletion: { _ in },
          receiveValue: { output in
        XCTAssertFalse(output)
        expectation.fulfill()
    })
    .store(in: &subscriptions)
```
