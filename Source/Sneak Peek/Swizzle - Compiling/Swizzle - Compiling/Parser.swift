//
//  swift
//  Swizzle - Compiling
//
//  Created by Ethan Uppal on 1/13/19.
//  Copyright © 2019 Ethan Uppal. All rights reserved.
//

import Cocoa

extension String {
    func camelCaseToWords() -> String {
        if isEmpty {
            return ""
        }
        var des = ""
        for index in self.indices {
            if index == startIndex {
                des += self[index].description.capitalized
            } else {
                let char = self[index]
                if "A" ... "Z" ~= char {
                    des.append(" \(char.description.lowercased())")
                } else {
                    des.append(char)
                }
            }
        }
        return des
    }
}

// Taken from https://stackoverflow.com/a/51516302
extension Double {
    func toString(decimal: Int = 9) -> String {
        let value = decimal < 0 ? 0 : decimal
        var string = String(format: "%.\(value)f", self)
        
        while string.last == "0" || string.last == "." {
            if string.last == "." { string = String(string.dropLast()); break}
            string = String(string.dropLast())
        }
        return string
    }
}

// Hacky way for single class stacks
protocol _ResolverStack {
    static var currentStructs: Set<String> { get set }
    var structNames: Set<String> { get }
    var parent: Self? { get }
    func new() -> Self
}
extension _ResolverStack {
    mutating func back() {
        if let p = parent {
            Self.currentStructs.subtract(structNames)
            self = p
        }
    }
    mutating func formNew() {
        self = new()
    }
}

extension _ResolverStack where Self: AnyObject {
    func setStructs() {
        Self.currentStructs.formUnion(structNames)
    }
}

public final class Parser {
    public struct Error: LocalizedError {
        public enum Message {
            // Parser
            case groupNotClosed
            case expectedStartingBracket
            case expectedClosingBracket
            case expectedIdentifier
            case unresolvedIdentifier
            case expectedType
            case expectedDeclaration
            case unexpectedToken
            case unexpectedEndOfFile
            case unexpectedNewLine
            case expectedSemicolon
            case expectedAssignment
            case expectedLiteral
            case expectedStartingGroup
            case expectedClosingGroup
            case expectedSeparator
            case expectedParameter
            case expectedReference
            case unknownAccessLevel
            case invalidAttribute
            case unknownAttribute
            case anyError
            
            // Resolver
            case functionAlreadyExists
            case objectAlreadyExists
            case variableAlreadyExists
            case protocolAlreadyExists
            case unknownType
            case variableDoesNotExist
            
            public var customMessage: String? {
                switch self {
                case .anyError:
                    return "Failed to compile code"
                case .expectedReference:
                    return "Expected reference in struct"
                case .unknownAccessLevel:
                    return "Unknown access level: Valid access levels are \(AccessLevel.allCases.map({ $0.rawValue }).joined(separator: ", "))"
                    //                    case .unexpectedEndOfFile:
                //                        return "Cannot allow a new line in the statement"
                default:
                    return nil
                }
            }
            public var description: String {
                return customMessage ?? "\(self)".camelCaseToWords()
            }
        }
        public let msg: Message
        public let line: Int
        public let token: Token?
        public let scope: StaticString?
        public let sourceFileName: String?
        public var errorDescription: String? {
            let scopeDescription: String = String((scope ?? "nil").description.camelCaseToWords().prefix { $0 != "(" })
            var des = msg.description + " ("
            if let token = token, token.isText {
                des += "token: \(token.lexme), "
            }
            return des + "line: \(line), scope: \(scopeDescription))"
        }
        
        func gnu_errorFormat(startingWith start: String, distance: Int?) -> String {
            var des = start
            if let sourceFileName = self.sourceFileName {
                des.append(sourceFileName + ":")
            }
            var distDes = ""
            if let dist = distance {
                distDes += ":\(dist)"
            }
            des += "\(line)\(distDes): \(msg.description)"
            return des
        }
        func prettyRepOfPosition(_ des: inout String, source: String) -> Int? {
            var distance: Int?
            if let tokenText = token?.lexme.replacingOccurrences(of: "\t", with: "    ") {
                Swift.print(tokenText)
                if let tokenRange = source.range(of: tokenText) {
                    distance = source.distance(from: source.startIndex, to: tokenRange.lowerBound)
                    des += repeatElement(" ", count: distance!)
                    des.append("^\n")
                }
            }
            return distance
        }
        
        public func detailedDescription(inCode code: String) -> String {
            if token?.type == .eof || msg == .unexpectedEndOfFile {
                return "Could not complete the statement becuse the compiler has reached the end of the file"
            }
            if line == -1 {
                switch msg {
                default:
                    return Message.anyError.description
                }
            }
            let flag: String = "Line is greater than or equal to 0"
            let lines = code.components(separatedBy: .newlines)
            let source = lines[line - 1].replacingOccurrences(of: "\t", with: "    ")
            var des = source + "\n"
            return gnu_errorFormat(startingWith: des, distance:prettyRepOfPosition(&des, source: source))
        }
    }
    
    public final class Resolver: _ResolverStack {
        static var currentStructs = Set<String>()
        
        let parser: Parser
        weak var parent: Resolver?
        public init(parser: Parser, parent: Resolver?) {
            self.parser = parser
            self.parent = parent
        }
        
        // FIXME: Use `StdLib.all.map` instead
        var structNames = Set(Reserved.structs) {
            didSet {
                setStructs()
            }
        }
        var variableNames = Set<String>()
        var functionNames = [String:Int]()
        var protocolNames = Set<String>()
        
        func error(_ msg: Error.Message, _ tkn: Token, src: String? = nil) -> Error {
            return Error(msg: msg, line: tkn.line ?? -1, token: tkn, scope: parser.scope, sourceFileName: src)
        }
        
        // Check existance
        public func resolveFunctionName(_ name: Token, _ arity: Int) throws {
            guard functionNames[name.lexme] != arity else {
                throw error(.functionAlreadyExists, name)
            }
            if structNames.contains(name.lexme) {
                throw error(.objectAlreadyExists, name)
            }
            if protocolNames.contains(name.lexme) {
                throw error(.protocolAlreadyExists, name)
            }
            if variableNames.contains(name.lexme) {
                throw error(.variableAlreadyExists, name)
            }
        }
        public func resolveStructName(_ name: Token, _ arity: Int) throws {
            guard structNames.insert(name.lexme).inserted else {
                throw error(.objectAlreadyExists, name)
            }
            if protocolNames.contains(name.lexme) {
                throw error(.protocolAlreadyExists, name)
            }
            if functionNames[name.lexme] == arity {
                throw error(.functionAlreadyExists, name)
            }
        }
        public func resolveVariableName(_ name: Token) throws {
            guard variableNames.insert(name.lexme).inserted else {
                throw error(.variableAlreadyExists, name)
            }
            if functionNames[name.lexme] != nil {
                throw error(.functionAlreadyExists, name)
            }
        }
        public func resolveProtocolName(_ name: Token) throws {
            guard protocolNames.insert(name.lexme).inserted else {
                throw error(.protocolAlreadyExists, name)
            }
            if structNames.contains(name.lexme) {
                throw error(.objectAlreadyExists, name)
            }
            if functionNames[name.lexme] != nil {
                throw error(.functionAlreadyExists, name)
            }
        }
        
        public func functionNameIsValid(_ name: Token, _ arity: Int) -> Bool {
            return functionNames[name.lexme] == arity || parent?.functionNameIsValid(name, arity) ?? false
        }
        public func objectNameIsValid(_ name: Token) throws {
            if !structNames.contains(name.lexme) {
                if let parent = self.parent {
                    try parent.objectNameIsValid(name)
                } else {
                    throw error(.unknownType, name)
                }
            }
        }
        public func protocolNameIsValid(_ name: Token) throws {
            if !protocolNames.contains(name.lexme) {
                if let parent = self.parent {
                    try parent.protocolNameIsValid(name)
                } else {
                    throw error(.unknownType, name)
                }
            }
        }
        public func variableNameIsValid(_ name: Token) throws {
            if !variableNames.contains(name.lexme) {
                if let parent = self.parent {
                    try parent.variableNameIsValid (name)
                } else {
                    throw error(.variableDoesNotExist, name)
                }
            }
        }
        
        public func new() -> Resolver {
            return Resolver(parser: parser, parent: self)
        }
    }
    
    let stream: [Token]
    var pos = 0
    var srcName: String?
    var isEOS: Bool { return pos == stream.endIndex }
    public lazy var resolver = Resolver(parser: self, parent: nil)
    public var debug = false
    var scope: StaticString?
    
    public init(stream: [Token], sourceFileName: String?) {
        self.stream = stream
        self.srcName = sourceFileName
    }
    
    var current: Token? {
        return isEOS ? nil : stream[pos]
    }
    
    func reset() {
        pos = 0
    }
    func consume(_ n: Int = 1) {
        pos += n
    }
    func backwards(_ n: Int = 1) {
        pos -= n
    }
    func peek() -> Token {
        return stream[pos]
    }
    func ahead(_ n: Int = 1) -> Token? {
        let newIndex = pos + n
        return newIndex < stream.endIndex ? stream[newIndex] : nil
    }
    
    func ErrorFC(_ msg: Error.Message, _ tkn: Token? = nil) -> Error {
        return Error(msg: msg, line: current?.line ?? -1, token: tkn ?? current, scope: scope, sourceFileName: srcName)
    }
    func error(for type: TokenType) throws -> Never {
        switch type {
        case .identifier:
            throw ErrorFC(.expectedIdentifier)
        case .literal:
            throw ErrorFC(.expectedLiteral)
        case .semicolon:
            throw ErrorFC(.expectedSemicolon)
        case .assign:
            throw ErrorFC(.expectedAssignment)
        case .leftBracket:
            throw ErrorFC(.expectedStartingBracket)
        case .rightBracket:
            throw ErrorFC(.expectedClosingBracket)
        case .leftPar:
            throw ErrorFC(.expectedStartingGroup)
        case .rightPar:
            throw ErrorFC(.expectedClosingGroup)
        case .propertyDecl:
            throw ErrorFC(.expectedDeclaration)
        case .comma:
            throw ErrorFC(.expectedSeparator)
        case .refDecl:
            throw ErrorFC(.expectedReference)
        case .newLine:
            throw ErrorFC(.unexpectedNewLine)
        default:
            throw ErrorFC(.unexpectedToken)
        }
    }
    
    func skip(_ types: Set<TokenType>) {
        while let tkn = current, types.contains(tkn.type) {
            consume()
        }
    }
    func match(_ type: TokenType) -> Bool {
        return current?.type == type
    }
    func match_t(_ types: Set<TokenType>) -> Bool {
        guard let type = current?.type else { return false }
        return types.contains(type)
    }
    func nextIs(_ type: TokenType) -> Bool {
        let next = pos + 1
        return next < stream.count ? (stream[next].type == type) : false
    }
    func eat(_ type: TokenType) throws -> Bool {
        guard match(type) else {
            try error(for: type)
        }
        consume()
        return true
    }
    func eat_t(_ types: Set<TokenType>) throws -> Bool {
        for type in types {
            if current?.type == type {
                consume()
                return true
            }
        }
        throw ErrorFC(.unexpectedToken)
    }
    func get(_ type: TokenType) throws -> Token {
        guard let tkn = current else {
            throw ErrorFC(.unexpectedEndOfFile)
        }
        if tkn.type == type {
            consume()
            return tkn
        }
        try error(for: type)
    }
    
    // Avoid repitition
    func semicolon() throws {
        _ = try eat(.semicolon)
    }
    func id() throws -> Token {
        return try get(.identifier)
    }
    func skipLines() {
        skip([.newLine])
    }
    
    // Overload `print`
    func print(_ vals: Any...) {
        guard debug else { return }
        let string = vals.map { "\($0)" }.joined(separator: " ")
        Log.log("Parser requested print: \(string)")
        if let des = scope?.description {
            Swift.print(des + ": ", terminator: "")
        }
        Swift.print(string)
    }
    
    // MARK: Parsing
    
    typealias Subgroup = [Token]
    typealias Group = [Subgroup]
    
    func singleToken(_ subgroup: Subgroup) throws -> Token {
        // Set scope
        scope = #function
        
        var i = subgroup.makeIterator()
        guard let tkn = i.next() else {
            fatalError("Should not happen")
        }
        guard i.next() == nil else {
            throw ErrorFC(.unexpectedToken)
        }
        return tkn
    }
    
    func _useAttribute(_ attr: Attribute) throws {
        // Set scope
        scope = #function
        
        let name = attr.name
        let params = attr.params
        switch name.lexme {
        case "resolve":
            print(params)
            for param in params {
                switch param.literal {
                case is String:
                    print("Resolving type: \(param.lexme)")
                    try resolver.resolveStructName(param, -1)
                default:
                    throw ErrorFC(.expectedLiteral, param)
                }
            }
        default:
            throw ErrorFC(.unknownAttribute)
        }
    }
    func parseAttribute() throws {
        // Set scope
        scope = #function
        
        consume()
        let attributeName = try id()
        var params = [Token]()
        if match(.leftPar) {
            consume()
            params = try parseCommaSeperated(end: [.rightPar]).compactMap {
                var iterator = $0.makeIterator()
                guard let id = iterator.next() else { return nil }
                guard iterator.next() == nil else { throw ErrorFC(.unexpectedToken) }
                return id
            }
        }
        let attribute = Attribute(name: attributeName, params: params)
        try _useAttribute(attribute)
    }
    
    func expressionRep(for tkn: Token) throws -> Expression.Rep {
        switch tkn.literal {
        case let string as String:
            return .string(string)
        case let float as Float:
            return .float(float)
        case let int as Int:
            return .int(int)
        case let bool as Bool:
            return .bool(bool)
        default:
            throw ErrorFC(.expectedLiteral)
        }
    }
    
    func makeExpression(_ group: Subgroup) throws -> Expression {
        // Set scope
        scope = #function
        
        print("\(group)")
        switch group.count {
        case 1:
            let tkn = group[0]
            switch tkn.type {
            case .literal:
                return Expression(rep: try expressionRep(for: tkn))
            default:
                return Expression(rep: .token(tkn))
            }
        case 3 where group[1].type == .dot:
            let access = AccessStatement(object: group[0], key: group[2])
            return Expression(rep: .access(access))
        case 3... where group[1].type == .leftPar:
            let name = group[0]
            guard name.type == .identifier else {
                throw ErrorFC(.expectedIdentifier)
            }
            let args = try parseCommaSeperated(in: Subgroup(group[1...]), end: [.rightPar]).map(makeExpression)
            let call = CallStatement(name: name, args: args)
            return Expression(rep: .call(call))
        default:
            throw ErrorFC(.anyError)
        }
    }
    func makeParameter(_ subgroup: Subgroup) throws -> ParameterStatement {
        // Set scope
        scope = #function
        
        guard subgroup.count == 3 else {
            throw ErrorFC(.expectedParameter)
        }
        let name = subgroup[0]
        let type = subgroup[2]
        guard name.type == .identifier else {
            throw ErrorFC(.expectedIdentifier)
        }
        guard subgroup[1].type == .colon, type.type == .identifier else {
            throw ErrorFC(.expectedType)
        }
        try resolver.objectNameIsValid(subgroup[2])
        return ParameterStatement(name: name, type: type)
    }
    
    func parseExpression(end: Set<TokenType>) throws -> Expression {
        // Set scope
        scope = #function
        
        var tokens = [Token]()
        while !match_t(end) {
            if isEOS { throw ErrorFC(.unexpectedEndOfFile) }
            tokens.append(current!)
            consume()
        }
        consume()
        return try makeExpression(tokens)
    }
    func parseStatementWithIdentifier() throws -> Statement {
        // Set scope
        scope = #function
        
        if nextIs(.leftPar) {
            return try parseCall()
        }
        throw ErrorFC(.anyError)
    }
    
    func parseCommaSeperated(end: Set<TokenType>) throws -> Group {
        // Set scope
        scope = #function
        
        var group = Group()
        var acc = Subgroup()
        var onComma = true
        while let tkn = current, !end.contains(tkn.type) {
            if tkn.type == .eof { throw ErrorFC(.unexpectedEndOfFile) }
            if tkn.type == .comma {
                guard !onComma else {
                    throw ErrorFC(.unexpectedToken)
                }
                onComma = true
                print("Final argument is \(acc)")
                group.append(acc)
                acc = []
                consume()
                skipLines()
                continue
            }
            print("\(acc) appends `\(tkn)`  for argument")
            onComma = false
            acc.append(tkn)
            consume()
        }
        if !acc.isEmpty {
            print("Final argument is \(acc)")
            group.append(acc)
            acc = []
        }
        _ = try eat_t(end)
        return group
    }
    
    func parseCommaSeperated(in group: Subgroup, end: Set<TokenType>) throws -> Group {
        // Set scope
        scope = #function
        
        var i = group.makeIterator()
        
        var group = Group()
        var acc = Subgroup()
        var onComma = true
        while let tkn = i.next(), !end.contains(tkn.type) {
            if tkn.type == .comma {
                guard !onComma else {
                    throw ErrorFC(.unexpectedToken)
                }
                onComma = true
                print("Final argument is \(acc)")
                group.append(acc)
                acc = []
                consume()
                skipLines()
                continue
            }
            print("\(acc) appends `\(tkn)`  for argument")
            onComma = false
            acc.append(tkn)
            consume()
        }
        if !acc.isEmpty {
            print("Final argument is \(acc)")
            group.append(acc)
            acc = []
        }
        _ = try eat_t(end)
        return group
    }
    
    func parseCall() throws -> CallStatement {
        // Set scope
        scope = #function
        
        let callName = try id()
        _ = try eat(.leftPar)
        let args = try parseCommaSeperated(end: [.rightPar]).map(makeExpression)
        // FIXME: No semiclons
        try semicolon()
        return CallStatement(name: callName, args: args)
    }
    
    func parseFunction(noResolve: Bool = false) throws -> FunctionStatement {
        // Set scope
        self.scope = #function
        
        // Get function name
        let funcName = try id()
        _ = try eat(.leftPar)
        // Get the parameters
        let separated = try parseCommaSeperated(end: [.rightPar])
        let params = try separated.map(makeParameter)
        if !noResolve {
            try resolver.resolveFunctionName(funcName, params.count)
        }
        _ = try eat(.leftBracket)
        // Keep getting declarations until we are at the end of the statement (scope == 0)
        var scope = 1
        resolver.formNew()
        var body = [Statement]()
        while scope > 0 {
            // Skip newlines
            skipLines()
            // Scope system for future proofing the allowence of nested funcs, ifs, etc. Must be first to account for empty objects
            if match(.leftBracket) {
                consume()
                resolver.formNew()
                scope += 1
            } else if match(.rightBracket) {
                consume()
                resolver.back()
                scope -= 1
                if scope == 0 { break }
            }
            body.append(try parseStatement())
        }
        return FunctionStatement(name: funcName, args: params, body: body)
    }
    
    func parseDeclaration() throws -> DeclarationStatement {
        // Set scope
        scope = #function
        
        // Is the next token an identifier? If so then this token should be a type
        if ahead()?.type == .identifier {
            let typeString = try id().lexme
            guard let type = DeclarationType(rawValue: typeString) else {
                throw ErrorFC(.expectedType)
            }
            let name = try id()
            // FIXME: No semicolons
            try semicolon()
            return DeclarationStatement(name: name, type: type)
        }
        throw ErrorFC(.expectedType)
        
    }
    func parseReference(_ accessLevelString: String?) throws -> ReferenceStatement {
        // Set scope
        scope = #function
        
        // Get the access level
        var accessLevel: AccessLevel
        if let str = accessLevelString, let a = AccessLevel(rawValue: str) {
            accessLevel = a
            _ = try eat(.refDecl)
        } else {
            // Default to exposed
            accessLevel = .exposed
        }
        
        let name = try id()
        _ = try eat(.colon)
        let type = try id()
        
        // Make sure that the type exists
        try resolver.objectNameIsValid(type)
        
        // FIXME: No semicolons
        try semicolon()
        return ReferenceStatement(accessLevel: accessLevel, name: name, type: type)
    }
    func parseInternalReference() throws -> InternalReferenceStatement {
        // Set scope
        scope = #function
        
        let name = try id()
        _ = try eat(.colon)
        let type = try id()
        
        // FIXME: No semicolons
        try semicolon()
        return InternalReferenceStatement(name: name, type: type)
    }
    
    func parseStruct() throws -> StructStatement {
        // Set scope
        self.scope = #function
        
        // Get the structs name
        let structName = try id()
        
        // Parts of object
        var declarations = [DeclarationStatement]()
        var references = [ReferenceStatement]()
        var internals = [InternalReferenceStatement]()
        var conformances = [Token]()
        var methods = [FunctionStatement]()
        
        // Protocol conformances
        if match(.colon) {
            consume()
            conformances = try parseCommaSeperated(end: [.leftBracket]).map(singleToken)
            backwards()
        }
        _ = try eat(.leftBracket)
        // Keep getting declarations until we are at the end of the statement (scope == 0)
        var scope = 1
        resolver.formNew()
        while scope > 0 {
            // New lines are not important
            skipLines()
            
            // Scope system for future proofing the allowence of struct methods. Must be first to account for empty struct
            if match(.leftBracket) {
                consume()
                resolver.formNew()
                scope += 1
            } else if match(.rightBracket) {
                consume()
                resolver.back()
                scope -= 1
                if scope == 0 { break }
            }
            if match(.propertyDecl) {
                let decl = current
                consume()
                declarations.append(try parseDeclaration())
                warn("Declarations are deprecated as of Swizzle vX.Y.Z", decl)
            } else if match(.refDecl) || match(.accessLevel) {
                let string = current?.lexme
                consume()
                references.append(try parseReference(string))
            } else if match(.internalDecl) {
                consume()
                internals.append(try parseInternalReference())
            } else if match(.identifier) {
                throw ErrorFC(.unknownAccessLevel)
            } else if match(.funcDecl) {
                consume()
                methods.append(try parseFunction(noResolve: true))
            } else if (false) {
                
            } else {
                throw ErrorFC(.unexpectedToken)
            }
        }
        if references.isEmpty {
            warn("'\(structName.lexme)' has no references", structName)
        }
        try resolver.resolveStructName(structName, declarations.count)
        return StructStatement(
            name: structName,
            conformances: conformances,
            declarations: declarations,
            references: references,
            internals: internals,
            methods: methods
        )
    }
    
    func parseAssign(_ type: Token) throws -> AssignStatement {
        // Set scope
        scope = #function
        
        // Advance to identifier token
        consume()
        
        let name = try id()
        
        if type.type == .varDecl {
            // Check that the variable name does not exist
            try resolver.resolveVariableName(name)
        } else if type.type == .varDecl {
            // Check that the variable name does exist
            try resolver.variableNameIsValid(name)
        }
        
        
        // Assignment `=`
        _ = try eat(.assign)
        
        let assign = AssignStatement(decl: type, name: name, expression: try parseExpression(end: [.semicolon]))
        return assign
    }
    
    func parseTypealias() throws -> TypeAliasStatement {
        // Set scope
        scope = #function
        
        let alias = try id()
        _ = try eat(.assign)
        let type = try id()
        
        try semicolon()
        
        try resolver.objectNameIsValid(type)
        try resolver.resolveStructName(alias, -1)
        
        return TypeAliasStatement(alias: alias, type: type)
    }
    
    func parseProtocol() throws -> ProtocolStatement {
        // Set scope
        scope = #function
        
        // Get the name
        let name = try id()
        
        _ = try eat(.leftBracket)
        
        // Parts of protocol
        var references = [ReferenceStatement]()
        
        // While not at brcket (no nested-ness in protocols)
        while !match(.rightBracket) {
            skipLines()
            if isEOS { throw ErrorFC(.unexpectedEndOfFile) }
            if match(.refDecl) || match(.accessLevel) {
                let string = current?.lexme
                consume()
                references.append(try parseReference(string))
            } else {
                throw ErrorFC(.unexpectedToken)
            }
        }
        skipLines()
        
        // The '}'
        consume()
        
        return ProtocolStatement(name: name, references: references)
    }
    
    func parseImport() throws -> ImportStatement {
        // Module name
        let module = try id()
        
        // FIXME: No semicolons
        try semicolon()
        
        return ImportStatement(module: module)
    }
    
    func parseStatement() throws -> Statement {
        // Set scope
        scope = #function
        
        switch current?.type {
        case .structDecl?:
            consume()
            return try parseStruct()
        case .protocolDecl?:
            consume()
            return try parseProtocol()
        case .funcDecl?:
            consume()
            return try parseFunction()
        case .identifier?:
            return try parseStatementWithIdentifier()
        case .varDecl?, .setDecl?:
            return try parseAssign(current!)
        case .typeAliasDecl?:
            consume()
            return try parseTypealias()
        case .importDecl?:
            consume()
            return try parseImport()
        default:
            throw ErrorFC(.unexpectedToken)
        }
    }
    
    public func formStatements(_ stmts: inout [Statement]) throws {
        // Set scope
        scope = #function
        
        reset()
        // While we are not at the end of our file
        while !isEOS {
            skipLines()
            switch current?.type {
            case .eof?: return
            case .attribute?: try parseAttribute()
            default: stmts.append(try parseStatement())
            }
        }
    }
    
    public struct Warning: CustomStringConvertible, CustomDebugStringConvertible {
        public let description: String
        public let token: Token?
        public var debugDescription: String {
            var end = ""
            if let line = token?.line {
                end = " (line: \(line))"
            }
            return "\(description)\(end)"
        }
    }
    
    func warn(_ msg: String, _ tkn: Token? = nil) {
        let warning = Warning(description: msg, token: tkn)
        warnings.append(warning)
        let message = warning.debugDescription
        Log.log("Parser supplied warning: \(message)")
    }
    public internal(set) var warnings = [Warning]()
    
    public func log<OutputStream: TextOutputStream>(to stream: inout OutputStream) {
        if !warnings.isEmpty {
            let des = warnings.map { $0.debugDescription }.joined(separator: "\n")
            stream.write("\nCompiler Warnings:\n-------------------\n\(des)\n\n")
        }
    }
}
