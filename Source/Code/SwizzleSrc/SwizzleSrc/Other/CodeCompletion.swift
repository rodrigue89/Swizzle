//
//  CodeCompletion.swift
//  Swizzle - Compiling
//
//  Created by Ethan Uppal on 1/19/19.
//  Copyright © 2019 Ethan Uppal. All rights reserved.
//

import Cocoa

public final class CodeCompletion {
    public init() {}
    public func completions(in text: String, range: Range<String.Index>) -> [String] {
        return Reserved.all.filter { $0.contains(text[range]) }
    }
}
