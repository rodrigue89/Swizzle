//
//  VM.swift
//  
//
//  Created by Ethan Uppal on 1/9/19.
//

import Foundation

public final class VM {
    public init() {
        
    }
    func popVal(_ stack: inout Stack<Any>) throws -> Any {
        guard let top = stack.pop() else {
            throw CompilerError(description: "Not enough values on stack", context: stack)
        }
        return top
    }
    func stringify(_ val: Any) throws -> String {
        guard let str = (val as? CustomStringConvertible)?.description else {
            throw CompilerError(description: "Could not form string from value", context: val)
        }
        return str
    }
    func intify(_ val: Any) throws -> Int {
        guard let int = val as? Int else {
            throw CompilerError(description: "Could not form integer from value", context: val)
        }
        return int
    }
    public func evaluate(bytecodeInstructions code: [Instruction], env: Environment) throws -> Any? {
        var programCounter = 0
        let length = code.count
        var stack = Stack<Any>()
        while programCounter < length {
            let instruction = code[programCounter]
            let opcode = instruction.opcode
            programCounter += 1
            switch opcode {
            case .loadConst:
                stack.push(instruction.arg)
            case .makeName:
                let val = try popVal(&stack)
                let name = try stringify(instruction.arg)
                guard !env.isDefined(name: name) else {
                    throw CompilerError(description: "Variable already defined", context: name)
                }
                env.define(name: name, value: val)
            case .storeName:
                let val = try popVal(&stack)
                let name = try stringify(instruction.arg)
                guard env.isDefined(name: name) else {
                    throw CompilerError(description: "Undefined variable", context: name)
                }
                env.define(name: name, value: val)
            case .loadName:
                let val = try env.lookup(name: try stringify(instruction.arg))
                stack.push(val)
            case .callFunction:
                let numberOfArgs: Int = try intify(instruction.arg)
                let arguments: [Any] = (0 ..< numberOfArgs).compactMap { _ in
                    return stack.pop()
                    }.reversed()
                let function = try popVal(&stack)
                if let fn = function as? ([Any]) throws -> Any {
                    stack.push(try fn(arguments))
                } else if let fn = function as? Function {
                    if let r = try fn.call(withValues: arguments) {
                        stack.push(r)
                    }
                } else {
                    throw CompilerError(description: "Undefined function", context: nil)
                }
            case .relativeJump:
                programCounter += try intify(instruction.arg)
            case .relativeJumpIfTrue:
                let cond = try intify(try popVal(&stack))
                if cond == 1 {
                    programCounter += try intify(instruction.arg)
                } else if cond != 0 {
                    throw CompilerError(description: "Unknown boolean condition", context: cond)
                }
            case .makeFunction:
                let numberOfArgs = try intify(instruction.arg)
                guard let body = try popVal(&stack) as? [Instruction] else {
                    throw CompilerError(description: "Expected body", context: nil)
                }
                guard let params = try popVal(&stack) as? [String] else {
                    throw CompilerError(description: "Expected parameters", context: nil)
                }
                guard params.count == numberOfArgs else {
                    throw CompilerError(description: "Arity mismatch", context: params)
                }
                let fn = Function(params: params, body: body, vm: self, env: env)
                stack.push(fn)
            default:
                throw CompilerError(description: "Unexpected operation code", context: opcode)
            }
        }
        return stack.pop()
    }
}
