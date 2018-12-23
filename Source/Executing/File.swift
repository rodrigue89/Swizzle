//
//  File.swift
//  
//
//  Created by Ethan Uppal on 12/23/18.
//

import Foundation

public class CodeFile {
    let code: String
    let header: Header?
    public init(url: URL, headerURL: URL?) throws {
        self.code = try String(contentsOf: url)
        if let headerURL = headerURL {
            let str = try String(contentsOf: headerURL)
            self.header = Header(headerCode: str)
        } else {
            self.header = nil
        }
    }
    public struct Options: OptionSet {
        public static let debug = Options(rawValue: 1)
        public static let stackTrace = Options(rawValue: 2)
        public static let traverseDebug = Options(rawValue: 4)
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    public var options: Options = [.stackTrace]
    public func run() throws -> Interpreter {
        let i = try Interpreter(code: code, debug: options.contains(.debug), stackTrace: options.contains(.stackTrace))
        i.header = header
        i.alwaysTraverseDebug = options.contains(.traverseDebug)
        try i.execute()
        return i
    }
}
