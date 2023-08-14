//
//  ActorMock.swift
//
//
//  Created by Victor C Tavernari on 21/08/2022.
//

import Foundation


/// A protocol for setting up and verifying asynchronous method expectations in mocks.
///
/// The `ActorMock` protocol extends the capabilities of the `Mock` class to support concurrency. It provides
/// utilities to asynchronously set up expectations for method calls, register method invocations,
/// and resolve expected return values. Implementing this protocol requires creating an associated `Methods`
/// enumeration to represent the class's public methods that will be called by the system under test.

public protocol ActorMock: AnyObject {

    /// Represents the Enum that will contains all methods reference to be expected.
    associatedtype Methods: Hashable
}


public extension ActorMock {

    var mockLogic: ActorMockLogic { .instance }

    @discardableResult
    func expect<Result>(method: Methods,
                        after: Methods? = nil,
                        resolver: @escaping () async throws  -> Result = { Void() }) async throws -> Self {

        try await self.mockLogic.expect(method: method, after: after, resolver: resolver)
        return self
    }

    func resolve<R>(method: Methods) async throws -> R {

        return try await self.mockLogic.resolve(method: method)
    }

    @discardableResult
    func verify() async throws -> Bool {

        return try await self.mockLogic.verify()
    }
}

public actor ActorMockLogic {

    static let instance = ActorMockLogic()

    typealias Resolver = () async throws -> Any

    /// Will store all expected sequences of methods.
    /// It is necessary because the default implementation works correctly.
    var methodsExpected: [[AnyHashable]] = []

    /// Will store all resolvers that will return what was expected.
    /// It is necessary because the default implementation works correctly.
    var methodsResolvers: [[AnyHashable]: Resolver] = [:]

    /// Will store all methods that was called by resolve function
    /// It is necessary because the default implementation works correctly.
    var methodsRegistered: [[AnyHashable]] = []

    private init() {}
}



/// An enumeration of possible errors that can arise during the asynchronous mocking process.
///
/// These errors provide detailed feedback on issues encountered while setting up, invoking, or verifying mocked methods in a concurrent context.

public enum ActorMockError: Error, Equatable {

    /// When not found a resolver available
    case resolverEmpty
    /// When the resolver implementation returns something different than the expected
    case invalidCastType
    /// When verify, some expectation was not mapped.
    case missingExpected(AnyHashable)
    /// When it try to chain the method with other, but it did not find a last valid method to chain.
    case couldNotAddInSequence(AnyHashable, AnyHashable)
    /// When some unexpected method was called
    case unexpectedMethod(AnyHashable)
}

public extension ActorMockLogic {


    /// Will register all expectations and resolvers
    /// - Parameters:
    ///   - method: expected method
    ///   - after: method that came before the current expected method
    ///   - resolver: the logic that will return some value related to the expected method
    /// - Returns: returns Self
    @discardableResult func expect<Result>(method: AnyHashable,
                                           after: AnyHashable? = nil,
                                           resolver: @escaping () async throws -> Result = { Void() }) throws -> Self {

        if after == nil {

            let sequece = [method]

            self.methodsExpected.append(sequece)
            self.methodsResolvers[sequece] = resolver

        } else if var lastSequence = self.methodsExpected.last, lastSequence.last == after {

            lastSequence.append(method)

            self.methodsExpected.removeLast()
            self.methodsExpected.append(lastSequence)
            self.methodsResolvers[lastSequence] = resolver

        } else if let after = after {

            throw ActorMockError.couldNotAddInSequence(method, after)
        }

        return self
    }

    private func result<R>(sequence: [AnyHashable]) async throws -> R {

        guard let resolver = self.methodsResolvers[sequence] else {

            throw ActorMockError.resolverEmpty
        }

        guard let result = try await resolver() as? R else {

            throw ActorMockError.invalidCastType
        }

        return result
    }


    /// It only should be called by the respective method
    /// - Parameter method: name of the method
    /// - Returns: return what was implemented on the expectation resolver
    func resolve<R>(method: AnyHashable) async throws -> R {

        var sequence = [method]

        if let lastRegistered = self.methodsRegistered.last {

            sequence = lastRegistered + [method]
        }

        guard let result: R = try? await self.result(sequence: sequence) else {

            let sequence = [method]

            self.methodsRegistered.append(sequence)

            let result: R = try await self.result(sequence: sequence)

            self.methodsResolvers.removeValue(forKey: sequence)

            return result
        }

        self.methodsResolvers.removeValue(forKey: sequence)

        if sequence.count > 1 {

            self.methodsRegistered.removeLast()
        }

        self.methodsRegistered.append(sequence)

        return result
    }


    /// Will check if expectations and resolved is matching as expected
    /// - Returns: Result of this comparsion
    @discardableResult
    func verify() throws -> Bool {

        defer {

            self.methodsExpected.removeAll()
            self.methodsResolvers.removeAll()
            self.methodsRegistered.removeAll()
        }

        try methodsExpected.ensureAllElementsAreContainedIn(methodsRegistered, errorGenerator: { MockError.missingExpected($0) })
        try methodsRegistered.ensureAllElementsAreContainedIn(methodsExpected, errorGenerator: { MockError.unexpectedMethod($0) })

        return true
    }
}
