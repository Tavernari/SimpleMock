//
//  ServiceMock.swift
//  
//
//  Created by Victor C Tavernari on 21/08/2022.
//

import Foundation
import SimpleMock

class ServiceMock: Service, Mock {
    
    enum Methods: Hashable {
        
        case save(_ id: String, _ value: Int)
        case load(_ id: String)
    }
    
    var methodsResolvers: [[Methods] : Resolver] = [:]
    var methodsExpected: [[Methods]] = []
    var methodsRegistered: [[Methods]] = []
    
    func save(_ id: String, _ value: Int) throws {
        
        return try self.resolve(method: .save(id, value))
    }
    
    func load(_ id: String) throws -> Int {
        
        return try self.resolve(method: .load(id))
    }
}
