//: Playground - noun: a place where people can play

import Foundation

public enum TokenType {
    case varDecl
    case setDecl
    case constDecl
    case funcDecl
    case objcDecl
    case ifDecl
    case elseDecl
    case initDecl
    case propertyDecl
    
    case letDecl
    case be
    case typeIs
    
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
            let index = code.index(pos, offsetBy: i)
            if code.indices.contains(index) {
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
        if code.indices.contains(index) {
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
        case "i" where matchNext("s"):
            consume(2)
            return Token(type: .typeIs, lexme: "is", literal: nil, line: line)
        case "v" where match("ar"):
            consume(3)
            return Token(type: .varDecl, lexme: "var", literal: nil, line: line)
        case "s" where match("et"):
            consume(3)
            return Token(type: .setDecl, lexme: "set", literal: nil, line: line)
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

public enum ObjectType: String {
    case implied = "*Any"
    case float = "Float"
    case string = "String"
    case bool = "Bool"
}

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

public class Statement {
    public var line: Int?
    public func accept<V: Visitor, R>(_ visitor: V) -> R where V.Result == R {
        fatalError()
    }
}

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
    
    func _makeAssignStmt(_ type: Token, _ g: [Token], _ s: inout [Statement]) throws {
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
                let expr = Expression(rep: .access(access))
                let assign = AssignStatement(decl: type, name: varName, expression: expr)
                assign.line = l
                s.append(assign)
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
                let assignStmt = AssignStatement(decl: Token(type: .varDecl, lexme: "var", literal: nil, line: nil), name: varName, expression: expr)
                assignStmt.line = l
                s.append(assignStmt)
                return
            } else {
                let call = CallStatement(name: fncName, args: args)
                let expr = Expression(rep: .call(call))
                let assignStmt = AssignStatement(decl: Token(type: .varDecl, lexme: "var", literal: nil, line: nil), name: varName, expression: expr)
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
        let set = SetStatement(object: objcName, key: key, value: expr)
        s.append(set)
    }
    
    public func formStatements(_ stmts: inout [Statement]) throws {
        reset()
        var group: [Token]?
        while !isAtEnd() {
            skipBlankLines()
            if isDebugging {
                print("Testing what statement matches:", current!)
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
            } else if current?.type == .varDecl || current?.type == .setDecl {
                let t = current!
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
                try _makeAssignStmt(t, group!, &stmts)
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
                let second = group?.dropFirst().first
                if second?.type == .dot {
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

extension Dictionary {
    public init(keys: [Key], values: [Value]) {
        self = [:]
        for (key, value) in zip(keys, values) {
            self[key] = value
        }
    }
}

extension String {
    func camelCaseToWords() -> String {
        return unicodeScalars.reduce("") {
            if CharacterSet.uppercaseLetters.contains($1) {
                return ($0 + " " + String($1))
            }
            else {
                return $0 + String($1)
            }
        }
    }
}

extension Statement {
    public func convert<S: Statement>(to type: S.Type) -> S? {
        return self as? S
    }
}

public struct ImportStatement {
    public let file: String
    public func code() -> String? {
        return IncludedLibraries.standardLibrary[file]
    }
}

public class IncludedLibraries {
    public static let Float = ObjectStatement(name: Token(type: .identifier, lexme: "Float", literal: nil, line: nil), declarations: [DeclarationStatement(name: Token(type: .identifier, lexme: "*value", literal: nil, line: nil), type: .float)])
    public static let MutableBoxFile = """
    objc MutableBox {
        decl value;
    }

    func setValue(box, value) {
        box = value;
    }
    func copyValue(box, dest) {
        dest.value = box.value;
    }
    """
    public static let TempTextFile = """
    objc TempText {
        decl String value;
    }

    func put(text, temp) {
        temp.value = text
    }
    func log(temp) {
        print(temp.value)
    }
    """
    
    public static let standardLibrary: [String:String] = [
        "MutableBox":MutableBoxFile,
        "TempText":TempTextFile
    ]
}

public class Header {
    public var imports = [ImportStatement]()
    public init?(headerCode: String) {
        for line in headerCode.components(separatedBy: "\n") {
            let components = line.components(separatedBy: " ")
            guard components.count == 2, components.last?.last == ";" else { return nil }
            guard components[0] == "import" else { return nil }
            let importStmt = ImportStatement(file: String(components[1].dropLast()))
            imports.append(importStmt)
        }
    }
}

public class Interpreter: Visitor {
    public typealias Result = [String]?
    
    struct Stack<Element>: Sequence {
        var flat = [Element]()
        mutating func push(_ newElement: Element) {
            flat.append(newElement)
        }
        mutating func pop() -> Element? {
            return flat.popLast()
        }
        mutating func removeAll() {
            flat.removeAll()
        }
        func makeIterator() -> AnyIterator<Element> {
            return AnyIterator(flat.reversed().makeIterator())
        }
    }
    public struct Queue<Element> {
        private var storage = [Element]()
        mutating public func enqueue(_ element: Element) {
            storage.append(element)
        }
        mutating public func dequeue() -> Element? {
            guard !storage.isEmpty else { return nil }
            return storage.removeFirst()
        }
        mutating public func empty() {
            storage = []
        }
        public func getFlat() -> [Element] {
            return storage
        }
        
        public var length: Int {
            return storage.count
        }
        public var isEmpty: Bool {
            return storage.isEmpty
        }
        public var last: Element? {
            return storage.last
        }
        public var next: Element? {
            return storage.first
        }
    }
    public struct Error: Swift.Error, CustomStringConvertible {
        public let message: String
        public let line: Int
        public var description: String {
            if line == -1 {
                return "\(message) (line: unknown)"
            }
            if line == -2 {
                return "\(message)"
            }
            return "\(message) (line: \(line))"
        }
        public var localizedDescription: String {
            return description
        }
    }
    public struct Function {
        public let name: String
        public let args: [String]
        public let block: (Interpreter, [String]) -> ()
        
        func _argDes() -> String {
            if args.isEmpty {
                return "()"
            } else if args == Interpreter._variL {
                return "(...)"
            } else {
                return "(\(args.map { "\($0):" }.joined()))"
            }
        }
        
        public func call(_ i: Interpreter, _ a: [Statement]) {
            var sep = true
//            print("a:", a)
            a.first?.accept(i)
            let args = a.compactMap { i.visit(stmt: $0) }.reduce([String]()) { (acc, next) -> [String] in
                if let next = next {
                    return acc + next
                } else {
                    return acc
                }
                }.reduce(into: [String]()) { (r, n) in
                    if n == "#" {
                        sep = false
                        if !r.isEmpty {
                            r[r.count - 1] = i.unstringify(r[r.count - 1])
                            if r[r.count - 1].last == " " {
                                r[r.count - 1].removeLast()
                            }
                        }
                        return
                    }
                    if sep == false {
                        if !r.isEmpty {
                            r[r.count - 1] = i.unstringify(r[r.count - 1])
                            if r[r.count - 1].last == " " {
                                r[r.count - 1].removeLast()
                            }
                        }
                        r[r.count - 1] += (i.unstringify(n) + " ")
                        sep = true
                    } else if sep == true {
                        let s = i.unstringify(n)
                        if s.first == " " {
                            r.append(" " + s + " ")
                        } else {
                            r.append(s + " ")
                        }
                        
                    }
            }
            block(i, args)
            i.logMsg("Function '\(name)\(_argDes())' was executed.")
        }
    }
    public struct Object: CustomStringConvertible {
        public let name: String
        public var values: [String:String]
        let stmt: InitStatement
        public var description: String {
            return "\(name)(\(values.map({ "\($0.key): \($0.value)" }).joined(separator: ", ")))"
        }
        
    }
    
    static let _variL = ["*VARIABLE_LENGTH"]
    
    let code: String
    var statements = [Statement]()
    public var stackTrace: Bool
    public var alwaysTraverseDebug: Bool = false
    public var header: Header?
    
    public init(code: String, debug: Bool = false, stackTrace: Bool) throws {
        self.formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        
        self.code = code
        self.stackTrace = stackTrace
        configureDefaults()
        let lexer = Lexer(code)
        var tokens = [Token]()
        lexer.formTokens(&tokens)
        if debug {
            print("Tokens:", tokens)
        }
        let parser = Parser(stream: tokens)
        parser.isDebugging = debug
        do {
            try parser.formStatements(&statements)
        }
        catch {
            let words = String(describing: error).camelCaseToWords().capitalized
            throw Error(message: words, line: parser.currentLine())
        }
        if debug {
            print("Statements:", statements)
        }
    }
    
    
    
    // MARK: Standard Library
    let printSeperator = ""
    let printTerminator = "\n"
    
    func configureDefaults() {
        statements.append(IncludedLibraries.Float)
        
        addFunc("print", Interpreter._variL) { (i, args) in
            var result = ""
            for index in args.indices {
                let val = self.unstringify(args[index])
                if index + 1 == args.endIndex {
                    result += val
                } else {
                    result += val + self.printSeperator
                }
            }
            print(self.frmPfx, result, separator: "", terminator: self.printTerminator)
        }
        //        addFunc("blahblah") { (i, args) in
        //            print("B%^&TRCedu7r6&u5r5u7%E&%euv75eVUY")
        //        }
    }
    
    func addFunc(_ name: String, _ args: [String], _ block: @escaping (Interpreter, [String]) -> ()) {
        functions[name] = Function(name: name, args: args, block: block)
    }
    
    func varValue(named name: String) -> AssignStatement? {
        return variables[name]
    }
    
    func unstringify(_ str: String) -> String {
        var str = str
        if str.first == "\"" {
            str.removeFirst()
        }
        if str.last == "\"" {
            str.removeLast()
        }
        return str
    }
    
    func makeObject(from constr: InitStatement, objcName: String) {
        let name = constr.objectName.lexme
        logMsg("Constructing an object with type of '\(name)' and storing in variable named '\(objcName)'.")
        let args = constr.args.compactMap { visit($0) }
        let reduced = args.reduce([String]()) { $0 + $1 }
        guard let names = objectDecls[name]?.declarations.map({ $0.name.lexme }) else { return }
        let given = constr.args.count
        let expected = names.count
        if given != expected {
            logMsg("The entered argument count does not match the expected argument count.", ui: "Given: \(given), Expected: \(expected)")
            reportError("Expected \(expected) argument\(expected == 1 ? "" : "s") in initializer")
        }
        let values = Dictionary(keys: names, values: reduced)
        let object = Object(name: name, values: values, stmt: constr)
        objects[objcName] = object
    }
    
    var objectDecls = [String:ObjectStatement]()
    var objects = [String:Object]()
    var variables = [String:AssignStatement]()
    var functions = [String:Function]()
    
    var stack = Stack<String>()
    
    public func visit(_ call: CallStatement) -> Interpreter.Result {
        let end = call.line != nil ? " at line \(call.line!)" : ""
        let callName = call.name.lexme
        let callArgs = call.args
        logMsg("Visiting a function call\(end)", true, ui: "Call: \(callName) with args: \(callArgs).")
        _ = functions[callName]?.call(self, callArgs) != nil
        
        return nil
    }
    public func visit(_ access: AccessStatement) -> Interpreter.Result {
        let objectName = access.object.lexme
        let objectKey = access.key.lexme
        if let val = objects[objectName]?.values[objectKey] {
            return [val]
        }
        return nil
    }
    public func visit(_ constr: InitStatement) -> Interpreter.Result {
        guard let objcName = stack.pop() else { return nil }
        makeObject(from: constr, objcName: objcName)
        return nil
    }
    public func visit(_ objc: ObjectStatement) -> Interpreter.Result {
        objectDecls[objc.name.lexme] = objc
        return nil
    }
    public func visit(_ decl: DeclarationStatement) -> Interpreter.Result {
        return nil
    }
    public func visit(_ expr: Expression) -> Interpreter.Result {
        logMsg("Getting data from expression.", ui: "Data: \(expr)")
        let rep = expr.rep
        if let tkn = rep.anyToken {
            let name = tkn.lexme
            if let object = objects[name], let val = object.values["*value"] {
                return [val]
            } else if let assign = variables[name], let result = assign.value.accept(self) {
//                print("expr visit access rep:", assign.value.rep)
                return result
            }
            return [name]
        } else if let literal = rep.literal {
            return [String(describing: literal)]
        } else if rep.call != nil {
            // TODO: Allow function creation with returns
        } else if let access = rep.access {
            return visit(access)
        } else if let list = rep.list {
            return list.map { $0.lexme }
        }
        return nil
    }
    public func visit(_ assign: AssignStatement) -> Interpreter.Result {
        let varName = assign.name.lexme
        logMsg("Setting value to the variable '\(varName)'.", ui: "Statement: \(assign)")
        if assign.decl.type == .varDecl && variables[varName] != nil {
            logMsg("Cannot assign to already initilaized.", ui: "Already created value: \(variables[varName]!)")
            reportError("Cannot create the variable \(varName) because it already exists, did you mean to use 'set' instead?")
            return nil
        } else if assign.decl.type == .setDecl && variables[varName] == nil {
            logMsg("Cannot assign to nothing.")
            reportError("Cannot set to \(varName) because \(varName) does not exist yet, did you mean to use 'var' instead?")
            return nil
        }
        variables[varName] = assign
        stack.push(varName)
        let rep = assign.value.rep
        if let call = rep.call {
            logMsg("Represents a call.")
            call.accept(self)
        } else if let constr = rep.constr {
            logMsg("Represents a constructor.")
            constr.accept(self)
        } else if let lit = rep.literal {
            if let num = lit as? Float {
                let `init` = InitStatement(objectName: IncludedLibraries.Float.name, args: [Expression(rep: .literal(num))])
                let object = Object(name: "Float", values: ["*value":num.description], stmt: `init`)
                objects[varName] = object
            }
        } else if let access = rep.access {
            return access.accept(self)
        }
        return nil
    }
    public func visit(_ set: SetStatement) -> Interpreter.Result {
        logMsg("Setting and editing an object.")
        objects[set.object.lexme]?.values[set.key.lexme] = visit(set.value)?.first
        return nil
    }
    public func visit(_ binary: BinaryExpression) -> Interpreter.Result {
        return nil
    }
    public func visit(_ cond: IfStatement) -> [String]? {
        let condition = visit(cond.condition)?.first
        logMsg("Visiting IfStatement", true, ui: "Evaluating if statement to choose what code to run")
        if condition == "true" {
            for stmt in cond.ifTrue {
                visit(stmt: stmt)
                if let error = error {
                    reportError(error)
                }
            }
        } else if condition == "false" {
            for stmt in cond.ifFalse {
                visit(stmt: stmt)
                if let error = error {
                    reportError(error)
                }
            }
        } else {
            reportError("Expected true or false return value for expression in if statement")
        }
        return nil
    }
    
    var logs = Queue<String>()
    var info = [Int:Debug]()
    var triggers = Queue<Int>()
    var _onTrigger = false
    
    func _resetST() {
        logs.empty()
        triggers.empty()
        _onTrigger = false
        _lastCaller = nil
        _frame = 1
        info.removeAll()
    }
    
    var frmPfx: String {
        if self.stackTrace {
            return "Frame #\(_frame): "
        } else {
            return ""
        }
    }
    
    func logMsg(_ msg: String, _ trigger: Bool = false, _ c: Int = 1, ui: String? = nil) {
        if stackTrace {
            let end = _onTrigger ? " (caller: frame #\(triggers.dequeue() ?? -1))" : ""
            let m = "*** \(frmPfx)\(msg)\(end)"
            logs.enqueue(m)
            if let ui = ui {
                info[_frame] = Debug(trigger: _lastCaller, log: msg, info: ui)
            }
            if trigger {
                for _ in 0 ..< c { triggers.enqueue(_frame) }
                _lastCaller = _frame
                _onTrigger = true
            } else {
                _onTrigger = false
            }
            _frame += 1
        }
    }
    
    var _frame = 0
    var _lastCaller: Int?
    
    func nowhite(_ s: String) -> String {
        var trailing = s.drop(while: { $0 == " " })
        while trailing.last == " " {
            trailing.removeLast()
        }
        return String(trailing)
    }
    
    public func visit(_ funct: FunctionStatement) -> [String]? {
        let funcName = funct.name.lexme
        logMsg("Visiting declaration of '\(funcName)(_:)'.", ui: "Statement: \(funct)")
        let args = funct.args.map { $0.lexme }
        let argCount = args.count
        let body = funct.body
        let function = Function(name: funcName, args: args) { [unowned self] (i, a) in
            guard argCount == a.count && !(args == Interpreter._variL) else {
                if self.stackTrace {
                    self.logMsg("Incorrect number of arguments. Expected \(argCount), given: \(a.count).", ui: "Input arguments: \(a), required arguments: \(args).")
                    self.logMsg("Arguments are not variable length.", ui: "Only varible length functions can have variable amounts of input arguments.")
                }
                self.reportError("Expected \(argCount) argument\(argCount == 1 ? "" : "s") in function call to '\(funcName)(_:)'")
                return
            }
            for statement in body {
                if let call = statement as? CallStatement {
                    var i = 0
                    var ua = 0
                    var newArgs = [Expression]()
//                    print("Orig args:", call.args)
                    call.args.forEach { (expr) in
                            if let n = expr.rep.anyToken?.lexme {
                                if ua < a.endIndex,  n == args[ua] {
                                    let result = Token(type: TokenType.literal, lexme: a[ua], literal: nil, line: nil)
                                    let newExpr = Expression(rep: .anyToken(result))
                                    self.visit(newExpr)
                                    newArgs.append(newExpr)
                                    ua += 1
                                } else {
                                    newArgs.append(expr)
                                }
                                
                            } else if let access = expr.rep.access {
                                access
                                guard let index = args.index(where: { $0 == access.object.lexme }) else {
                                    self.reportError("Unresolved identifier '\(access.key.lexme)'")
                                    return
                                    
                                }
                                
                                /*guard */let objcName = self.nowhite(a[index])/*.rep.anyToken?.lexme else {
                                    self.reportError("Unknown object")
                                    return
                                }*/
                                
                                guard let val = self.objects[objcName]?.values[access.key.lexme] else {
                                    self.reportError("Unknown property '\(access.key.lexme)'")
                                    return
                                }
                                let result = Token(type: .literal, lexme: val, literal: val, line: nil)
                                let newExpr = Expression(rep: .anyToken(result))
                                self.visit(newExpr)
                                newArgs.append(newExpr)
                                ua += 1
                        }
                        i += 1
                    }
//                    print("New Args for \(funcName):", newArgs)
                    let newCall = CallStatement(name: call.name, args: newArgs)
                    self.visit(newCall)
                } else if let cond = statement as? IfStatement {
                    
                }
//                self.visit(stmt: statement)
            }
        }
        functions[funcName] = function
        return nil
    }
    
    public typealias FunctionTupleInput = (interpreter: Interpreter, args: [String])
    public func registerExternalFunction(name: String, block: @escaping (FunctionTupleInput) -> ()) {
        addFunc(name, Interpreter._variL, block)
    }
    
    var error: String?
    
    public func reportError(_ msg: String) {
        error = msg
    }
    
    func logAll() {
        if stackTrace {
            print("\nTrace:")
            print("------")
            while let msg = logs.dequeue() {
                print(msg)
            }
            if alwaysTraverseDebug {
                traverseStackTrace {
                    $0.printToConsole()
                }
            }
        }
    }
    
    let formatter: NumberFormatter
    
    public func execute() throws {
        _resetST()
        if let importStmts = self.header?.imports {
            for stmt in importStmts {
                logMsg("Importing \"\(stmt.file)\"")
                if let code = stmt.code() {
                    let l = Lexer(code)
                    var t = [Token]()
                    l.formTokens(&t)
                    var p = Parser(stream: t)
                    var s = [Statement]()
                    try p.formStatements(&s)
                    for stmt in s {
                        self.visit(stmt: stmt)
                        if error != nil {
                            throw Error(message: "Error importing file", line: -2)
                        }
                    }
                }
            }
        }
        error = nil
        var i = 0
        for statement in statements {
            logMsg("\(formatter.string(from: i + 1 as NSNumber) ?? (i == statements.count ? "Last" : i == 0 ? "First" : "Next")) iteration: \(type(of: statement))")
            self.visit(stmt: statement)
            if let error = error {
                logAll()
                throw Error(message: error, line: -2)
            }
            i += 1
        }
        logAll()
    }
    
    public struct Debug {
        public let trigger: Int?
        public let log: String
        public let info: String?
        public init(trigger: Int?, log: String, info: String?) {
            self.trigger = trigger
            self.log = log
            self.info = info
        }
        
        public var printInfo = false
        public func printToConsole() {
            var des = "Debug("
            if let trigger = trigger {
                des += "[caller = frame #\(trigger)] "
            }
            des += "\"\(log)\""
            if let info = info, printInfo {
                des += ", info: \"\(info)\""
            }
            des.append(")")
            print(des)
        }
    }
    
    public func debug(frame: Int) -> Debug? {
        return info[frame]
    }
    public func traverseStackTrace(by body: @escaping (Debug) -> ()) {
        print("\nDebug:")
        print("------")
        for (_, debug) in info.sorted(by: { $0.key < $1.key }) {
            body(debug)
        }
    }
    public func clearDebug() {
        info.removeAll()
    }
}

public class CodeFile {
    let code: String
    
    public struct Error: CustomStringConvertible, Swift.Error {
        public var description: String
        public var localizedDescription: String {
            return description
        }
    }
    public init(directory: FileManager.SearchPathDirectory, path: String) throws {
        guard path.hasSuffix(".sw") else { throw Error(description: "Expected '.sw' as the file type") }
        guard let url = FileManager.default.urls(for: directory, in: .userDomainMask).first?.appendingPathComponent(path) else { throw Error(description: "Could not find file at \(path)") }
        self.code = try String(contentsOf: url)
    }
    public struct Options: OptionSet {
        public static let debug = Options(rawValue: 1)
        public static let stackTrace = Options(rawValue: 2)
        public static let traverseDebug = Options(rawValue: 4)
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    public var options: Options = [.stackTrace]
    public func run() throws -> Interpreter {
        let i = try Interpreter(code: code, debug: options.contains(.debug), stackTrace: options.contains(.stackTrace))
        i.alwaysTraverseDebug = options.contains(.traverseDebug)
        try i.execute()
        return i
    }
}

let code = """
print("Hello, world");
"""

do {
    let i = try Interpreter(code: code, debug: false, stackTrace: true)
    do {
        try i.execute()
    }
    catch {
        print(error)
    }
    
}
catch {
    print(error)
}







