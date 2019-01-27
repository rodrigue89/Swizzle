//
//  Struct.swift
//  Swizzle - Compiling
//
//  Created by Ethan Uppal on 1/16/19.
//  Copyright © 2019 Ethan Uppal. All rights reserved.
//

import Foundation

public struct InitializationError: Error {
    public let message: String
    public let context: Any?
}

public struct TypeError: LocalizedError {
    public let given: String
    public let expected: String
    public var errorDescription: String? {
        return "Cannot convert value of type \(given) ro type \(expected)."
    }
}

public enum SwizzleValue {
    case object(SwizzleStruct)
    case string(String)
    case int(Int)
    case float(Float)
    case bool(Bool)
    public var type: String {
        switch self {
        case .object(let obj):
            return obj.type
        case .string: return "String"
        case .int: return "Int"
        case .float: return "Float"
        case .bool: return "Bool"
        default:
            fatalError("Unknown type for case in SwizzleValue.type")
        }
    }
}

extension SwizzleValue: ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral, ExpressibleByStringLiteral, ExpressibleByBooleanLiteral {
    public init(integerLiteral value: Int) {
        self = .int(value)
    }
    public init(floatLiteral value: Float) {
        self = .float(value)
    }
    public init(stringLiteral value: String) {
        self = .string(value)
    }
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

public final class SwizzleStruct {
    public let type: String
    var storage: UnsafeMutablePointer<SwizzleValue>
    let size: Int
    public init(source: StructStatement, parameters: [SwizzleValue]) throws {
        self.size = parameters.count
        self.type = source.name.lexme
        guard size == source.references.count else {
            throw InitializationError(message: "Expected \(size) arguments in initializer for \(type).", context: nil)
        }
        self.storage = UnsafeMutablePointer.allocate(capacity: size)
        for index in 0 ..< size {
            let param = parameters[index]
            storage[index] = param
            let given = source.references[index].type.lexme
            let expected = param.type
            guard given == expected else {
                throw TypeError(given: given, expected: expected)
            }
        }
    }

    public func lookup(index: Int) -> SwizzleValue {
        return storage[index]
    }
    public func modify(index: Int, value: SwizzleValue) {
        storage[index] = value
    }

    deinit {
        storage.deallocate()
    }
}
