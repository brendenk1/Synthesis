import Combine
@testable import Synthesis
import XCTest

final class KernelTests: XCTestCase {
    
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
    
    func testKernelPublishesUpdates() {
        let expectation = XCTestExpectation(description: "The Kernel should publish updates from connections")
        let publisher = Just(Optional<Bool>(true)).setFailureType(to: Error.self)
        
        kernel
            .whenValueUpdates()
            .filter { $0 == true }
            .sink(receiveValue: { _ in
                expectation.fulfill()
            })
            .store(in: &subscriptions)
        
        kernel.subscribeTo(publisher)
        wait(for: [expectation], timeout: 0.1)
    }
}
