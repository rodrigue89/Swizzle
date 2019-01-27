//
//  Compiler.swift
//  
//
//  Created by Ethan Uppal on 1/9/19.
//

import Foundation

public final class Compiler {
    public static func compile(exp: Any) throws -> [Instruction] {
        switch exp {
        case let int as Int:
            return [loadConst(int)]
        case let array as [Any]:
            if let arrays = array as? [[Any]] {
                return try arrays.reduce(into: [Instruction]()) {
                    $0 += try compile(exp: $1)
                }
            }
            guard !array.isEmpty else {
                throw CompilerError(description: "Cannot compile an empty expression", context: array)
            }
            if isEqual(array[0], rhs: "var") {
                guard array.count == 3 else {
                    throw CompilerError(description: "Expected 3 elements in value expression", context: array)
                }
                let name = array[1]
                let subexp = array[2]
                return try compile(exp: subexp) + [makeName(name)]
            } else if isEqual(array[0], rhs: "set") {
                guard array.count == 3 else {
                    throw CompilerError(description: "Expected 3 elements in value expression", context: array)
                }
                let name = array[1]
                let subexp = array[2]
                return try compile(exp: subexp) + [storeName(name)]
            } else if isEqual(array[0], rhs: "if") {
                guard array.count == 4 else {
                    throw CompilerError(description: "Expected 4 elements in value expression", context: array)
                }
                let cond = try compile(exp: array[1])
                let ifTrueCode = try compile(exp: array[2])
                let ifFalseCode = try compile(exp: array[3]) + [relativeJump(ifTrueCode.count)]
                return cond + [relativeJumpIfTrue(ifFalseCode.count)] + ifFalseCode + ifTrueCode
            }  else if isEqual(array[0], rhs: "closure") {
                guard array.count == 3 else {
                    throw CompilerError(description: "Expected 3 elements in value expression", context: array)
                }
                guard let parameters = array[1] as? [String] else {
                    throw CompilerError(description: "Expected parameters in closure delaration", context: array)
                }
                let body = try compile(exp: array[2])
                return [
                    loadConst(parameters),
                    loadConst(body),
                    makeFunc(parameters.count)
                ]
            } else if isEqual(array[0], rhs: "func") {
                guard array.count == 4 else {
                    throw CompilerError(description: "Expected function parameters and a body", context: array)
                }
                return try compile(exp: ["closure", array[2], array[3]]) + [storeName(array[1])]
            } else {
                let arguments = array[1...]
                let numberOfArgs = arguments.count
                let argCode = try arguments.reduce(into: [Instruction]()) {
                    $0 += try compile(exp: $1)
                }
                return try compile(exp: array[0]) + argCode + [callFunc(numberOfArgs)]
            }
            
            throw CompilerError(description: "The expression provided is not implemeted", context: exp)
        case let str as String:
            return [loadName(str)]
        default:
            throw CompilerError(description: "The expression provided is not implemeted", context: exp)
        }
    }
    public static func test(_ exp: Any, _ expected: [Instruction]) {
        do {
            let result = try compile(exp: exp)
            assert(result == expected)
        }
        catch {
            assertionFailure("\(error)")
        }
    }
}
