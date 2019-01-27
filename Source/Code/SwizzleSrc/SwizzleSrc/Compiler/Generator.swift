//
//  Generator.swift
//  SwizzleSrc
//
//  Created by Ethan Uppal on 1/22/19.
//  Copyright © 2019 Ethan Uppal. All rights reserved.
//

import Foundation

public final class Generator: Visitor {
    let statements: UnsafeMutablePointer<Statement>
    let count: Int
    
    public init(statements: [Statement]) {
        self.count = statements.count
        self.statements = .allocate(capacity: count)
        initialize(from: statements)
    }
    
    func initialize(from stmts: [Statement]) {
        for index in 0 ..< count {
            statements[index] = stmts[index]
        }
    }
    
    let cache = NSCache<AnyObject, AnyObject>()
    func makeIR(result: inout Result) throws {
        if let ir = cache.object(forKey: "ir" as NSString) as? Result {
            result = ir
        } else {
            for index in 0 ..< count {
                result.append([try statements[index].accept(self)])
            }
            cache.setObject(result as AnyObject, forKey: "ir" as NSString)
        }
    }
}

public extension Generator {
    enum Error: Swift.Error {
        case notImplemented
    }
    
    public func visit(_ strct: StructStatement) throws -> [Any] {
        throw Error.notImplemented
    }
    
    public func visit(_ decl: DeclarationStatement) throws -> [Any] {
        throw Error.notImplemented
    }
    
    public func visit(_ ref: ReferenceStatement) throws -> [Any] {
        throw Error.notImplemented
    }
    
    public func visit(_ access: AccessStatement) throws -> [Any] {
        throw Error.notImplemented
    }
    
    public func visit(_ call: CallStatement) throws -> [Any] {
        return [call.name.lexme, [try call.args.map { try $0.accept(self) }]]
    }
    
    public func visit(_ assign: AssignStatement) throws -> [Any] {
        return [assign.decl.lexme, assign.name.lexme, try assign.value.accept(self)]
    }
    
    public func visit(_ expr: Expression) throws -> [Any] {
        switch expr.rep {
        case .access(let access):
            return try access.accept(self)
        case .call(let call):
            return try call.accept(self)
        case .bool(let value as Any), .float(let value as Any), .string(let value as Any), .int(let value as Any):
            return [value]
        case .token(let token):
            return [token.lexme]
        case .expr(let expr):
            return try expr.accept(self)
        }
    }
    
    public func visit(_ constr: InitStatement) throws -> [Any] {
        throw Error.notImplemented
    }
    
    public func visit(_ set: SetStatement) throws -> [Any] {
        throw Error.notImplemented
    }
    
    public func visit(_ funct: FunctionStatement) throws -> [Any] {
        return ["func", funct.name.lexme, try funct.args.map { try $0.accept(self) }, try funct.body.map { try $0.accept(self) }]
    }
    
    public func visit(_ arg: ParameterStatement) throws -> [Any] {
        return [arg.name.lexme]
    }
    
    public func visit(_ binary: BinaryExpression) throws -> [Any] {
        return [binary.op.lexme, try binary.lhs.accept(self), try binary.rhs.accept(self)]
    }
    
    public func visit(_ cond: IfStatement) throws -> [Any] {
        return ["if", try cond.condition.accept(self), try cond.ifTrue.map { try $0.accept(self) }, try cond.ifFalse.map { try $0.accept(self) }]
    }
    
    public func visit(_ alias: TypeAliasStatement) throws -> [Any] {
        throw Error.notImplemented
    }
    
    public func visit(_ proto: ProtocolStatement) throws -> [Any] {
        throw Error.notImplemented
    }
    
    public func visit(_ extend: ExtensionStatement) throws -> [Any] {
        throw Error.notImplemented
    }
    
    public func visit(_ inter: InternalReferenceStatement) throws -> [Any] {
        throw Error.notImplemented
    }
    
    public func visit(_ impr: ImportStatement) throws -> [Any] {
        throw Error.notImplemented
    }
    
    public func visit(_ protoMeth: MethodPrototypeStatement) throws -> [Any] {
        throw Error.notImplemented
    }
}


