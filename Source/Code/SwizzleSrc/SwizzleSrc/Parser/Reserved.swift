//
//  Reserved.swift
//  Swizzle - Compiling
//
//  Created by Ethan Uppal on 1/19/19.
//  Copyright © 2019 Ethan Uppal. All rights reserved.
//

import Foundation

public enum Reserved {
    public static let keywords = ["var", "set", "ref", "let", "decl", "internal", "struct", "protocol", "extend", "if", "else", "func", "typealias", "init"]
    public static let symbols = ["\\(", "\\)", "+", "-", "*", "/", "}", "{", "[", "]", "%", "$", "#", "@", "&", "^", "!"]
    public static let structs = [
        "Float", "String", "Bool", "Array", "Color", "Point", "Vector4", "Void", "Int", "Any"
    ]
    public static var all: [String] { return keywords + symbols + Parser.Resolver.currentStructs } 
}

