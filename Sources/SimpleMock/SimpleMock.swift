//
//  SimpleMock.swift
//
//
//  Created by Victor C Tavernari on 21/08/2022.
//

import Foundation

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
///     var methodsResolvers: [[Methods] : () -> Any] = [:]
///     var methodsExpected: [[Methods]] = []
///     var methodsRegistered: [[Methods]] = []
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
    
    /// Callback that will be called when some method has to resolve the return value
    typealias Resolver = () -> Any
    
    /// Will store all expected sequences of methods.
    /// It is necessary because the default implementation works correctly.
    var methodsExpected: [[Methods]] { get set }
    
    /// Will store all resolvers that will return what was expected.
    /// It is necessary because the default implementation works correctly.
    var methodsResolvers: [[Methods]: Resolver] { get set }
    
    /// Will store all methods that was called by resolve function
    /// It is necessary because the default implementation works correctly.
    var methodsRegistered: [[Methods]] { get set }
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
    /// When some unexpected method was called
    case unexpectedMethod(AnyHashable)
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
resolver: @escaping () -> Result = { Void() }) throws -> Self {
        
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
            
            throw MockError.couldNotAddInSequence(method, after)
        }
        
        return self
    }
    
    private func result<R>(sequence: [Methods]) throws -> R {
        
        guard let resolver = self.methodsResolvers[sequence] else {
            
            throw MockError.resolverEmpty
        }
        
        guard let result = resolver() as? R else {
        
            throw MockError.invalidCastType
        }
        
        return result
    }
    
    
    /// It only should be called by the respective method
    /// - Parameter method: name of the method
    /// - Returns: return what was implemented on the expectation resolver
    func resolve<R>(method: Methods) throws -> R {
        
        var sequence = [method]
        
        if let lastRegistered = self.methodsRegistered.last {
            
            sequence = lastRegistered + [method]
        }
        
        guard let result: R = try? self.result(sequence: sequence) else {
            
            let sequence = [method]
            
            self.methodsRegistered.append(sequence)
            
            let result: R = try self.result(sequence: sequence)
            
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
    @discardableResult func verify() throws -> Bool {
        
        return try self.methodsExpected.allSatisfy { sequence in
            
            guard self.methodsRegistered.contains(where: { $0 == sequence}) else {
                
                throw MockError.missingExpected(sequence)
            }
            
            return true

        } && self.methodsRegistered.allSatisfy { sequence in
            
            guard self.methodsExpected.contains(where: { $0 == sequence}) else {
                
                throw MockError.unexpectedMethod(sequence)
            }
            
            return true
        }
    }
}
