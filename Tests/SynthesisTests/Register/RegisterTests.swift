import Combine
@testable import Synthesis
import XCTest

final class RegisterTests: XCTestCase {
    
    var subscriptions = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
        try super.tearDownWithError()
    }
    
    func testRegisterUpdate() {
        let expectation = XCTestExpectation(description: "Update Register with Value Should Publish Update")
        let register: Register<Int> = Register()
        let expectedOutput = [1]
        
        register
            .publisher
            .dropFirst()
            .sink(receiveValue: { output in
                XCTAssertEqual(output, expectedOutput)
                expectation.fulfill()
            })
            .store(in: &subscriptions)
        
        register.updateRegister(withElement: 1)
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testRegisterUpdatesExistingValue() {
        let expectation = XCTestExpectation(description: "Update Register with a Update to Existing Value Should Publish Update")
        let register: Register<TestRegistryItem> = Register()
        var item = TestRegistryItem(value: 1)
        register.updateRegister(withElement: item)
        let expectedOutputValue = 2
        
        register
            .publisher
            .filter { !$0.isEmpty }
            .dropFirst()
            .map { $0.first }
            .sink(receiveValue: { output in
                XCTAssertEqual(output?.value, expectedOutputValue)
                expectation.fulfill()
            })
            .store(in: &subscriptions)
        
        item.value = 2
        register.updateRegister(withElement: item)
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testRemovingItemFromRegister() {
        let expectation = XCTestExpectation(description: "Removing an Item from the Register will Publish Update")
        let register: Register<Int> = Register()
        let number = 2
        register.updateRegister(withElement: number)
        let expectedOutputValue = Array<Int>()
        
        register
            .publisher
            .dropFirst()
            .sink(receiveValue: { output in
                XCTAssertEqual(output, expectedOutputValue)
                expectation.fulfill()
            })
            .store(in: &subscriptions)
        
        register.removeFromRegister(element: number)
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testClearingRegistry() {
        let expectation = XCTestExpectation(description: "Clearing Registry Empties Registry Items")
        let register: Register<Int> = Register()
        register.updateRegister(withElement: 1)
        register.updateRegister(withElement: 2)
        register.updateRegister(withElement: 3)
        register.updateRegister(withElement: 4)
        let expectedOutputValue = Array<Int>()
        
        register
            .publisher
            .dropFirst()
            .sink(receiveValue: { output in
                XCTAssertEqual(output, expectedOutputValue)
                expectation.fulfill()
            })
            .store(in: &subscriptions)
        
        register.clearRegistry()
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testFindingItem() throws {
        let register: Register<Int> = Register()
        register.updateRegister(withElement: 1)
        register.updateRegister(withElement: 2)
        let expectedOutput = 2
        
        let output = try register.findRegistryItem(matching: 2)
        XCTAssertEqual(output, expectedOutput)
    }
    
    func testFindingItemError() {
        let register: Register<Int> = Register()
        register.updateRegister(withElement: 1)
        register.updateRegister(withElement: 2)
        XCTAssertThrowsError(try register.findRegistryItem(matching: 3))
    }
    
    func testFindingItemMatching() throws {
        let register: Register<Int> = Register()
        register.updateRegister(withElement: 1)
        register.updateRegister(withElement: 2)
        let expectedOutput = 2
        
        let output = try register.findRegistryItem(byMatching: { $0 == 2 })
        XCTAssertEqual(output, expectedOutput)
    }
    
    func testFindingItemMatchingError() {
        let register: Register<Int> = Register()
        register.updateRegister(withElement: 1)
        register.updateRegister(withElement: 2)
        register.updateRegister(withElement: 3)
        register.updateRegister(withElement: 4)
        // Criteria will error because more than a single matching item can be found
        XCTAssertThrowsError(try register.findRegistryItem(byMatching: { $0 % 2 == 0 }))
    }
    
    func testRegistryContainsItem() {
        let register: Register<Int> = Register()
        register.updateRegister(withElement: 1)
        let expectedOutput = true
        XCTAssertEqual(register.contains(byMatching: { $0 == 1 }), expectedOutput)
    }
    
    func testIsEmptyValues() {
        let register: Register<Int> = Register()
        XCTAssertTrue(register.isEmpty)
        register.updateRegister(withElement: 1)
        XCTAssertFalse(register.isEmpty)
    }
}

fileprivate struct TestRegistryItem: Hashable {
    var value: Int
    let id: UUID = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(_ lhs: TestRegistryItem, _ rhs: TestRegistryItem) -> Bool {
        lhs.id == rhs.id
    }
}
