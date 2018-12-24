//
//  File.swift
//  
//
//  Created by Ethan Uppal on 12/23/18.
//

import Foundation

public class CodeFile {
    /// The source of the file
    let code: String
    
    public struct Error: CustomStringConvertible, Swift.Error {
        public var description: String
        public var localizedDescription: String {
            return description
        }
    }
    public init(directory: FileManager.SearchPathDirectory, path: String) throws {
        guard path.hasSuffix(".swiz") else { throw Error(description: "Expected '.swiz' as the file type") }
        guard let url = FileManager.default.urls(for: directory, in: .userDomainMask).first?.appendingPathComponent(path) else { throw Error(description: "Could not find file at \(path)") }
        self.code = try String(contentsOf: url)
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
        i.alwaysTraverseDebug = options.contains(.traverseDebug)
        try i.execute()
        return i
    }
}
