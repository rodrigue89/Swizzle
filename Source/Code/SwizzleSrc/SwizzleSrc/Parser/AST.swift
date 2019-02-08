//
//  AST.swift
//  Swizzle - Compiling
//
//  Created by Ethan Uppal on 1/13/19.
//  Copyright © 2019 Ethan Uppal. All rights reserved.
//

import Foundation

extension Array where Element: CustomStringConvertible {
    public func joined() -> String {
        if isEmpty {
            return ""
        }
        return map { $0.description }.joined(separator: ", ")
    }
    public func lined(indent: String = "") -> String {
        if isEmpty {
            return ""
        }
        return indent + map { $0.description }.joined(separator: "\n\(indent)")
    }
}

public enum DeclarationType: String {
    case float = "Float"
    case string = "String"
    case bool = "Bool"
}

public enum AccessLevel: String, CaseIterable {
    /// The reference can be accessed and mutated in any module
    case `public`
    /// The reference can be accessed in any module and edited in the defining module
    case `exposed`
    /// The reference can only be accessed inside an object
    case `private`
}

public protocol Visitor {
    associatedtype Result
    func visit(_ strct: StructStatement) throws -> Result
    func visit(_ decl: DeclarationStatement) throws -> Result
    func visit(_ ref: ReferenceStatement) throws -> Result
    func visit(_ access: AccessStatement) throws -> Result
    func visit(_ call: CallStatement) throws -> Result
    func visit(_ assign: AssignStatement) throws -> Result
    func visit(_ expr: Expression) throws -> Result
    func visit(_ constr: InitStatement) throws -> Result
    func visit(_ set: SetStatement) throws -> Result
    func visit(_ funct: FunctionStatement) throws -> Result
    func visit(_ arg: ParameterStatement) throws -> Result
    func visit(_ binary: BinaryExpression) throws -> Result
    func visit(_ cond: IfStatement) throws -> Result
    func visit(_ alias: TypeAliasStatement) throws -> Result
    func visit(_ proto: ProtocolStatement) throws -> Result
    func visit(_ extend: ExtensionStatement) throws -> Result
    func visit(_ inter: InternalReferenceStatement) throws -> Result
    func visit(_ impr: ImportStatement) throws -> Result
    func visit(_ protoMeth: MethodPrototypeStatement) throws -> Result
}

public class Statement: CustomStringConvertible {
    public func accept<V: Visitor, R>(_ visitor: V) throws -> R where V.Result == R {
        fatalError()
    }
    public var description: String {
        fatalError()
    }
//    public func encode(to encoder: Encoder) throws {
//        fatalError()
//    }
//    public init(from decoder: Decoder) throws {
//        fatalError()
//    }
}

public final class StructStatement: Statement {
    public let name: Token
    public let conformances: [Token]
    public let declarations: [DeclarationStatement]
    public let references: [ReferenceStatement]
    public let internals: [InternalReferenceStatement]
    public let methods: [FunctionStatement]
    public init(
        name: Token,
        conformances: [Token],
        declarations: [DeclarationStatement] = [],
        references: [ReferenceStatement],
        internals: [InternalReferenceStatement],
        methods: [FunctionStatement]
        )
    {
        self.name = name
        self.conformances = conformances
        self.declarations = declarations
        self.references = references
        self.internals = internals
        self.methods = methods
    }
    
    public override var description: String {
        let refStr = references.isEmpty ? "" : "\n\(references.lined(indent: "  "))\n"
        let conformStr = conformances.isEmpty ? " " : ": \(conformances.map { $0.lexme }.joined(separator: ", ")) "
        return "struct \(name.lexme)\(conformStr){\(refStr)}"
    }
    
    public override func accept<V, R>(_ visitor: V) throws -> R where V : Visitor, R == V.Result {
        return try visitor.visit(self)
    }
}

public final class DeclarationStatement: Statement {
    public let name: Token
    public let type: DeclarationType
    public init(name: Token, type: DeclarationType) {
        self.name = name
        self.type = type
    }
    public override var description: String {
        return "decl \(type.rawValue) \(name.lexme)"
    }
    public override func accept<V, R>(_ visitor: V) throws -> R where V : Visitor, R == V.Result {
        return try visitor.visit(self)
    }
}

public final class ReferenceStatement: Statement {
    public let accessLevel: AccessLevel
    public let name: Token
    public let type: Token
    public init(accessLevel: AccessLevel = .private, name: Token, type: Token) {
        self.accessLevel = accessLevel
        self.name = name
        self.type = type
    }
    public override var description: String {
        return "\(accessLevel.rawValue) ref \(name.lexme): \(type.lexme)"
    }
    public override func accept<V, R>(_ visitor: V) throws -> R where V : Visitor, R == V.Result {
        return try visitor.visit(self)
    }
}

public final class AccessStatement: Statement {
    public let object: Token
    public let key: Token
    public init(object: Token, key: Token) {
        self.object = object
        self.key = key
    }
    public override var description: String {
        return "\(object.lexme).\(key.lexme))"
    }
    public override func accept<V, R>(_ visitor: V) throws -> R where V : Visitor, R == V.Result {
        return try visitor.visit(self)
    }
}

public final class CallStatement: Statement {
    public let name: Token
    public let args: [Expression]
    public init(name: Token, args: [Expression]) {
        self.name = name
        self.args = args
    }
    public override var description: String {
        return "\(name.lexme)(\(args.joined()))"
    }
    public override func accept<V, R>(_ visitor: V) throws -> R where V : Visitor, R == V.Result {
        return try visitor.visit(self)
    }
}

public final class BinaryExpression: Statement {
    public let lhs: Expression
    public let op: Token
    public let rhs: Expression
    public init(lhs: Expression, op: Token, rhs: Expression) {
        self.lhs = lhs
        self.op = op
        self.rhs = rhs
    }
    public override var description: String {
        var lhsDes = ""
        switch lhs.rep {
        case .expr(let expr):
            lhsDes = "(\(expr))"
        default:
            lhsDes = lhs.description
        }
        var rhsDes = ""
        switch rhs.rep {
        case .expr(let expr):
            rhsDes = "(\(expr))"
        default:
            rhsDes = rhs.description
        }
        return "\(lhsDes) \(op.lexme) \(rhsDes)"
    }
    public override func accept<V, R>(_ visitor: V) throws -> R where V : Visitor, R == V.Result {
        return try visitor.visit(self)
    }
}

public final class Expression: Statement {
    public enum Rep: CustomStringConvertible {
        case token(Token)
        case string(String)
        case float(Float)
        case int(Int)
        case bool(Bool)
        case access(AccessStatement)
        case call(CallStatement)
        case expr(BinaryExpression)
        public var description: String {
            switch self {
            case .token(let token):
                return token.lexme
            case .string(let string):
                return string
            case .float(let float):
                return float.description
            case .int(let int):
                return int.description
            case .bool(let bool):
                return bool.description
            case .access(let access):
                return access.description
            case .call(let call):
                return call.description
            case .expr(let expr):
                return expr.description
            default:
                fatalError("Add case to Expression.Rep.description")
            }
        }
    }
    public let rep: Rep
    public init(rep: Rep) {
        self.rep = rep
    }
    public override var description: String {
        return "\(rep)"
    }
    public override func accept<V, R>(_ visitor: V) throws -> R where V : Visitor, R == V.Result {
        return try visitor.visit(self)
    }
}

public final class IfStatement: Statement {
    public let condition: Expression
    public let ifTrue: [Statement]
    public let ifFalse: [Statement]
    public init(condition: Expression, then: [Statement], else: [Statement]) {
        self.condition = condition
        self.ifTrue = then
        self.ifFalse = `else`
    }
    public override var description: String {
        return "if \(condition)"
    }
    public override func accept<V, R>(_ visitor: V) throws -> R where V : Visitor, R == V.Result {
        return try visitor.visit(self)
    }
}

public final class InitStatement: Statement {
    public let objectName: Token
    public let args: [Expression]
    public init(objectName: Token, args: [Expression]) {
        self.objectName = objectName
        self.args = args
    }
    public override var description: String {
        return "\(objectName.lexme).init(\(args.joined())"
    }
    public override func accept<V, R>(_ visitor: V) throws -> R where V : Visitor, R == V.Result {
        return try visitor.visit(self)
    }
}

public final class AssignStatement: Statement {
    public let decl: Token
    public let name: Token
    public let value: Expression
    public init(decl: Token, name: Token, expression: Expression) {
        self.decl = decl
        self.name = name
        self.value = expression
    }
    public override var description: String {
        return "\(decl.lexme) \(name.lexme) = \(value)"
    }
    public override func accept<V, R>(_ visitor: V) throws -> R where V : Visitor, R == V.Result {
        return try visitor.visit(self)
    }
}

public final class SetStatement: Statement {
    public let object: Token
    public let key: Token
    public let value: Expression
    public init(object: Token, key: Token, value: Expression) {
        self.object = object
        self.key = key
        self.value = value
    }
    public override var description: String {
        return "\(object.lexme).\(key.lexme) = \(value))"
    }
    public override func accept<V, R>(_ visitor: V) throws -> R where V : Visitor, R == V.Result {
        return try visitor.visit(self)
    }
}

public final class ParameterStatement: Statement {
    public let name: Token
    public let type: Token
    public init(name: Token, type: Token) {
        self.name = name
        self.type = type
    }
    public override var description: String {
        return "\(name.lexme): \(type.lexme)"
    }
    public override func accept<V, R>(_ visitor: V) throws -> R where V : Visitor, R == V.Result {
        return try visitor.visit(self)
    }
}

public final class FunctionStatement: Statement {
    public let name: Token
    public let args: [ParameterStatement]
    public let body: [Statement]
    public let returnType: Token
    public init(name: Token, args: [ParameterStatement], body: [Statement], returnType: Token = Token(type: .identifier, lexme: "Void", literal: nil, line: nil)) {
        self.name = name
        self.args = args
        self.body = body
        self.returnType = returnType
    }
    public override var description: String {
        return "\(name.lexme)(\(args.joined())) -> \(returnType.lexme)"
    }
    public override func accept<V, R>(_ visitor: V) throws -> R where V : Visitor, R == V.Result {
        return try visitor.visit(self)
    }
}

public final class TypeAliasStatement: Statement {
    public let alias: Token
    public let type: Token
    public init(alias: Token, type: Token) {
        self.alias = alias
        self.type = type
    }
    public override var description: String {
        return "typealias \(alias.lexme) = \(type.lexme)"
    }
    public override func accept<V, R>(_ visitor: V) throws -> R where V : Visitor, R == V.Result {
        return try visitor.visit(self)
    }
}

public final class ProtocolStatement: Statement {
    public let name: Token
    public let references: [ReferenceStatement]
    public init(name: Token, references: [ReferenceStatement]) {
        self.name = name
        self.references = references
    }
    public override var description: String {
        return "protocol \(name.lexme) {\n\(references.lined(indent: "  "))\n}"
    }
    
    public override func accept<V, R>(_ visitor: V) throws -> R where V : Visitor, R == V.Result {
        return try visitor.visit(self)
    }
}

public final class ExtensionStatement: Statement {
    public let name: Token
    public let references: [ReferenceStatement]
    public init(name: Token, references: [ReferenceStatement]) {
        self.name = name
        self.references = references
    }
    public override var description: String {
        return "extend \(name.lexme) {\n\(references.lined(indent: "  "))\n}"
    }
    
    public override func accept<V, R>(_ visitor: V) throws -> R where V : Visitor, R == V.Result {
        return try visitor.visit(self)
    }
}

public final class InternalReferenceStatement: Statement {
    public let name: Token
    public let type: Token
    public init(name: Token, type: Token) {
        self.name = name
        self.type = type
    }
    public override var description: String {
        return "internal \(type.lexme)"
    }
    public override func accept<V, R>(_ visitor: V) throws -> R where V : Visitor, R == V.Result {
        return try visitor.visit(self)
    }
}

public final class MethodPrototypeStatement: Statement {
    public let name: Token
    public let args: [ParameterStatement]
    public let type: Token
    public init(name: Token, args: [ParameterStatement], type: Token) {
        self.name = name
        self.args = args
        self.type = type
    }
    public override var description: String {
        return "\(name.lexme)(\(args.joined())) -> \(type.lexme)"
    }
    public override func accept<V, R>(_ visitor: V) throws -> R where V : Visitor, R == V.Result {
        return try visitor.visit(self)
    }
}

public final class ImportStatement: Statement {
    public let module: Token
    public init(module: Token) {
        self.module = module
    }
    public override var description: String {
        return "impoty \(module.lexme)"
    }
    public override func accept<V, R>(_ visitor: V) throws -> R where V : Visitor, R == V.Result {
        return try visitor.visit(self)
    }
}

public struct Attribute {
    public let name: Token
    public let params: [Token]
}
