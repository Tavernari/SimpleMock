//
//  File.swift
//  
//
//  Created by Victor C Tavernari on 13/08/2023.
//

import Foundation
import XCTest
@testable import SimpleMock

final class ExtendedActorMockTests: XCTestCase {

    var actorServiceMock: ActorServiceMock!
    let id = "Test ID"

    override func setUp() {
        super.setUp()
        actorServiceMock = ActorServiceMock()
    }

    func testConcurrentExpectationsDifferentMethods() async throws {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { [self] in
                try! await actorServiceMock.expect(method: .load(self.id)) { 10 }
            }
            group.addTask { [self] in
                try! await actorServiceMock.expect(method: .save(self.id, 10))
            }
        }
        let value = try await actorServiceMock.load(id)
        XCTAssertEqual(value, 10)
        try await actorServiceMock.save(id, 10)
        try await actorServiceMock.verify()
    }

    func testConcurrentExpectationsSameMethodDifferentArgs() async throws {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { [self] in
                try! await actorServiceMock.expect(method: .save(self.id, 10))
            }
            group.addTask { [self] in
                try! await actorServiceMock.expect(method: .save(self.id, 20))
            }
            group.addTask { [self] in
                try! await actorServiceMock.expect(method: .save(self.id, 30))
            }
        }
        try await actorServiceMock.save(id, 10)
        try await actorServiceMock.save(id, 20)
        try await actorServiceMock.save(id, 30)
        try await actorServiceMock.verify()
    }

    func testUnfollowedSequenceInConcurrency() async throws {
        do {
            try await actorServiceMock.expect(method: .load(id)) { 0 }
            try await actorServiceMock.expect(method: .save(id, 10))
            try await actorServiceMock.expect(method: .load(id), after: .save(id, 10)) { 10 }
            
            let value1 = try await actorServiceMock.load(id)
            XCTAssertEqual(value1, 0)
            let value2 = try await actorServiceMock.load(id)
            XCTAssertEqual(value2, 10)  // This breaks the sequence
            try await actorServiceMock.save(id, 10)
            try await actorServiceMock.verify()
        } catch {

            XCTAssertEqual(error as! ActorMockError, ActorMockError.resolverEmpty)
        }
    }
}
