//
//  Highlighter.swift
//  SyntaxHighlighter
//
//  Created by Ethan Uppal on 1/15/19.
//  Copyright © 2019 Ethan Uppal. All rights reserved.
//

import Foundation

public final class Highlighter {
    public static var fontName: String = ""
    public static var fontSize: CGFloat = -1
    public static var _debug = false
    
    public static func configure(body: (Highlighter.Type) throws -> ()) rethrows {
        try body(self)
    }
    
    public let regularExpressions: [RegularExpression]
    public init(regularExpressions: [RegularExpression]) {
        self.regularExpressions = regularExpressions
    }
    public func attributedString(from source: String) -> NSAttributedString {
        let str = NSMutableAttributedString(string: source)
        regularExpressions.forEach {
            for range in $0._matches(in: source, transform: { $0 }) {
                if Highlighter._debug, let r = Range(range, in: source) {
                    print($0.word.rawValue, "-", source[r])
                }
                str.addAttributes($0.word._attributes, range: range)
            }
        }
        return str
    }
}

#if canImport(Cocoa)
import Cocoa
public extension Highlighter {
    public func highlightSyntax(in textView: NSTextView) {
        let string = textView.string
        let cursorPos = textView.selectedRange()
        let attrString = attributedString(from: string)
        textView.string.removeAll()
        textView.textStorage?.append(attrString)
        textView.setSelectedRange(cursorPos)
    }
}
#endif

