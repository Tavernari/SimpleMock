//
//  ActorServiceMock.swift
//
//
//  Created by Victor C Tavernari on 13/08/2023.
//

import Foundation
import SimpleMock


/// An actor-based mock for simulating service operations in a concurrent environment.
///
/// The `ActorServiceMock` actor provides asynchronous methods to simulate the behavior of a service. By conforming
/// to the `ActorMock` protocol, it supports the setting up and verification of method expectations in a concurrent context.
actor ActorServiceMock: ActorMock {

    enum Methods: Hashable {
        case save(_ id: String, _ value: Int)
        case load(_ id: String)
    }

    func save(_ id: String, _ value: Int) async throws {
        return try await self.resolve(method: .save(id, value))
    }

    func load(_ id: String) async throws -> Int {
        return try await self.resolve(method: .load(id))
    }
}
