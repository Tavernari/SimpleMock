//
//  Array+ensureAllElementsAreContainedIn.swift
//  
//
//  Created by Victor C Tavernari on 13/08/2023.
//

import Foundation

public extension Array where Element: Equatable {
    func ensureAllElementsAreContainedIn(_ otherArray: [Element], errorGenerator: (Element) -> Error) throws {
        for element in self {
            if !otherArray.contains(element) {
                throw errorGenerator(element)
            }
        }
    }
}
