//
//  SwizzleSrcTests.swift
//  SwizzleSrcTests
//
//  Created by Ethan Uppal on 1/20/19.
//  Copyright © 2019 Ethan Uppal. All rights reserved.
//

import XCTest
@testable import SwizzleSrc

class SwizzleSrcTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    let code = """
var x = 2;
var y = 3;
"""
    
    func lex() -> [Token] {
        var tokens = [Token]()
        let lexer = Lexer(code)
        lexer.formTokens(&tokens)
        return tokens
    }
    func parse(tkns: [Token]) -> [Statement] {
        var statements = [Statement]()
        let parser = Parser(stream: tkns, sourceFileName: "main")
        parser.debug = true
        do {
            try parser.formStatements(&statements)
        }
        catch let error as Parser.Error {
            XCTFail("\n" + error.detailedDescription(inCode: code))
        }
        catch {
            XCTFail(error.localizedDescription)
        }
        return statements
    }
    func generate(stmts: [Statement]) -> [Any] {
        var ir = [Any]()
        do {
            try SwizzleSrc.generate(from: stmts, into: &ir)
        }
        catch {
            XCTFail(error.localizedDescription)
        }
        return ir
    }
    
    func testLex() {
        self.measure {
            _ = lex()
        }
    }
    
    func testParse()  {
        let tkns = lex()
        self.measure {
            _ = parse(tkns: tkns)
        }
    }
    
    func testGeneration() {
        let stmts = parse(tkns: lex())
        self.measure {
            print(generate(stmts: stmts))
        }
    }
    
    func testPrecedenceClimbing() {
        self.measure {
            let result = Expression(rep: 1).combine(
                with: BinaryExpression(
                    lhs: Expression(rep: 3),
                    op: Token(type: .multiply, lexme: "*", literal: nil, line: nil),
                    rhs: Expression(rep: 4))
                ,
                op: Token(type: .divide, lexme: "/", literal: nil, line: nil))
            print(result)
        }
    }
    
    func testPlist() {
        self.measure {
            do {
                let url = _pathToResourcesFolder()
                    .appendingPathComponent(
                        "ProjInfo.plist",
                        isDirectory: false
                    )
                let info = try InfoPlist.from(url: url)
                print(info)
                
            }
            catch {
                XCTFail(String(describing: error))
            }
        }        
    }
    
    func testGetSources() {
        self.measure {
            do {
                print(try textOfItem(item: "Public/Buffer.swiz"))
            }
            catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testConfirmHelperPath() {
        XCTAssertEqual(_pathToResourcesFolder().lastPathComponent, "Resources")
    }
    
    func testProgram() {
        // Get tokens
        var tokens = [Token]()
        let lexer = Lexer(code)
        lexer.formTokens(&tokens)
        // Parse
        var statements = [Statement]()
        let parser = Parser(stream: tokens, sourceFileName: "main")
        parser.debug = true
        do {
            try parser.formStatements(&statements)
        }
        catch let error as Parser.Error {
            XCTFail("\n" + error.detailedDescription(inCode: code))
        }
        catch {
            XCTFail(error.localizedDescription)
        }

        // Make IR
        var ir = [Any]()
        do {
            try SwizzleSrc.generate(from: statements, into: &ir)
        }
        catch {
            XCTFail(error.localizedDescription)
        }
        // Compiler
        let bytecode: [Instruction]
        do {
            bytecode = try Compiler.compile(exp: ir)
        }
        catch {
            if let error = error as? CompilerError {
                XCTFail(error.localizedDescription)
            }
            XCTFail(error.localizedDescription)
            return
        }
        
        // Run the bytecode
        let vm = VM()
        let env = _DefaultEnvironment()
        let start, end: CFAbsoluteTime
        do {
            start = CFAbsoluteTimeGetCurrent()
            _ = try vm.evaluate(bytecodeInstructions: bytecode, env: env)
            end = CFAbsoluteTimeGetCurrent()
        }
        catch {
            if let error = error as? CompilerError {
                XCTFail(error.localizedDescription)
            }
            XCTFail(error.localizedDescription)
            return
        }
        print("Executed in \(end - start) seconds")
        print("==================================")
        print("Environment:")
        print(env.table)
    }
    
}

