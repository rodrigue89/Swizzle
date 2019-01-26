//
//  Semicolon Inserter.swift
//  
//
//  Created by Ethan Uppal on 12/24/18.
//

import Foundation

public final class Inserter {
    let doNotTerminate: Set<Character> = [
        "{",
        "}",
        ";",
        "\n"
    ]
    public func insert(char: Character, terminatingStatementsIn code: inout String) {
        for index in code.indices {
            if code[index] == "\n" && !doNotTerminate.contains(code[code.index(before: index)]) {
                code.insert(char, at: index)
            }
        }
        if let last = code.last, !doNotTerminate.contains(last) {
            code.append(char)
        }
    }
}

/*
let inserter = Inserter()
var code = """
objc Person {
  decl name
}

func greet(person) {
  print("Hello,", person.name, #, ".")
}

var p = Person("Tim")
greet(p)
"""
inserter.insert(char: ";", terminatingStatementsIn: &code)
print(code)
 */
