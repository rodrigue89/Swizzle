//
//  Any+Equality.swift
//  
//
//  Created by Ethan Uppal on 1/9/19.
//

import Foundation

public func isEqual<T: Equatable>(_ lhs: Any, rhs: T) -> Bool {
    return (lhs as? T) == rhs
}
