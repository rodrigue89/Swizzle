//
//  Helping.swift
//  
//
//  Created by Ethan Uppal on 12/23/18.
//

import Foundation

extension Dictionary {
    public init(keys: [Key], values: [Value]) {
        self.init()
        for (key, value) in zip(keys, values) {
            self[key] = value
        }
    }
}

// Taken from https://stackoverflow.com/questions/41292671/separating-camelcase-string-into-space-separated-words-in-swift
extension String {
    func camelCaseToWords() -> String {
        return unicodeScalars.reduce("") {
            if CharacterSet.uppercaseLetters.contains($1) {
                return ($0 + " " + String($1))
            } else {
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

public func measure(block: () -> ()) -> CFAbsoluteTime {
    let start = CFAbsoluteTimeGetCurrent()
    block()
    let end = CFAbsoluteTimeGetCurrent()
    return end - start
}
