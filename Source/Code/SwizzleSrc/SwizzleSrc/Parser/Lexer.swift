//
//  Lexer.swift
//  Swizzle - Compiling
//
//  Created by Ethan Uppal on 1/13/19.
//  Copyright © 2019 Ethan Uppal. All rights reserved.
//

import Foundation

public enum TokenType {
    // Declarations
    case varDecl
    case setDecl
    case constDecl
    case funcDecl
    case structDecl
    case ifDecl
    case elseDecl
    case initDecl
    case propertyDecl
    case refDecl
    case protocolDecl
    case extendDecl
    case typeAliasDecl
    case internalDecl
    case importDecl
    
    // Other
    case attribute
    case accessLevel
    case typeIs
    
    // Misc
    case literal
    case null
    case this
    case identifier
    
    // Operators
    case plus
    case minus
    case multiply
    case divide
    case modulus
    
    case join
    case arrow
    
    case assign
    case equal
    case unequal
    
    case not
    case and
    case or
    
    // Grouping
    case leftPar, rightPar
    case leftBracket, rightBracket
    
    // Symbols
    case semicolon
    case colon
    case scope
    case underscore
    case newLine
    case comma
    case dot
    case eof
}

// A token
public struct Token: Hashable, CustomStringConvertible, CustomDebugStringConvertible {
    public let type: TokenType
    public let lexme: String // the value of teh token
    public var literal: Any?
    public let line: Int?
    
    public init(type: TokenType, lexme: String, literal: Any?, line: Int?) {
        self.type = type
        self.lexme = lexme
        self.literal = literal
        self.line = line
    }
    
    public static func EOF(_ line: Int) -> Token {
        return Token(type: .eof, lexme: "\\0", literal: nil, line: line)
    }
    
    public var description: String {
        return lexme
    }
    public var debugDescription: String {
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
    public func hash(into hasher: inout Hasher) {
        type.hash(into: &hasher)
        lexme.hash(into: &hasher)
        line?.hash(into: &hasher)
    }
}

public extension Token {
    /// Whether or not the specified token represents readable text
    public var isText: Bool {
        switch type {
        case .plus, .minus, .multiply, .divide, .modulus, .and, .not, .or:
            return false
        case .join, .arrow, .colon, .semicolon, .underscore, .newLine, .comma, .dot, .eof:
            return false
        case .leftPar, .rightPar, .leftBracket, .rightBracket:
            return false
        default:
            return true
        }
    }
}

public final class Lexer {
    public init(_ code: String) {
        self.code = code
        self.end = code.endIndex
    }
    let code: String
    lazy var pos = code.startIndex
    let end: String.Index
    var line = 1
    
    func isEOF() -> Bool {
        return pos == end
    }
    
    func peek() -> Character {
        return code[pos]
    }
    
    func tryPeek() -> Character? {
        return isEOF() ? nil : peek()
    }
    
    func peekNext() -> Character {
        return code[code.index(after: pos)]
    }
    
    func tryPeekNext() -> Character? {
        if isEOF() { return nil }
        let n = code.index(after: pos)
        return n < end ? code[n] : nil
    }
    
    func peekNext(_ length: Int) -> String {
        var str = ""
        var i = 1
        while i < length {
            let index = code.index(pos, offsetBy: i)
            if index < end {
                str.append(code[index])
                i += 1
            } else {
                break
            }
            if i + 1 == code.count {
                break
            }
        }
        let index = code.index(pos, offsetBy: i)
        if index < end {
            str.append(code[code.index(pos, offsetBy: i)])
        }
        return str
    }
    
    let notImp: Set<Character> = [
        " ",
        "\t"
    ]
    
    func consumeUseless() {
        while let c = tryPeek(), notImp.contains(c) {
            consume()
        }
    }
    
    func getAndConsumeStringLiteral() -> Token? {
        if isEOF() {
            return nil
        }
        var acc = "\""
        consume()
        var prev: Character?
        while let c = tryPeek() {
            if c == "\"" && prev != "\\" {
                break
            }
            acc.append(c)
            consume()
            if isEOF() {
               return nil
            }
            prev = c
        }
        consume()
        acc.append("\"")
        return token(type: .literal, lexme: acc, literal: acc)
    }
    
    func getAndConsumeNumberLiteral() -> Token {
        var acc = ""
        while let c = tryPeek(), digits.contains(c) {
            acc.append(c)
            consume()
            if isEOF() {
                break
            }
        }
        return token(type: .literal, lexme: acc, literal: Int(acc) ?? Float(acc))
    }
    
    func consume(_ count: Int = 1) {
        var i = 0
        while i < count {
            if isEOF() {
                return
            }
            pos = code.index(after: pos)
            if tryPeek() == "\n" {
                line += 1
            }
            i += 1
        }
    }
    
    func matchNext(_ character: Character) -> Bool {
        return tryPeekNext() == character
    }
    
    func match(_ string: String) -> Bool {
        return peekNext(string.count) == string
    }
    
    func read(_ str: String) -> Bool {
        if tryPeek() == str.first && match(String(str.dropFirst())) {
            consume(str.count)
            return true
        }
        return false
    }
    
    let endOfIdentifier: [Character] = [
        " ",
        ";",
        "(",
        "{",
        "\n",
        ")",
        "}",
        ",",
        "#",
        "/",
        "*",
        "-",
        "+",
        "&",
        ".",
        ":",
        "%"
    ]
    
    func scanIdentifier() -> Token? {
        var acc = ""
        while let p = tryPeek(), !endOfIdentifier.contains(p) {
            if isEOF() {
                if let c = tryPeek() { acc.append(c) }
                break
            }
            acc.append(p)
            consume()
        }
        return acc.isEmpty ? nil : Token(type: .identifier, lexme: acc, literal: nil, line: line)
    }
    
    func _couldBeNumber() -> Bool {
        guard let c = tryPeek() else { return false }
        return digits.contains(c)
    }
    
    let digits = Set<Character>(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."])
    
    func token(type: TokenType, lexme: String, literal: Any? = nil) -> Token {
        return Token(type: type, lexme: lexme, literal: literal, line: line)
    }
    
    func scanToken() -> Token? {
        consumeUseless()
        if isEOF() { return nil }
        switch peek() {
        case "/" where matchNext("/"):
            consume(2)
            while tryPeek() != "\n" {
                if isEOF() {
                    break
                }
                consume()
            }
            return token(type: .newLine, lexme: "\n")
        case ".":
            consume()
            return token(type: .dot, lexme: ".")
        case "#":
            consume()
            return token(type: .join, lexme: "#")
        case "\n":
            consume()
            return token(type: .newLine, lexme: "\n")
        case ",":
            consume()
            return token(type: .comma, lexme: ",")
        case ";":
            consume()
            return token(type: .semicolon, lexme: ";")
        case ":" where matchNext(":"):
            consume(2)
            return token(type: .scope, lexme: "::")
        case ":":
            consume()
            return token(type: .colon, lexme: ":")
        case "*":
            consume()
            return token(type: .multiply, lexme: "*")
        case "/":
            consume()
            return token(type: .divide, lexme: "/")
        case "+":
            consume()
            return token(type: .plus, lexme: "+")
        case "-" where matchNext(">"):
            consume(2)
            return token(type: .arrow, lexme: "->")
        case "-":
            consume()
            return token(type: .minus, lexme: "-")
        case "%":
            consume()
            return token(type: .modulus, lexme: "%")
        case "_" where matchNext(" ") || matchNext(","):
            consume()
            return token(type: .underscore, lexme: "_")
        case "(":
            consume()
            return token(type: .leftPar, lexme: "(")
        case ")":
            consume()
            return token(type: .rightPar, lexme: ")")
        case "{":
            consume()
            return token(type: .leftBracket, lexme: "{")
        case "}":
            consume()
            return token(type: .rightBracket, lexme: "}")
        case "=" where matchNext("="):
            consume(2)
            return token(type: .equal, lexme: "==")
        case "=":
            consume()
            return token(type: .assign, lexme: "=")
        case "!" where matchNext("="):
            consume(2)
            return token(type: .unequal, lexme: "!=")
        case "!":
            consume()
            return token(type: .not, lexme: "!")
        case "&" where matchNext("&"):
            consume(2)
            return token(type: .and, lexme: "&&")
        case "|" where matchNext("|"):
            consume(2)
            return token(type: .or, lexme: "||")
        case "@":
            consume()
            return token(type: .attribute, lexme: "@")
        case "i" where matchNext("s"):
            consume(2)
            return token(type: .typeIs, lexme: "is")
        case "v" where match("ar"):
            consume(3)
            return token(type: .varDecl, lexme: "var")
        case "s" where match("et"):
            consume(3)
            return token(type: .setDecl, lexme: "set")
        case "c" where match("onst"):
            consume(5)
            return token(type: .constDecl, lexme: "const")
        case "f" where match("unc"):
            consume(4)
            return token(type: .funcDecl, lexme: "func")
        case "p" where match("rotocol"):
            consume(8)
            return token(type: .protocolDecl, lexme: "protocol")
        case "r" where match("ef"):
            consume(3)
            return token(type: .refDecl, lexme: "ref")
        case "s" where match("truct"):
            consume(6)
            return token(type: .structDecl, lexme: "struct")
        case "i" where matchNext("f"):
            consume(2)
            return token(type: .ifDecl, lexme: "if")
        case "e" where match("lse"):
            consume(4)
            return token(type: .elseDecl, lexme: "else")
        case "t" where match("rue"):
            consume(4)
            return token(type: .literal, lexme: "true", literal: true)
        case "f" where match("alse"):
            consume(5)
            return token(type: .literal, lexme: "false", literal: false)
        case "n" where match("il"):
            consume(3)
            return token(type: .null, lexme: "nil")
        case "d" where match("ecl"):
            consume(4)
            return token(type: .propertyDecl, lexme: "decl")
        case "s" where match("elf"):
            consume(4)
            return token(type: .this, lexme: "self")
        case "n" where match("ew"):
            consume(4)
            return token(type: .initDecl, lexme: "init")
        case "l" where match("et"):
            consume(3)
            return token(type: .constDecl, lexme: "let")
        case "e" where match("xtend"):
            consume(6)
            return token(type: .extendDecl, lexme: "extend")
        case "t" where match("ypealias"):
            consume(9)
            return token(type: .typeAliasDecl, lexme: "typealias")
        case "p" where match("ublic"):
            consume(6)
            return token(type: .accessLevel, lexme: "public")
        case "p" where match("rivate"):
            consume(6)
            return token(type: .accessLevel, lexme: "private")
        case "e" where match("xposed"):
            consume(7)
            return token(type: .accessLevel, lexme: "exposed")
        case "i" where match("nternal"):
            consume(8)
            return token(type: .internalDecl, lexme: "internal")
        case "i" where match("mport"):
            consume(6)
            return token(type: .importDecl, lexme: "import")
        case "\"":
            return getAndConsumeStringLiteral()
        case _ where _couldBeNumber():
            return getAndConsumeNumberLiteral()
        default:
            return scanIdentifier()
        }
    }
    
    public func formTokens(_ tkns: inout [Token]) {
        self.pos = code.startIndex
        while let next = self.scanToken() {
            tkns.append(next)
            Log.log("Token appended to token buffer \(next.debugDescription).")
            if isEOF() {
                break
            }
        }
        tkns.append(Token.EOF(line))
        Log.log("Lexer has reached the end of file point.")
    }
}
