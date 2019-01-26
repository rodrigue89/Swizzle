//
//  Lexer.swift
//  
//
//  Created by Ethan Uppal on 12/23/18.
//

import Foundation

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
    
    func getAndConsumeStringLiteral() -> Token {
        var acc = "\""
        consume()
        while let c = tryPeek(), c != "\"" {
            acc.append(c)
            consume()
            if isEOF() {
                break
            }
        }
        consume()
        acc.append("\"")
        return Token(type: .literal, lexme: acc, literal: acc, line: line)
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
        return Token(type: .literal, lexme: acc, literal: Float(acc), line: line)
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
        "."
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
            //consume()
            return Token(type: .newLine, lexme: "\n", literal: nil, line: line)
        case ".":
            consume()
            return Token(type: .dot, lexme: ".", literal: nil, line: line)
        case "#":
            consume()
            return Token(type: .join, lexme: "#", literal: nil, line: line)
        case "\n":
            consume()
            return Token(type: .newLine, lexme: "\n", literal: nil, line: line)
        case ",":
            consume()
            return Token(type: .comma, lexme: ",", literal: nil, line: line)
        case ";":
            consume()
            return Token(type: .semicolon, lexme: ";", literal: nil, line: line)
        case "*":
            consume()
            return Token(type: .multiply, lexme: "*", literal: nil, line: line)
        case "/":
            consume()
            return Token(type: .divide, lexme: "/", literal: nil, line: line)
        case "+":
            consume()
            return Token(type: .plus, lexme: "+", literal: nil, line: line)
        case "-":
            consume()
            return Token(type: .minus, lexme: "-", literal: nil, line: line)
        case "_" where matchNext(" ") || matchNext(","):
            consume()
            return Token(type: .underscore, lexme: "_", literal: nil, line: line)
        case "(":
            consume()
            return Token(type: .leftPar, lexme: "(", literal: nil, line: line)
        case ")":
            consume()
            return Token(type: .rightPar, lexme: ")", literal: nil, line: line)
        case "{":
            consume()
            return Token(type: .leftBracket, lexme: "{", literal: nil, line: line)
        case "}":
            consume()
            return Token(type: .rightBracket, lexme: "}", literal: nil, line: line)
        case "=" where matchNext("="):
            consume(2)
            return Token(type: .equal, lexme: "==", literal: nil, line: line)
        case "=":
            consume()
            return Token(type: .assign, lexme: "=", literal: nil, line: line)
        case "!" where matchNext("="):
            consume(2)
            return Token(type: .unequal, lexme: "!=", literal: nil, line: line)
        case "!":
            consume()
            return Token(type: .not, lexme: "!", literal: nil, line: line)
        case "&" where matchNext("&"):
            consume(2)
            return Token(type: .and, lexme: "&&", literal: nil, line: line)
        case "|" where matchNext("|"):
            consume(2)
            return Token(type: .or, lexme: "||", literal: nil, line: line)
        case "i" where matchNext("s"):
            consume(2)
            return Token(type: .typeIs, lexme: "is", literal: nil, line: line)
        case "v" where match("ar"):
            consume(3)
            return Token(type: .varDecl, lexme: "var", literal: nil, line: line)
        case "s" where match("et"):
            consume(3)
            return Token(type: .setDecl, lexme: "set", literal: nil, line: line)
        case "c" where match("onst"):
            consume(5)
            return Token(type: .constDecl, lexme: "const", literal: nil, line: line)
        case "f" where match("unc"):
            consume(4)
            return Token(type: .funcDecl, lexme: "func", literal: nil, line: line)
        case "i" where match("mpl"):
            consume(4)
            fatalError("WIP")
        case "o" where match("bjc"):
            consume(4)
            return Token(type: .objcDecl, lexme: "objc", literal: nil, line: line)
        case "i" where matchNext("f"):
            consume(2)
            return Token(type: .ifDecl, lexme: "if", literal: nil, line: line)
        case "e" where match("lse"):
            consume(4)
            return Token(type: .elseDecl, lexme: "else", literal: nil, line: line)
        case "t" where match("rue"):
            consume(4)
            return Token(type: .literal, lexme: "true", literal: true, line: line)
        case "f" where match("alse"):
            consume(5)
            return Token(type: .literal, lexme: "false", literal: false, line: line)
        case "n" where match("il"):
            consume(3)
            return Token(type: .null, lexme: "nil", literal: nil, line: line)
        case "d" where match("ecl"):
            consume(4)
            return Token(type: .propertyDecl, lexme: "decl", literal: nil, line: line)
        case "s" where match("elf"):
            consume(4)
            return Token(type: .this, lexme: "self", literal: nil, line: line)
        case "n" where match("ew"):
            consume(4)
            return Token(type: .initDecl, lexme: "init", literal: nil, line: line)
        case "l" where match("et"):
            consume(3)
            return Token(type: .letDecl, lexme: "let", literal: nil, line: line)
        case "b" where matchNext("e"):
            consume(2)
            return Token(type: .be, lexme: "be", literal: nil, line: line)
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
            if isEOF() {
                break
            }
        }
        tkns.append(Token.EOF)
    }
}
