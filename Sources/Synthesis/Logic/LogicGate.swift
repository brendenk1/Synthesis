import Combine
import Foundation

/*
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
 */
public struct LogicGate<Input> {
    public init(condition: @escaping (Input) -> Bool,
                trueCondition: @escaping LogicGate<Input>.Output,
                falseCondition: @escaping LogicGate<Input>.Output) {
        self.condition = condition
        self.trueCondition = trueCondition
        self.falseCondition = falseCondition
    }
    
    public typealias Output = (Input) -> Void
    
    let condition: (Input) -> Bool
    let trueCondition: Output
    let falseCondition: Output
    
    public func evaluate(_ input: Input) {
        condition(input) ? trueCondition(input) : falseCondition(input)
    }
}

/*
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
 */
extension Publisher {
    public func logicGatePublisher<Input, T, ErrorType>(condition: @escaping (Input) -> Bool,
                                                        trueCondition: @escaping (Input) -> AnyPublisher<T, ErrorType>,
                                                        falseCondition: @escaping (Input) -> AnyPublisher<T, ErrorType>) -> AnyPublisher<T, ErrorType>
    where Input == Output,
          ErrorType == Failure
    {
        self
            .map { input in
                condition(input) ? trueCondition(input) : falseCondition(input)
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}
