//
//  precedence_climbing.swift
//  SwizzleSrc
//
//  Created by Ethan Uppal on 1/24/19.
//  Copyright © 2019 Ethan Uppal. All rights reserved.
//

import Foundation

public protocol Combining {
    static func combine(lhs: Self, op: Token, rhs: Self) -> Expression
}

public protocol ExpressionRepresentable {
    var rep: Expression.Rep { get }
}

extension Expression: ExpressionRepresentable {}
extension BinaryExpression: ExpressionRepresentable {
    public var rep: Expression.Rep {
        return .expr(self)
    }
}

extension Expression: Combining {
    public static func combine(lhs: Expression, op: Token, rhs: Expression) -> Expression {
        let expr = BinaryExpression(lhs: lhs, op: op, rhs: rhs)
        return Expression(rep: .expr(expr))
    }
}

extension BinaryExpression: Combining {
    public static func combine(lhs: BinaryExpression, op: Token, rhs: BinaryExpression) -> Expression {
        let expr = BinaryExpression(lhs: .init(rep: .expr(lhs)), op: op, rhs: .init(rep: .expr(rhs)))
        return Expression(rep: .expr(expr))
    }
}

public extension ExpressionRepresentable {
    public func combine(with value: Self, op: Token) -> Expression {
        let expr = BinaryExpression(lhs: Expression(rep: rep), op: op, rhs: Expression(rep: value.rep))
        return Expression(rep: .expr(expr))
    }
}

extension Expression {
    public func combine(with value: BinaryExpression, op: Token) -> Expression {
        let expr = BinaryExpression(lhs: Expression(rep: rep), op: op, rhs: Expression(rep: .expr(value)))
        return Expression(rep: .expr(expr))
    }
}

extension Expression.Rep: ExpressibleByFloatLiteral, ExpressibleByStringLiteral, ExpressibleByBooleanLiteral, ExpressibleByIntegerLiteral {
    public init(floatLiteral value: Float) {
        self = .float(value)
    }
    public init(integerLiteral value: Int) {
        self = .int(value)
    }
    public init(stringLiteral value: String) {
        self = .string(value)
    }
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}
