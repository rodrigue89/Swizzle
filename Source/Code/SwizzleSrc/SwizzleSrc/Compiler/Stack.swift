//
//  Stack.swift
//  
//
//  Created by Ethan Uppal on 1/9/19.
//

import Foundation

public struct Stack<Element> {
    var flat = [Element]()
    public mutating func push(_ value: Element) {
        flat.append(value)
    }
    public mutating func push(contentsOf values: [Element]) {
        flat.append(contentsOf: values)
    }
    public mutating func pop() -> Element? {
        return flat.popLast()
    }
}
