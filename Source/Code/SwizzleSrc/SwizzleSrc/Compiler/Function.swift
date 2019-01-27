//
//  Function.swift
//  
//
//  Created by Ethan Uppal on 1/9/19.
//

import Foundation

public struct Function {
    public let params: [String]
    public let body: [Instruction]
    public let vm: VM
    public let env: Environment
    public func call(withValues vals: [Any]) throws -> Any? {
        let scopeTable = Dictionary(uniqueKeysWithValues: zip(params, vals))
        let bodyEnv = Environment(table: scopeTable, parent: self.env)
        return try vm.evaluate(bytecodeInstructions: body, env: bodyEnv)
    }
}
