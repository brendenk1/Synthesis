import Combine
@testable import Synthesis
import XCTest

final class SetValueConnectorTests: XCTestCase {
    
    var subscriptions = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
        try super.tearDownWithError()
    }
    
    func testSetValueConnector() {
        let expectation = XCTestExpectation(description: "Set Value Connector Should Update Kernel")
        let kernel: Kernel<Bool> = Kernel()
        let expectedOutput = true
        
        kernel
            .whenValueUpdates()
            .dropFirst()
            .sink(receiveValue: { output in
                XCTAssertEqual(output, expectedOutput)
                expectation.fulfill()
            })
            .store(in: &subscriptions)
        
        Action(connector: SetValueConnector(value: true),
               kernel: kernel)
            .execute()
        
        wait(for: [expectation], timeout: 0.1)
    }
}
