//
//  Visitor.swift
//  
//
//  Created by Ethan Uppal on 12/23/18.
//

import Foundation

public protocol Visitor {
    associatedtype Result
    func visit(stmt: Statement) -> Result?
    func visit(_ objc: ObjectStatement) -> Result
    func visit(_ decl: DeclarationStatement) -> Result
    func visit(_ access: AccessStatement) -> Result
    func visit(_ call: CallStatement) -> Result
    func visit(_ assign: AssignStatement) -> Result
    func visit(_ expr: Expression) -> Result
    func visit(_ constr: InitStatement) -> Result
    func visit(_ set: SetStatement) -> Result
    func visit(_ funct: FunctionStatement) -> Result
    func visit(_ binary: BinaryExpression) -> Result
    func visit(_ cond: IfStatement) -> Result
}

public extension Visitor {
    public func visit(stmt: Statement) -> Result? {
        switch stmt {
        case let objc as ObjectStatement:
            return visit(objc)
        case let decl as DeclarationStatement:
            return visit(decl)
        case let get as AccessStatement:
            return visit(get)
        case let call as CallStatement:
            return visit(call)
        case let assign as AssignStatement:
            return visit(assign)
        case let expr as Expression:
            return visit(expr)
        case let constr as InitStatement:
            return visit(constr)
        case let set as SetStatement:
            return visit(set)
        case let funct as FunctionStatement:
            return visit(funct)
        case let binary as BinaryExpression:
            return visit(binary)
        case let cond as IfStatement:
            return visit(cond)
        default:
            return nil
        }
    }
}
