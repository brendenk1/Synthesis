import Combine
@testable import Synthesis
import XCTest

final class FormatterTests: XCTestCase {
    
    var subscriptions = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
        try super.tearDownWithError()
    }
    
    func testFormatterExecution() {
        let expectation = XCTestExpectation(description: "The Formatter should publish expected values")
        let formatter = Format<Int, Bool>() { int in return int == 1 }
        let expectedOutput: [Bool] = [false, true]
        let input = [0, 1]
        
        formatter
            .applyFormatting(from: input.publisher)
            .collect()
            .sink(receiveValue: { values in
                XCTAssertEqual(values, expectedOutput)
                expectation.fulfill()
            })
            .store(in: &subscriptions)
        
        wait(for: [expectation], timeout: 0.1)
    }
}
