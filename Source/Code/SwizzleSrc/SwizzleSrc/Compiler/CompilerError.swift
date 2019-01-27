//
//  Error.swift
//  
//
//  Created by Ethan Uppal on 1/9/19.
//

import Foundation

public struct CompilerError: Swift.Error, CustomStringConvertible {
    public let description: String
    public let context: Any?
    public var localizedDescription: String {
        if let ctx = context {
            return "\(description) (ctx: \(ctx))"
        } else {
            return description
        }
    }
}
