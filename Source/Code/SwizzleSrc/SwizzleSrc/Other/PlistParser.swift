//
//  InfoPLISTParser.swift
//  SwizzleSrc
//
//  Created by Ethan Uppal on 1/25/19.
//  Copyright © 2019 Ethan Uppal. All rights reserved.
//

import Foundation

public protocol PlistDecodable {
    associatedtype Keys: PlistKey
    init(decoder: PlistDecoder<Self>) throws
}

public protocol PlistKey: Hashable, RawRepresentable where RawValue == String {
    static var count: Int { get }
}

public extension PlistKey where Self: CaseIterable {
    public static var count: Int {
        return allCases.count
    }
}

extension PlistDecodable {
    public static func from(url: URL) throws -> Self {
        return try PlistParser<Self>(readingFrom: url).parsedResult
    }
}

public final class PlistParser<Result: PlistDecodable> {
    public enum Error: Swift.Error {
        case couldNotFormData
        case corruptedData
        case unknownKey
    }
    
    private let parser = PropertyListDecoder()
    public init(readingFrom url: URL) throws {
        guard let src = NSDictionary(contentsOf: url) else {
            throw Error.couldNotFormData
        }
        guard src.count == Result.Keys.count else {
            throw Error.corruptedData
        }
        var plist = [Result.Keys:Any]()
        for (key, value) in src {
            guard let string = key as? String else {
                throw Error.corruptedData
            }
            guard let propertyName = Result.Keys(rawValue: string) else {
                throw Error.unknownKey
            }
            plist[propertyName] = value
        }
        let decoder = PlistDecoder<Result>(dict: plist)
        self.parsedResult = try Result(decoder: decoder)
    }
    
    public let parsedResult: Result
}

public final class PlistDecoder<Result: PlistDecodable> {
    public enum Error: Swift.Error {
        case valueDoesNotExist
    }
    internal let dictionary: [Result.Keys: Any]
    internal init(dict: [Result.Keys: Any]) {
        self.dictionary = dict
    }
    public func decode<T>(_ type: T.Type, forKey key: Result.Keys) throws -> T {
        guard let value = dictionary[key] as? T else {
            throw Error.valueDoesNotExist
        }
        return value
    }
}

// Actual usage
public struct InfoPlist: PlistDecodable {
    public enum Keys: String, PlistKey, CaseIterable {
        case automaticImports = "Automatic Imports"
        case versionNumber = "Swizzle Version Number"
        case mainFilePath = "Main File Path"
    }
    public let automaticInputs: [String]
    public let versionNumber: String
    public let mainFilePath: String
    
    public init(decoder: PlistDecoder<InfoPlist>) throws {
        self.automaticInputs = try decoder.decode([String].self, forKey: .automaticImports)
        self.versionNumber = try decoder.decode(String.self, forKey: .versionNumber)
        self.mainFilePath = try decoder.decode(String.self, forKey: .mainFilePath)
    }
}
