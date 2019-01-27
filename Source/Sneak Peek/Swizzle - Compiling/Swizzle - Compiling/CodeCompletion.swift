//
//  CodeCompletion.swift
//  Swizzle - Compiling
//
//  Created by Ethan Uppal on 1/19/19.
//  Copyright © 2019 Ethan Uppal. All rights reserved.
//

import Cocoa

public final class CodeCompletion {
    let used = keywords + symbols + structs
    public func completions(in text: String, range: Range<String.Index>) -> [String] {
        return used.filter { $0.contains(text[range]) }
    }
}
