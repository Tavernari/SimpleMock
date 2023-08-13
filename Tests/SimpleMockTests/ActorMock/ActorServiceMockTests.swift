//
//  ActorServiceMockTests.swift
//  
//
//  Created by Victor C Tavernari on 13/08/2023.
//

import XCTest
import SimpleMock

final class ActorServiceMockTests: XCTestCase {

    var serviceMock: ActorServiceMock!
    let id = "Test ID"

    override func setUp() {
        super.setUp()
        serviceMock = ActorServiceMock()
    }

    func testConcurrentInvocations() async throws {
        let expectation = XCTestExpectation(description: "waiting for async calls")
        expectation.expectedFulfillmentCount = 2
        expectation.assertForOverFulfill = true

        try await serviceMock.expect(method: .load(id)) { 10 }
        try await serviceMock.expect(method: .save(id, 20))

        // Concurrently invoking the methods
        await withTaskGroup(of: Void.self) { group in
            group.addTask { [self] in
                let value = try? await serviceMock.load(self.id)
                XCTAssertEqual(value, 10)
                expectation.fulfill()
            }
            group.addTask { [self] in
                try? await serviceMock.save(self.id, 20)
                expectation.fulfill()
            }
        }

        try await serviceMock.verify()

        #if swift(>=6.0)
            await self.fulfillment(of: [expectation])
        #else
            self.wait(for: [expectation], timeout: 1)
        #endif

    }

    func testConcurrentExpectations() async throws {
        // Setting up expectations concurrently
        await withTaskGroup(of: Void.self) { group in
            group.addTask { [self] in
                try! await serviceMock.expect(method: .load(self.id)) { 10 }
            }
            group.addTask { [self] in
                try! await serviceMock.expect(method: .save(self.id, 20))
            }
        }

        let value = try await serviceMock.load(id)
        XCTAssertEqual(value, 10)
        try await serviceMock.save(id, 20)
        try await serviceMock.verify()
    }
}

