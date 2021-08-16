import Combine
@testable import Synthesis
import XCTest

final class ManagerTests: XCTestCase {
    
    var manager: Manager<Bool>!
    var subscriptions = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        self.manager = Manager()
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        self.manager = nil
        self.subscriptions.forEach { $0.cancel() }
        self.subscriptions.removeAll()
        try super.tearDownWithError()
    }
    
    func testManagerPublishedValues() {
        let expectation = XCTestExpectation(description: "The manager should publish updates from sources")
        let publisher = Just(Optional<Bool>(true)).eraseToAnyPublisher()
        
        manager
            .$value
            .filter { $0 == true }
            .sink(receiveValue: { value in
                expectation.fulfill()
            })
            .store(in: &subscriptions)
        
        manager.whenFormattedValueReceived(from: publisher)
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testManagerPublishesUniqueValues() {
        let expectation = XCTestExpectation(description: "The manager should publish unique values from sources")
        let publisher = [nil, true, true, false, true, false, false, true].publisher.eraseToAnyPublisher()
        let expectedOutput: [Bool?] = [true, false, true, false, true]
        
        manager
            .$value
            .filter { $0 != nil }
            .collect(5)
            .sink(receiveValue: { output in
                XCTAssertEqual(output, expectedOutput)
                expectation.fulfill()
            })
            .store(in: &subscriptions)
        
        manager.whenFormattedValueReceived(from: publisher)
        wait(for: [expectation], timeout: 0.1)
    }
}

extension Bool: Identifiable {
    public var id: Bool {
        self
    }
}
