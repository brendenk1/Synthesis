import Combine
@testable import Synthesis
import XCTest

final class LogicGateTests: XCTestCase {
    
    var subscriptions = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
        try super.tearDownWithError()
    }
    
    func testTrueCondition() {
        let trueCondition = { value in
            XCTAssertTrue(value == 1)
        }
        
        let falseCondition: LogicGate<Int>.Output = { _ in
            XCTFail("Should evaluate true")
        }
        
        let gate: LogicGate<Int> = LogicGate(condition: { $0 == 1 },
                                             trueCondition: trueCondition,
                                             falseCondition: falseCondition)
        gate.evaluate(1)
    }
    
    func testFalseCondition() {
        let trueCondition: LogicGate<Int>.Output = { _ in
            XCTFail("Should evaluate false")
        }
        
        let falseCondition: LogicGate<Int>.Output = { value in
            XCTAssertTrue(value == 1)
        }
        
        let gate: LogicGate<Int> = LogicGate(condition: { $0 != 1 },
                                             trueCondition: trueCondition,
                                             falseCondition: falseCondition)
        gate.evaluate(1)
    }
    
    func testLogicGatePublisherTrue() {
        let expectation = XCTestExpectation(description: "The evaluation should publish true")
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
            .logicGatePublisher(condition: { $0 == 1 },
                                trueCondition: trueCondition,
                                falseCondition: falseCondition)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { output in
                XCTAssertTrue(output)
                expectation.fulfill()
            })
            .store(in: &subscriptions)
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testLogicGatePublisherFalse() {
        let expectation = XCTestExpectation(description: "The evaluation should publish false")
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
        
        wait(for: [expectation], timeout: 0.1)
    }
}
