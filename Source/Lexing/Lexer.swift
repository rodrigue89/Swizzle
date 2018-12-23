//
//  Lexer.swift
//  
//
//  Created by Ethan Uppal on 12/23/18.
//

import Foundation

public class Lexer {
    public init(_ code: String) {
        self.code = code
    }
    let code: String
    lazy var pos = code.startIndex
    var line = 1
    
    func isEOF() -> Bool {
        return pos == code.endIndex
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
    
    func peekNext(_ length: Int) -> String {
        var str = ""
        var i = 1
        while i < length {
            str.append(code[code.index(pos, offsetBy: i)])
            i += 1
            if isEOF() {
                break
            }
        }
        str.append(code[code.index(pos, offsetBy: i)])
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
        while peek() != "\"" {
            acc.append(peek())
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
        while digits.contains(peek()) {
            acc.append(peek())
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
        return peekNext() == character
    }
    
    func match(_ string: String) -> Bool {
        return peekNext(string.count) == string
    }
    
    func read(_ str: String) -> Bool {
        if peek() == str.first && match(String(str.dropFirst())) {
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
    
    func optionalCurrent() -> Character? {
        if pos < code.endIndex {
            return code[pos]
        }
        return nil
    }
    
    func scanIdentifier() -> Token? {
        var acc = ""
        while !endOfIdentifier.contains(peek()) {
            if isEOF() {
                if let c = optionalCurrent() { acc.append(c) }
                break
            }
            acc.append(peek())
            consume()
        }
        return acc.isEmpty ? nil : Token(type: .identifier, lexme: acc, literal: nil, line: line)
    }
    
    func _couldBeNumber() -> Bool {
        return digits.contains(peek())
    }
    
    let digits = Set<Character>(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."])
    
    func scanToken() -> Token? {
        consumeUseless()
        switch peek() {
        case "/" where matchNext("/"):
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
        case "_":
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
        case "v" where match("ar"):
            consume(3)
            return Token(type: .varDecl, lexme: "var", literal: nil, line: line)
        case "l" where match("et"):
            consume(3)
            return Token(type: .constDecl, lexme: "let", literal: nil, line: line)
        case "f" where match("unc"):
            consume(4)
            return Token(type: .funcDecl, lexme: "func", literal: nil, line: line)
        case "o" where match("bjc"):
            consume(4)
            return Token(type: .objcDecl, lexme: "objc", literal: nil, line: line)
        case "i" where matchNext("f"):
            consume(2)
            return Token(type: .ifDecl, lexme: "if", literal: nil, line: line)
        case "t" where match("rue"):
            consume(4)
            return Token(type: .literal, lexme: "true", literal: nil, line: line)
        case "f" where match("alse"):
            consume(5)
            return Token(type: .literal, lexme: "false", literal: nil, line: line)
        case "n" where match("il"):
            consume(3)
            return Token(type: .null, lexme: "nil", literal: nil, line: line)
        case "d" where match("ecl"):
            consume(4)
            return Token(type: .propertyDecl, lexme: "decl", literal: nil, line: line)
        case "s" where match("elf"):
            consume(4)
            return Token(type: .this, lexme: "self", literal: nil, line: line)
        case "i" where match("nit"):
            consume(4)
            return Token(type: .initDecl, lexme: "init", literal: nil, line: line)
        case "\"":
            return getAndConsumeStringLiteral()
        case _ where _couldBeNumber():
            return getAndConsumeNumberLiteral()
        default:
            return scanIdentifier()
        }
    }
    
    public func formTokens(_ tkns: inout [Token]) -> [Token] {
        self.pos = code.startIndex
        while let next = self.scanToken() {
            tkns.append(next)
            if isEOF() {
                break
            }
        }
        tkns.append(Token.EOF)
        return tkns
    }
}
