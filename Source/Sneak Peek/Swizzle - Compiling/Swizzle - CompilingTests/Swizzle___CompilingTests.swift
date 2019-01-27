//___FILEHEADER___

import XCTest
import SwizzleSrc

func tkn(_ str: String) -> Token {
    return Token(type: .identifier, lexme: str, literal: nil, line: nil)
}

class Swizzle___CompilingTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testObject() { 
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        self.measure {
            let structStmt = StructStatement(name: tkn("URL"), conformances: [], declarations: [], references: [
                ReferenceStatement(name: tkn("string"), type: tkn("String")),
                ReferenceStatement(name: tkn("flag"), type: tkn("Int")),
                ], internals: [], methods: [])
            do {
                let obj = try SwizzleStruct(source: structStmt, parameters: ["www.apple.com", .int(0)])
            }
            catch {
                XCTFail(error.localizedDescription)
            }
        }
        
    }
    
    func testVM() {
        func printFn(args: [Any]) {
            print(args.map { String(describing: $0) }.joined(separator: " "))
        }
        let env = Environment(table: [:])
        let vm = VM()
        env.defineFn(name: "print", block: printFn)
        let code = """
func foo() {
  print("bar");
}
foo();
"""
        var std_cOut = ""
        let stmts = parse(codeText: code, consoleText: &std_cOut)
        if stmts.isEmpty {
            return
        }
        print(stmts)
        var ir = [Any]()
        do {
            try generate(from: stmts, into: &ir)
            print(ir)
            let bytecode = try Compiler.compile(exp: ir)
            self.measure {
                do {
                    _ = try vm.evaluate(bytecodeInstructions: bytecode, env: env)
                }
                catch let error as CompilerError {
                    XCTFail(error.localizedDescription)
                }
                catch {
                    XCTFail(error.localizedDescription)
                }
            }
        }
        catch {
            XCTFail(String(describing: error))
        }
    }
    
}
