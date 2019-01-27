//
//  Helpers.swift
//  SwizzleSrc
//
//  Created by Ethan Uppal on 1/25/19.
//  Copyright © 2019 Ethan Uppal. All rights reserved.
//

import Foundation

fileprivate final class _ShortTermAST {
    static var _last: String?
    static var _ast: [Statement]?
}

public func parse(codeText: String, consoleText: inout String) -> [Statement] {
    if codeText.isEmpty {
        consoleText = "Please enter some code"
        return []
    }
    
    if _ShortTermAST._last == codeText, let ast = _ShortTermAST._ast {
        let start = CFAbsoluteTimeGetCurrent()
        let string = ast.map { String(describing: $0) }.joined(separator: "\n")
        let end = CFAbsoluteTimeGetCurrent()
        let desTime = end - start
        consoleText = """
        Lexed in 0 seconds
        Parsed in \(desTime.toString()) seconds:
        \(string)
        """
        return ast
    } else {
        Log.log("\nCompilation log at \(Date()):")
    }
    _ShortTermAST._last = codeText
    
    consoleText = ""
    
    let lexStart = CFAbsoluteTimeGetCurrent()
    let lexer = Lexer(codeText)
    var tokens = [Token]()
    lexer.formTokens(&tokens)
    let lexEnd = CFAbsoluteTimeGetCurrent()
    print("\u{001B}[2J")
    
    print(tokens.map { $0.lexme })
    let lexTime = lexEnd - lexStart
    consoleText += "Lexed in \(lexTime.toString()) seconds\n"
    let parseStart = CFAbsoluteTimeGetCurrent()
    let parser = Parser(stream: tokens, sourceFileName: "main.swiz")
    parser.debug = true
    var statements = [Statement]()
    do {
        try parser.formStatements(&statements)
        let parseEnd = CFAbsoluteTimeGetCurrent()
        _ShortTermAST._ast = statements
        let string = statements.map { String(describing: $0) }.joined(separator: "\n")
        let parseTime = parseEnd - parseStart
        consoleText += "Parsed in \(parseTime.toString()) seconds:\n"
        print(string, to: &consoleText)
    }
    catch let error as Parser.Error {
        // Logging
        let localized = error.localizedDescription
        Log.log(localized)
        
        // Debugging
        print("\nCompiler Error:", to: &consoleText)
        print(error.detailedDescription(inCode: codeText), to: &consoleText)
    }
    catch {
        let localized = error.localizedDescription
        
        // Logging
        Log.log(localized)
        
        print(localized, to: &consoleText)
    }
    
    var stream = ""
    parser.log(to: &stream)
    print(stream, to: &consoleText)
    
    return statements
}

fileprivate final class _GeneratorShared {
    static weak var g: Generator?
}

public func generate(from statements: [Statement], into ir: inout Generator.Result) throws {
    if let generator = _GeneratorShared.g {
        try generator.makeIR(result: &ir)
    } else {
        let generator = Generator(statements: statements)
        try generator.makeIR(result: &ir)
        _GeneratorShared.g = generator
    }
}

fileprivate final class _ShortTermOpcodes {
    static var _ops: [Instruction]?
}

public func compileSources(to stream: inout [Instruction], changed: Bool) throws {
    if let ops = _ShortTermOpcodes._ops, !changed {
        stream = ops
        return
    }
    var statements = [Statement]()
    let sources = try getSources()
    for source in sources.private.items {
        let text = try textOfItem(item: source)
        let lexer = Lexer(text)
        var tokens = [Token]()
        lexer.formTokens(&tokens)
        let parser = Parser(stream: tokens, sourceFileName: source)
        try parser.formStatements(&statements)
    }
    var ir = [Any]()
    try generate(from: statements, into: &ir)
    let ops = try Compiler.compile(exp: ir)
    stream.append(contentsOf: ops)
    _ShortTermOpcodes._ops = stream
}

func compile(sources: KeyValuePairs<String, String>, into stream: inout [Instruction]) throws {
    var statements = [Statement]()
    for (fileName, codeText) in sources {
        let lexer = Lexer(codeText)
        var tokens = [Token]()
        lexer.formTokens(&tokens)
        let parser = Parser(stream: tokens, sourceFileName: fileName)
        try parser.formStatements(&statements)
    }
    var ir = [Any]()
    try generate(from: statements, into: &ir)
    let ops = try Compiler.compile(exp: ir)
    stream.append(contentsOf: ops)
}

public func execute(bytecode: [Instruction], environment: Environment) throws {
    let vm = VM()
    _ = try vm.evaluate(bytecodeInstructions: bytecode, env: environment)
}
