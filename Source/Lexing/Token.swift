//
//  Token.swift
//  
//
//  Created by Ethan Uppal on 12/23/18.
//

import Foundation

public enum TokenType {
    case varDecl
    case constDecl
    case funcDecl
    case objcDecl
    case ifDecl
    case elseDecl
    case initDecl
    case propertyDecl
    
    case literal
    case null
    case this
    case identifier
    
    case plus
    case minus
    case multiply
    case divide
    case join
    
    case assign
    case equal
    case unequal
    
    case not
    case and
    case or
    
    case leftPar, rightPar
    case leftBracket, rightBracket
    
    case semicolon
    case underscore
    case newLine
    case comma
    case dot
    case eof
}

public struct Token: Equatable, CustomStringConvertible {
    public let type: TokenType
    public let lexme: String
    public var literal: Any?
    public let line: Int?
    
    public static let EOF = Token(type: .eof, lexme: "\\0", literal: nil, line: nil)
    public static let initDecl = Token(type: .initDecl, lexme: "init", literal: nil, line: nil)
    
    public var description: String {
        if self.type == .newLine {
            return "(type: newLine, value: '\\n')"
        }
        if let literal = literal {
            return "(type: \(type), literal: \(literal), line: \(line ?? -1))"
        }
        let l = self.line?.description ?? "nil"
        return "(type: \(type), value: '\(lexme)', line: \(l))"
    }
    public static func == (lhs: Token, rhs: Token) -> Bool {
        return (lhs.type, lhs.lexme, lhs.line) == (rhs.type, rhs.lexme, rhs.line)
    }
}
