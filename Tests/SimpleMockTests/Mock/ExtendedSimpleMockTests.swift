//
//  ExtendedSimpleMockTests.swift
//  
//
//  Created by Victor C Tavernari on 13/08/2023.
//

import Foundation
import XCTest
@testable import SimpleMock

final class ExtendedSimpleMockTests: XCTestCase {

    var serviceMock: ServiceMock!
    let id = "Test ID"

    override func setUp() {
        super.setUp()
        serviceMock = ServiceMock()
    }

    func testExpectationSetButNotCalled() throws {
        try serviceMock.expect(method: .load(id)) { 10 }
        XCTAssertThrowsError(try serviceMock.verify())
    }

    func testMultipleExpectationsForSameMethodDifferentArgs() throws {
        try serviceMock.expect(method: .save(id, 10))
        try serviceMock.expect(method: .save(id, 20))
        try serviceMock.expect(method: .save(id, 30))

        try serviceMock.save(id, 10)
        try serviceMock.save(id, 20)
        try serviceMock.save(id, 30)

        XCTAssertNoThrow(try serviceMock.verify())
    }

    func testExpectationsWithUnfollowedSequence() throws {
        do {
            try serviceMock.expect(method: .load(id)) { 0 }
            try serviceMock.expect(method: .save(id, 10))
            try serviceMock.expect(method: .load(id), after: .save(id, 10)) { 10 }

            let value1 = try serviceMock.load(id)
            XCTAssertEqual(value1, 0)
            let value2 = try serviceMock.load(id)
            XCTAssertEqual(value2, 10)  // This breaks the sequence
            XCTAssertThrowsError(try serviceMock.save(id, 10))
            XCTAssertThrowsError(try serviceMock.verify())
        } catch {

            XCTAssertEqual(error as? MockError, MockError.resolverEmpty)
        }
    }
}
