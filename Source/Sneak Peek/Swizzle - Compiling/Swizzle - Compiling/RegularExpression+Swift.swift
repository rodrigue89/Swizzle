//
//  Highlighter.swift
//  SyntaxHighlighter
//
//  Created by Ethan Uppal on 1/15/19.
//  Copyright © 2019 Ethan Uppal. All rights reserved.
//

import AppKit

public struct RegularExpression {
    public struct Word {
        public let rawValue: String
        public let color: NSColor
        public let bold: Bool
        public init(rawValue: String, color: NSColor, bold: Bool = false) {
            self.rawValue = rawValue
            self.color = color
            self.bold = bold
        }
    }
    public let word: Word
    public let info: [String]?
    public init(word: Word, info: [String] = []) {
        self.word = word
        self.info = info.isEmpty ? nil : .some(info)
    }
}

public extension RegularExpression.Word {
    public enum Standard {
        public static let keywordColor = NSColor.systemPink
        public static let keywordBold = true
        public static let commentColor = NSColor.green
        public static let numberColor = NSColor.blue
        public static let stringColor = NSColor(red: 255 / 255, green: 102 / 255, blue: 0, alpha: 255 / 255)
        public static let identifierColor = NSColor.purple
        public static let symbolColor = NSColor.black
    }
}

public extension RegularExpression.Word {
    public static let keyword = RegularExpression.Word(rawValue: "standard.keyword", color: Standard.keywordColor, bold: Standard.keywordBold)
    public static let comment = RegularExpression.Word(rawValue: "standard.comment", color: Standard.commentColor)
    public static let number = RegularExpression.Word(rawValue: "standard.number", color: Standard.numberColor)
    public static let string = RegularExpression.Word(rawValue: "standard.string", color: Standard.stringColor)
    public static let identifier = RegularExpression.Word(rawValue: "standard.identifier", color: Standard.identifierColor)
    public static let symbol = RegularExpression.Word(rawValue: "standard.symbol", color: Standard.symbolColor)
    
    public var _attributes: [NSAttributedString.Key: Any] {
        let font = self.bold ? NSFont(name: Highlighter.fontName + "-Bold", size: Highlighter.fontSize) : NSFont(name: Highlighter.fontName, size: Highlighter.fontSize)
        return [.foregroundColor: color, .font: font as Any]
    }
}

public extension RegularExpression {
    private func _regex(_ ptrn: String) -> NSRegularExpression? {
        return try? NSRegularExpression(pattern: ptrn, options: [])
    }
    public func _toRegExp() -> NSRegularExpression? {
        switch word.rawValue {
        case Word.keyword.rawValue:
            guard let keywords = info else {
                return nil
            }
            let text = keywords.joined(separator: "|")
            return _regex("(\(text))")
        case Word.comment.rawValue:
            let commentStart = info?.first ?? "//"
            return _regex(commentStart + ".*\n")
        case Word.number.rawValue:
            return _regex("( |,|=)[0-9]+.?[0-9]*")
        case Word.string.rawValue:
            return _regex("\"[^\"\\\\]*(\\\\.[^\"\\\\]*)*\"")
        case Word.identifier.rawValue:
            let prefixCustom = info?.first ?? ""
            let suffixCustom = info?.dropFirst().first ?? ""
            return _regex("\(prefixCustom)\\b[_a-zA-Z][_a-zA-Z0-9]*\\b\(suffixCustom)")
        case Word.symbol.rawValue:
            guard let symbols = info else {
                return nil
            }
            let text = symbols.joined(separator: "|")
            return _regex("(\(text))")
        default:
            return nil
        }
    }
}

public extension RegularExpression {
    public typealias Match = Range<String.Index>
    
    public func _matches<R>(in string: String, transform: (NSRange) -> R?) -> [R] {
        guard let _regex = _toRegExp() else { return [] }
        let matches = _regex.matches(in: string, options: [], range: string._nsrange)
        return matches.compactMap {
            transform($0.range)
        }
    }
    public func matches(in string: String) -> [Match] {
        return _matches(in: string) { Range($0, in: string) }
    }
}

public extension String {
    var _nsrange: NSRange {
        return NSRange(location: 0, length: utf16.count)
    }
    var _nsrange_end: NSRange {
        return NSRange(location: utf16.count, length: 0)
    }
    public func matches(using regex: RegularExpression) -> [String] {
        return regex.matches(in: self).map {
            String(self[$0])
        }
    }
}
