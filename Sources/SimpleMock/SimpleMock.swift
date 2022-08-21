//
//  SimpleMock.swift
//
//
//  Created by Victor C Tavernari on 21/08/2022.
//

import Foundation
import XCTest


/// Mock is a protocol with generic methods to help the developer to implement it.
/// It demands an Enum to define the processes that should expect.
/// It also needs two collections and one dictionary to save expectations, expectations resolvers, and register methods calls.
///
/// ## Usage
///
/// When conform the protocol Mock, it need to create an Enum Methods to represent the class public methods that will called by the system under test.
///
/// ### Example
///
/// Imagine a `Service` protocol that will be injected into some object.
/// ```swift
/// protocol Service {
///
///     func save(_ id: String, _ value: Int) throws
///     func load(_ id: String) throws -> Int
/// }
/// ```
///
/// If `Service` needs a mock, it should be implemented like this:
/// ```swift
/// class ServiceMock: Service, Mock {
///
///     // Enum that represents all available
///     // functions on the `Service`
///     enum Methods: Hashable {  protocol
///
///         case save(_ id: String, _ value: Int)
///         case load(_ id: String)
///     }
///
///     var resolvers: [[Methods] : () -> Any] = [:]
///     var expecteds: [[Methods]] = []
///     var registered: [[Methods]] = []
///
///     func save(_ id: String, _ value: Int) throws {
///
///         // It should call resolve passing the case
///         // from the `Methods` enum.
///         // Even the save expect Void as return, you
///         // should add return to resolve identify the
///         // type Void.
///         return try self.resolve(method: .save(id, value))
///     }
///
///     func load(_ id: String) throws -> Int {
///
///         // It should call resolve passing the case
///         // from the `Methods` enum
///         return try self.resolve(method: .load(id))
///     }
/// }
/// ```
public protocol Mock: AnyObject {
    
    /// Represents the Enum that will contains all methods reference to be expected.
    associatedtype Methods: Hashable
    
    /// Will store all expected sequences of methods.
    /// It is necessary because the default implementation works correctly.
    var expecteds: [[Methods]] { get set }
    
    /// Will store all resolvers that will return what was expected.
    /// It is necessary because the default implementation works correctly.
    var resolvers: [[Methods]: () -> Any] { get set }
    
    /// Will store all methods that was called by resolve function
    /// It is necessary because the default implementation works correctly.
    var registered: [[Methods]] { get set }
}


/// All error available when interact with the `Mock` implementation
public enum MockError: Error, Equatable {
    
    /// When not found a resolver available
    case resolverEmpty
    /// When the resolver implementation returns something different than the expected
    case invalidCastType
    /// When verify, some expectation was not mapped.
    case missingExpected(AnyHashable)
    /// When it try to chain the method with other, but it did not find a last valid method to chain.
    case couldNotAddInSequence(AnyHashable, AnyHashable)
}

public extension Mock {
    
    
    /// Will register all expectations and resolvers
    /// - Parameters:
    ///   - method: expected method
    ///   - after: method that came before the current expected method
    ///   - resolver: the logic that will return some value related to the expected method
    /// - Returns: returns Self
    @discardableResult func expect<Result>(method: Methods,
                        after: Methods? = nil,
                        resolver: @escaping () -> Result) throws -> Self {
        
        if after == nil {
            
            let sequece = [method]
            
            self.expecteds.append(sequece)
            self.resolvers[sequece] = resolver
            
        } else if var lastSequence = self.expecteds.last, lastSequence.last == after {
            
            lastSequence.append(method)
            
            self.expecteds.removeLast()
            self.expecteds.append(lastSequence)
            self.resolvers[lastSequence] = resolver
            
        } else if let after = after {
            
            throw MockError.couldNotAddInSequence(method, after)
        }
        
        return self
    }
    
    
    /// It only should be called by the respective method
    /// - Parameter method: name of the method
    /// - Returns: return what was implemented on the expectation resolver
    func resolve<R>(method: Methods) throws -> R {
        
        let sequence = (self.registered.last ?? []) + [method]
        
        if let result = self.resolvers[sequence]?() as? R {
            
            self.resolvers.removeValue(forKey: sequence)
            
            if sequence.count > 1 {
                
                self.registered.removeLast()
            }
            
            self.registered.append(sequence)
            
            return result
            
        } else {
            
            let sequence = [method]
            
            guard let resolver = self.resolvers[sequence] else {
                
                throw MockError.resolverEmpty
            }
            
            guard let result = resolver() as? R else {
            
                throw MockError.invalidCastType
            }
            
            self.resolvers.removeValue(forKey: sequence)
            self.registered.append(sequence)
            
            return result
        }
    }
    
    
    /// Will check if expectations and resolved is matching as expected
    /// - Returns: Result of this comparsion
    @discardableResult func verify() throws -> Bool {

        try self.expecteds.allSatisfy { sequence in
            
            guard self.registered.contains(where: { $0 == sequence}) else {
                
                throw MockError.missingExpected(sequence)
            }
            
            return true
        }
    }
}
