//
//  Parser.swift
//  
//
//  Created by Ethan Uppal on 12/23/18.
//

import Foundation

public class Parser {
    public enum Error: Swift.Error {
        case groupNotClosed
        case expectedStartingBracket
        case expectedClosingBracket
        case expectedIdentifier
        case expectedType
        case expectedDeclaration
        case unexpectedToken
        case expectedSemicolon
        case expectedAssignment
        case expectedLiteral
        case expectedStartingGroup
        case expectedClosingGroup
        case anyError
    }
    let stream: [Token]
    var pos = 0
    
    public func currentLine() -> Int {
        return current?.line ?? -1
    }
    
    public init(stream: [Token]) {
        self.stream = stream
    }
    
    var current: Token? {
        return stream.isEmpty || isAtEnd() ? nil : stream[pos]
    }
    
    func reset() {
        pos = 0
    }
    func isAtEnd() -> Bool {
        return pos + 1 == stream.count
    }
    func advance() {
        pos += 1
    }
    
    func eat(_ type: TokenType) -> Bool {
        let c = current
        if c?.type == type {
            advance()
            return true
        } else {
            return false
        }
    }
    func match(_ type: TokenType) -> Bool {
        return current?.type == type
    }
    func get(_ type: TokenType) -> Token? {
        let c = current
        if c?.type == type {
            advance()
            return c
        } else {
            return nil
        }
    }
    
    func skipBlankLines() {
        while current?.type == .newLine, !isAtEnd() {
            advance()
        }
    }
    
    func expect<C: RangeReplaceableCollection>(_ type: TokenType, c: inout C) -> Token? where C.Element == Token {
        let t = c.first
        if t?.type == type {
            c.removeFirst()
            return t
        }
        return nil
    }
    
    public var isDebugging = false
    
    func _makeObjcStmt(_ g: [Token], _ s: inout [Statement]) throws {
        let l = g.first?.line
        var g = g
        let name = g.removeFirst()
        var decls = [DeclarationStatement]()
        let segments = g.split(whereSeparator: { $0.type == .semicolon }).filter{ $0.count > 1 }
        if isDebugging {
            print("Segments for ObjectStatement of \(name):", segments)
        }
        for segment in segments {
            var segment = segment
            if segment.first?.type == .newLine {
                segment.removeFirst()
            }
            guard expect(.propertyDecl, c: &segment) != nil else { throw Error.expectedDeclaration }
            if segment.count == 1 {
                guard segment.first?.type == .identifier else { throw Error.expectedIdentifier }
                if let declName = segment.first {
                    let decl = DeclarationStatement(name: declName, type: .implied)
                    decls.append(decl)
                }
            } else if segment.count == 2 {
                guard segment.first?.type == .identifier else { throw Error.expectedIdentifier }
                guard segment.dropFirst().first?.type == .identifier else { throw Error.expectedType }
                guard let type = ObjectType(rawValue: segment[2].lexme) else { throw Error.expectedType }
                let decl = DeclarationStatement(name: segment[0], type: type)
                decls.append(decl)
            } else {
                throw Error.unexpectedToken
            }
        }
        let objcStmt = ObjectStatement(name: name, declarations: decls)
        objcStmt.line = l
        s.append(objcStmt)
    }
    
    func _makeAssignStmt(_ g: [Token], _ s: inout [Statement]) throws {
        var g = g
        let l = g.first?.line
        guard let varName = expect(.identifier, c: &g) else { throw Error.expectedIdentifier }
        guard expect(.assign, c: &g) != nil else { throw Error.expectedAssignment }
        switch g.count {
        case 1:
            guard let lit = expect(.literal, c: &g) else { throw Error.expectedLiteral }
            let assignStmt = AssignStatement(decl: type, name: varName, expression: Expression(rep: .literal(lit.literal!)))
            assignStmt.line = l
            s.append(assignStmt)
            return
        default:
            if g.count == 3, g.dropFirst().first?.type == .dot, let object = g.first, let key = g.last {
                let access = AccessStatement(object: object, key: key)
                s.append(access)
                return
            }
            guard g.count >= 3 else { throw Error.anyError }
            guard let fncName = expect(.identifier, c: &g) else {
                throw Error.expectedIdentifier
            }
            
            guard expect(.leftPar, c: &g) != nil else { throw Error.expectedStartingGroup }
            var args = [Expression]()
            var onComma = false
            var i = 0
            while g[i].type != .rightPar {
                let tkn = g[i]
                if args.isEmpty && tkn.type == .comma {
                    throw Error.unexpectedToken
                }
                if tkn.type == .comma {
                    guard !onComma else { throw Error.unexpectedToken }
                    onComma = true
                } else {
                    onComma = false
                    let expr = Expression(rep: .anyToken(tkn))
                    args.append(expr)
                }
                i += 1
            }
            
            if let char = fncName.lexme.first, let scalar = char.unicodeScalars.first, CharacterSet.uppercaseLetters.contains(scalar) {
                let constr = InitStatement(objectName: fncName, args: args)
                let expr = Expression(rep: .constr(constr))
                let assignStmt = AssignStatement(name: varName, expression: expr)
                assignStmt.line = l
                s.append(assignStmt)
                return
            } else {
                let call = CallStatement(name: fncName, args: args)
                let expr = Expression(rep: .call(call))
                let assignStmt = AssignStatement(name: varName, expression: expr)
                assignStmt.line = l
                s.append(assignStmt)
                return
            }
            throw Error.unexpectedToken
        }
    }
    
    func _makeFuncStmt(_ g: [Token], _ s: inout [Statement]) throws {
        let l = currentLine()
        var g = g
        guard let name = expect(.identifier, c: &g) else { throw Error.expectedIdentifier }
        if isDebugging {
            print("FunctionStatement named \(name), g:", g)
        }
        guard expect(.leftPar, c: &g) != nil else { throw Error.expectedStartingGroup }
        var args = [Token]()
        var body = [Statement]()
        let allowed: Set<TokenType> = [
            .identifier,
            ]
        while g.first?.type != .rightPar {
            if g.isEmpty {
                throw Error.expectedClosingGroup
            }
            if let tkn = g.first {
                if allowed.contains(tkn.type) {
                    args.append(tkn)
                    g.removeFirst()
                } else if tkn.type == .comma {
                    g.removeFirst()
                }
            } else {
                break
            }
        }
        if isDebugging {
            print("FunctionStatement args:", args)
        }
        guard expect(.rightPar, c: &g) != nil else { throw Error.expectedClosingGroup }
        guard expect(.leftBracket, c: &g) != nil else { throw Error.expectedStartingBracket }
        let segments = g.dropFirst().split(whereSeparator: { $0.type == .semicolon }).filter{ !$0.isEmpty }
        if isDebugging {
            print("Segments for FunctionStatement named \(name):", segments)
        }
        let argAllowed: Set<TokenType> = [
            .identifier,
            .literal,
            .join
        ]
        let argSeps: Set<TokenType> = [
            .comma
        ]
        
        for segment in segments {
            var segment = segment
            if segment.first?.type == .newLine {
                segment.removeFirst()
            }
            let toCheck = segment.index(after: segment.startIndex)
            if segment.count >= 5, segment[toCheck].type == .dot {
                guard let object = expect(.identifier, c: &segment) else { throw Error.expectedIdentifier }
                guard expect(.dot, c: &segment) != nil else { throw Error.unexpectedToken }
                guard let key = expect(.identifier, c: &segment) else { throw Error.expectedIdentifier }
                guard expect(.assign, c: &segment) != nil else { throw Error.expectedAssignment }
                let expr = Expression(rep: .anyToken(segment[0]))
                let setStmt = SetStatement(object: object, key: key, value: expr)
                body.append(setStmt)
            } else if segment.count > 2 {
                if let type = expect(.varDecl, c: &segment) {
                    try _makeAssignStmt(type, Array(segment), &s)
                } else if let type = expect(.setDecl, c: &segment) {
                    try _makeAssignStmt(type, Array(segment), &s)
                } else {
                    guard let callName = expect(.identifier, c: &segment) else { throw Error.expectedIdentifier }
                    var args = [Expression]()
                    guard expect(.leftPar, c: &segment) != nil else { throw Error.expectedStartingGroup }
                    while let tkn = segment.first, tkn.type != .rightPar {
                        if segment.isEmpty {
                            throw Error.expectedClosingGroup
                        }
                        if tkn.type == .identifier, segment.dropFirst().first?.type == .dot, let key = segment.dropFirst(2).first {
                            let access = AccessStatement(object: tkn, key: key)
                            let expr = Expression(rep: .access(access))
                            args.append(expr)
                            segment.removeFirst(3)
                            continue
                        }
                        if argAllowed.contains(tkn.type) {
                            let expr = Expression(rep: .anyToken(tkn))
                            args.append(expr)
                        } else if !argSeps.contains(tkn.type) {
                            throw Error.unexpectedToken
                        }
                        segment.removeFirst()
                    }
                    if isDebugging {
                        print("Args", args)
                    }
                    guard expect(.rightPar, c: &segment) != nil else { throw Error.expectedClosingGroup }
                    let callStmt = CallStatement(name: callName, args: args)
                    body.append(callStmt)
                }
            }
        }
        let funcStmt = FunctionStatement(name: name, args: args, body: body)
        funcStmt.line = l
        s.append(funcStmt)
    }
    
    func _makeCallStmt(_ g: [Token], _ s: inout [Statement]) throws {
        var g = g
        let l = g.first?.line
        guard let callName = expect(.identifier, c: &g) else { throw Error.expectedIdentifier }
        guard expect(.leftPar, c: &g) != nil else { throw Error.expectedStartingGroup }
        guard g.last?.type == .rightPar else { throw Error.expectedClosingGroup }
        var argSegments = g.dropLast().split(whereSeparator: { $0.type == .comma })
        if isDebugging {
            print("Creating Call:", argSegments)
        }
        var args = [Expression]()
        func addStmt(subsegment: Token, args: inout [Expression]) {
            let parts = subsegment.lexme.components(separatedBy: ".")
            if isDebugging {
                print("parts:", parts, "subsegment:", subsegment)
            }
            //            if parts.count == 2 {
            //                let objcToken = Token(type: .identifier, lexme: parts[0], literal: nil, line: nil)
            //                let keyToken = Token(type: .identifier, lexme: parts[1], literal: nil, line: nil)
            //                let get = AccessStatement(object: objcToken, key: keyToken)
            //                args.append(Expression(rep: .access(get)))
            //            } else
            if parts.count == 1 {
                let expr = Expression(rep: .anyToken(subsegment))
                args.append(expr)
            }
        }
        for segment in argSegments {
            var segment = segment
            while let subsegment = segment.first {
                if subsegment.type == .identifier, segment.dropFirst().first?.type == .dot, let key = segment.dropFirst(2).first {
                    if subsegment.lexme.isEmpty || key.lexme.isEmpty {
                        continue
                    }
                    let access = AccessStatement(object: subsegment, key: key)
                    let expr = Expression(rep: .access(access))
                    args.append(expr)
                    segment.removeAll()
                    continue
                }
                addStmt(subsegment: subsegment, args: &args)
                segment.removeFirst()
            }
        }
        let call = CallStatement(name: callName, args: args)
        call.line = l
        s.append(call)
    }
    
    func _makeSetStmt(_ g: [Token], _ s: inout [Statement]) throws {
        var g = g
        let objcName = g.removeFirst()
        guard expect(.dot, c: &g) != nil else { throw Error.unexpectedToken }
        guard let key = expect(.identifier, c: &g) else { throw Error.expectedIdentifier }
        guard expect(.assign, c: &g) != nil else { throw Error.unexpectedToken }
        // FIXME: Allow multiple-token expressions
        guard let val = g.first else { throw Error.anyError }
        let expr = Expression(rep: .anyToken(val))
        SetStatement(object: objcName, key: key, value: expr)
    }
    
    public func formStatements(_ stmts: inout [Statement]) throws {
        reset()
        var group: [Token]?
        while !isAtEnd() {
            skipBlankLines()
            if isDebugging {
                print("Testing statement against:", current!)
            }
            if current?.type == .objcDecl {
                advance()
                guard let objcName = get(.identifier) else { throw Error.expectedIdentifier }
                guard group == nil else { throw Error.groupNotClosed }
                group = [objcName]
                guard eat(.leftBracket) else { throw Error.expectedStartingBracket }
                while !eat(.rightBracket) {
                    if isAtEnd() {
                        throw Error.expectedClosingBracket
                    }
                    if let c = current {
                        group?.append(c)
                    } else {
                        break
                    }
                    advance()
                }
                try _makeObjcStmt(group!, &stmts)
                group = nil
            } else if current?.type == .varDecl {
                advance()
                guard let varName = get(.identifier) else { throw Error.expectedIdentifier }
                guard group == nil else { throw Error.groupNotClosed }
                group = [varName]
                while !eat(.semicolon) {
                    if isAtEnd() {
                        throw Error.expectedSemicolon
                    }
                    if let c = current {
                        group?.append(c)
                    } else {
                        break
                    }
                    advance()
                }
                try _makeAssignStmt(group!, &stmts)
                group = nil
            } else if current?.type == .identifier {
                guard let name = get(.identifier) else { throw Error.expectedIdentifier }
                guard group == nil else { throw Error.groupNotClosed }
                group = [name]
                while !eat(.semicolon) {
                    if isAtEnd() {
                        throw Error.expectedSemicolon
                    }
                    if let c = current {
                        group?.append(c)
                    } else {
                        break
                    }
                    advance()
                }
                if group?.dropFirst().first?.type == .dot {
                    try _makeSetStmt(group!, &stmts)
                } else {
                    try _makeCallStmt(group!, &stmts)
                }
                group = nil
            } else if current?.type == .funcDecl {
                advance()
                guard let funcName = get(.identifier) else { throw Error.expectedIdentifier }
                guard group == nil else { throw Error.groupNotClosed }
                group = [funcName]
                guard match(.leftPar) else { throw Error.expectedStartingGroup }
                while !eat(.rightBracket) {
                    if isAtEnd() {
                        throw Error.expectedClosingBracket
                    }
                    if let c = current {
                        group?.append(c)
                    } else {
                        break
                    }
                    advance()
                }
                try _makeFuncStmt(group!, &stmts)
                group = nil
            }
        }
    }
}
