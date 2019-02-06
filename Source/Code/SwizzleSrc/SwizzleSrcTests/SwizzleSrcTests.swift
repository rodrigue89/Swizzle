//
//  SwizzleSrcTests.swift
//  SwizzleSrcTests
//
//  Created by Ethan Uppal on 1/20/19.
//  Copyright © 2019 Ethan Uppal. All rights reserved.
//
/*
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
                if let path = Bundle.main.path(forResource: "DefaultInfo", ofType: "plist") {
                    let url = URL(fileURLWithPath: path)
                    let info = try InfoPlist.from(url: url)
                    print(info)
                } else {
                    XCTFail()
                }
            }
            catch {
                XCTFail(error.localizedDescription)
            }
        }        
    }
    
    func testGetSources() {
        self.measure {
            do {
                print(try textOfItem(item: "Buffer.swiz"))
            }
            catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
}
*/
