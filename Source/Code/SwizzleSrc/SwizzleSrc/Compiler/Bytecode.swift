//
//  Bytecode.swift
//  
//
//  Created by Ethan Uppal on 1/9/19.
//

import Foundation

public enum Opcode: Int {
    case loadConst
    case makeName
    case storeName
    case loadName
    case callFunction
    case relativeJumpIfTrue
    case relativeJump
    case makeFunction
}

public struct Instruction: CustomStringConvertible, Equatable {
    let opcode: Opcode, arg: Any
    init(_ opcode: Opcode, arg: Any) {
        self.opcode = opcode
        self.arg = arg
    }
    var _debuggedArg: String {
        return String(reflecting: arg)
    }
    public var description: String {
        return "\(opcode)(\(_debuggedArg))"
    }
    
    public static func == (lhs: Instruction, rhs: Instruction) -> Bool {
        switch (lhs.arg, rhs.arg) {
        case (let lhsArg as CustomStringConvertible, let rhsArg as CustomStringConvertible):
            return (lhs.opcode, lhsArg.description) == (rhs.opcode, rhsArg.description)
        default:
            return false
        }
    }
}

// MARK: Instruction Generation
public typealias InstrMake = (Opcode) -> ((Any) -> Instruction)
public let generator: InstrMake = { opcode in return { (val: Any) -> Instruction in return Instruction(opcode, arg: val)} }

public let loadConst = generator(.loadConst)
public let storeName = generator(.storeName)
public let makeName = generator(.makeName)
public let loadName = generator(.loadName)
public let callFunc = generator(.callFunction)
public let relativeJumpIfTrue = generator(.relativeJumpIfTrue)
public let relativeJump = generator(.relativeJump)
public let makeFunc = generator(.makeFunction)


