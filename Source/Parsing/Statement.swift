//
//  Statement.swift
//  
//
//  Created by Ethan Uppal on 12/23/18.
//

import Foundation

/// The abstract superclass for all statements
public class Statement {
    public var line: Int?
    public func accept<V: Visitor, R>(_ visitor: V) -> R where V.Result == R {
        fatalError()
    }
}

/// A statement representing an object
public class ObjectStatement: Statement, CustomStringConvertible {
    public let name: Token
    public let declarations: [DeclarationStatement]
    public init(name: Token, declarations: [DeclarationStatement]) {
        self.name = name
        self.declarations = declarations
    }
    public var description: String {
        return "ObjectStatement(name: \(name), declarations: \(declarations))"
    }
    
    public override func accept<V, R>(_ visitor: V) -> R where V : Visitor, R == V.Result {
        return visitor.visit(self)
    }
}

/// The type of something
public enum ObjectType: String {
    case implied = "*Any"
    case float = "Float"
    case string = "String"
    case bool = "Bool"
}

/// A statement representing a declaration
public class DeclarationStatement: Statement, CustomStringConvertible {
    public let name: Token
    public let type: ObjectType
    public init(name: Token, type: ObjectType) {
        self.name = name
        self.type = type
    }
    public var description: String {
        return "DeclarationStatement(name: \(name), type: \(type.rawValue))"
    }
    public override func accept<V, R>(_ visitor: V) -> R where V : Visitor, R == V.Result {
        return visitor.visit(self)
    }
}

/// A statement representing an access
public class AccessStatement: Statement, CustomStringConvertible {
    public let object: Token
    public let key: Token
    public init(object: Token, key: Token) {
        self.object = object
        self.key = key
    }
    public var description: String {
        return "AccessStatement(object: \(object), key: \(key))"
    }
    public override func accept<V, R>(_ visitor: V) -> R where V : Visitor, R == V.Result {
        return visitor.visit(self)
    }
}


/// A statement representing a call
public class CallStatement: Statement, CustomStringConvertible {
    public let name: Token
    public let args: [Expression]
    public init(name: Token, args: [Expression]) {
        self.name = name
        self.args = args
    }
    public var description: String {
        return "CallStatement(name: \(name), args: \(args))"
    }
    public override func accept<V, R>(_ visitor: V) -> R where V : Visitor, R == V.Result {
        return visitor.visit(self)
    }
}

/// Any expression
public class Expression: Statement, CustomStringConvertible {
    public enum Rep {
        case constr(InitStatement)
        case call(CallStatement)
        case literal(Any)
        case anyToken(Token)
        case access(AccessStatement)
        case binary(BinaryExpression)
        case list([Token])
        public var call: CallStatement? {
            switch self {
            case let .call(call):
                return call
            default:
                return nil
            }
        }
        public var constr: InitStatement? {
            switch self {
            case let .constr(constr):
                return constr
            default:
                return nil
            }
        }
        public var literal: Any? {
            switch self {
            case let .literal(literal):
                return literal
            default:
                return nil
            }
        }
        public var anyToken: Token? {
            switch self {
            case let .anyToken(tkn):
                return tkn
            default:
                return nil
            }
        }
        public var access: AccessStatement? {
            switch self {
            case let .access(access):
                return access
            default:
                return nil
            }
        }
        public var expr: BinaryExpression? {
            switch self {
            case let .binary(expr):
                return expr
            default:
                return nil
            }
        }
        public var list: [Token]? {
            switch self {
            case let .list(list):
                return list
            default:
                return nil
            }
        }
    }
    public let rep: Rep
    public init(rep: Rep) {
        self.rep = rep
    }
    public var description: String {
        return "Expression(rep: \(rep))"
    }
    public override func accept<V, R>(_ visitor: V) -> R where V : Visitor, R == V.Result {
        return visitor.visit(self)
    }
}

/// A binary expression
public class BinaryExpression: Statement, CustomStringConvertible {
    public let lhs: Expression
    public let op: Token
    public let rhs: Expression
    public init(lhs: Expression, op: Token, rhs: Expression) {
        self.lhs = lhs
        self.op = op
        self.rhs = rhs
    }
    public var description: String {
        return "BinaryExpression(lhs: \(lhs), op: \(op), rhs: \(rhs))"
    }
    public override func accept<V, R>(_ visitor: V) -> R where V : Visitor, R == V.Result {
        return visitor.visit(self)
    }
}

/// A statement representing conditional code
public class IfStatement: Statement, CustomStringConvertible {
    public let condition: Expression
    public let ifTrue: [Statement]
    public let ifFalse: [Statement]
    public init(condition: Expression, then: [Statement], else: [Statement]) {
        self.condition = condition
        self.ifTrue = then
        self.ifFalse = `else`
    }
    public var description: String {
        return "IfStatement(condition: \(condition), then: \(ifTrue), else: \(ifFalse))"
    }
    public override func accept<V, R>(_ visitor: V) -> R where V : Visitor, R == V.Result {
        return visitor.visit(self)
    }
}

/// A statement representing a constructor
public class InitStatement: Statement, CustomStringConvertible {
    public let objectName: Token
    public let args: [Expression]
    public init(objectName: Token, args: [Expression]) {
        self.objectName = objectName
        self.args = args
    }
    public var description: String {
        return "InitStatement(objectName: \(objectName), args: \(args))"
    }
    public override func accept<V, R>(_ visitor: V) -> R where V : Visitor, R == V.Result {
        return visitor.visit(self)
    }
}

/// A statement representing an assignment
public class AssignStatement: Statement, CustomStringConvertible {
    public let decl: Token
    public let name: Token
    public let value: Expression
    public init(decl: Token, name: Token, expression: Expression) {
        self.decl = decl
        self.name = name
        self.value = expression
    }
    public var description: String {
        return "AssignStatement(name: \(name), value: \(value))"
    }
    public override func accept<V, R>(_ visitor: V) -> R where V : Visitor, R == V.Result {
        return visitor.visit(self)
    }
}

/// A statement representing a set
public class SetStatement: Statement, CustomStringConvertible {
    public let object: Token
    public let key: Token
    public let value: Expression
    public init(object: Token, key: Token, value: Expression) {
        self.object = object
        self.key = key
        self.value = value
    }
    public var description: String {
        return "SetStatement(object: \(object), key: \(key), value: \(value))"
    }
    public override func accept<V, R>(_ visitor: V) -> R where V : Visitor, R == V.Result {
        return visitor.visit(self)
    }
}

/// A statement representing a function
public class FunctionStatement: Statement, CustomStringConvertible {
    public let name: Token
    public let args: [Token]
    public let body: [Statement]
    public init(name: Token, args: [Token], body: [Statement]) {
        self.name = name
        self.args = args
        self.body = body
    }
    public var description: String {
        return "FunctionStatement(name: \(name), args: \(args), body: \(body))"
    }
    public override func accept<V, R>(_ visitor: V) -> R where V : Visitor, R == V.Result {
        return visitor.visit(self)
    }
}



