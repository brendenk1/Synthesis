import Combine
@testable import Synthesis
import XCTest

final class ActionTests: XCTestCase {
    
    var kernel: Kernel<Bool>!
    var subscriptions = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        self.kernel = Kernel()
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        self.kernel = nil
        self.subscriptions.forEach { $0.cancel() }
        self.subscriptions.removeAll()
        try super.tearDownWithError()
    }
    
    func testActionConnectsToKernel() {
        let expectation = XCTestExpectation(description: "The Kernel should publish updates from connections")
        let action = Action(connector: TestConnector(shouldError: false), kernel: kernel)
        
        kernel
            .whenValueUpdates()
            .filter { $0 == true }
            .sink(receiveValue: { _ in
                expectation.fulfill()
            })
            .store(in: &subscriptions)
        
        action.execute()
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testActionPublishesError() {
        let expectation = XCTestExpectation(description: "The Action should publish an error if needed")
        let action = Action(connector: TestConnector(shouldError: true), kernel: kernel)
        
        kernel
            .whenValueUpdates()
            .filter { $0 == true }
            .sink(receiveValue: { _ in
                XCTFail("Kernel should still be nil")
            })
            .store(in: &subscriptions)
        
        action.execute(with: Subscribers.ErrorSubscription(onError: { _ in
            expectation.fulfill()
        }))
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    struct TestConnector: Connector {
        let shouldError: Bool
        
        typealias Element = Bool
        
        func connect() -> Output {
            switch shouldError {
            case true:
                return Fail(error: TestError.error)
                    .eraseToAnyPublisher()
            case false:
                return Just(true)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
        }
    }
    
    enum TestError: Error {
        case error
    }
}
