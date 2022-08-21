//
//  Service.swift
//  
//
//  Created by Victor C Tavernari on 21/08/2022.
//

import Foundation

protocol Service {
    
    func save(_ id: String, _ value: Int) throws
    func load(_ id: String) throws -> Int
}
