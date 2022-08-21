import XCTest
@testable import SimpleMock

final class SimpleMockTests: XCTestCase {
    
    lazy var id = "Test ID"
    lazy var serviceMock = ServiceMock()
    
    func testEmptyExpect() throws {
        
        XCTAssertThrowsError(try serviceMock.load(id), "Should throw resolverEmpty error") { error in
            
            XCTAssertEqual(error as? MockError, MockError.resolverEmpty)
        }
        
        try serviceMock.verify()
        
    }
    
    func testOneMockExpectation() throws {
        
        try serviceMock.expect(method: .load(self.id)) { 0 }
        
        XCTAssertEqual(try serviceMock.load(self.id), 0)
        
        try self.serviceMock.verify()
    }
    
    func testSequenceMockExpectation() throws {
        
        try serviceMock.expect(method: .load(self.id)) { 0 }
        
        try serviceMock.expect(method: .save(self.id, 10)) { Void() }
        try serviceMock.expect(method: .load(self.id), after: .save(self.id, 10)) { 10 }
        
        XCTAssertEqual(try serviceMock.load(self.id), 0)
        try serviceMock.save(self.id, 10)
        XCTAssertEqual(try serviceMock.load(self.id), 10)
        
        try self.serviceMock.verify()
    }
    
    func testSequenceMockExpectationWithError() throws {
        
        try serviceMock.expect(method: .load(self.id)) { 0 }
        
        try serviceMock.expect(method: .save(self.id, 10)) { Void() }
        try serviceMock.expect(method: .load(self.id), after: .save(self.id, 10)) { 10 }
        
        XCTAssertEqual(try serviceMock.load(id), 0)
        XCTAssertThrowsError(try serviceMock.save(id, 40))
        XCTAssertThrowsError(try serviceMock.load(self.id))
        
        XCTAssertThrowsError(try self.serviceMock.verify())
    }
    
    func testMockExpectationWithCastTypeError() throws {
        
        try serviceMock.expect(method: .load(self.id)) { true }
        
        XCTAssertThrowsError(try serviceMock.load(id)) { error in
            
            XCTAssertEqual(error as? MockError, .invalidCastType)
        }
        
        XCTAssertThrowsError(try self.serviceMock.verify())
    }
    
    func testWhenExpectationDidNotFoundAfterValidMethod() throws {
        
        try self.serviceMock.expect(method: .save(id, 1)) { 1 }
        XCTAssertThrowsError(try self.serviceMock.expect(method: .load(id), after: .save(id, 10)) { 1 }) { error in
            
            let loadMethod = ServiceMock.Methods.load(id)
            let afterInvalidMethod = ServiceMock.Methods.save(id, 10)
            
            XCTAssertEqual(error as? MockError, .couldNotAddInSequence(loadMethod, afterInvalidMethod))
        }
    }
}
