//
//  GetSources.swift
//  SwizzleSrc
//
//  Created by Ethan Uppal on 1/25/19.
//  Copyright © 2019 Ethan Uppal. All rights reserved.
//

import Foundation


public struct Sources {
    public struct Item {
        public enum DecodingError: Swift.Error {
            case noArrayExists
            case notAnArrayOfStrings
        }
        let name: String
        let items: [String]
        public static func from(name: String, json: JSON) throws -> Item {
            guard let array = json.array else {
                throw DecodingError.noArrayExists
            }
            let items = try array.map { (element: JSON) throws -> String in
                guard let string = element.string else {
                    throw DecodingError.notAnArrayOfStrings
                }
                return string
            }
            return Item(name: name, items: items)
        }
    }
    public let `private`: Item
    public let `public`: Item
    public static func from(json: JSON) throws -> Sources {
        return Sources(
            private: try .from(
                name: "Private",
                json: json["Private"]
            ),
            public: try .from(
                name: "Public",
                json: json["Public"]
            )
        )
    }
}

func _pathToResourcesFolder() -> URL {
    return URL(fileURLWithPath: #file)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent(
            "Resources",
            isDirectory: true
    )
}

func _sources() throws -> JSON {
    let url = _pathToResourcesFolder().appendingPathComponent("Files.json")
    let string = try String(contentsOf: url)
    return JSON(parseJSON: string)

}

func getSources() throws -> Sources {
    let json = try _sources()
    return try Sources.from(json: json)
}

extension String: LocalizedError {
    public var localizedDescription: String {
        return self
    }
}

func textOfItem(item: String) throws -> String {
    let url = _pathToResourcesFolder()
        .appendingPathComponent("Core")
        .appendingPathComponent(item)
    if IS_DEBUG_ENABLED {
        print("Attempts to get text of \(item)")
        print("===============================")
        print("Full path: \(url)")
        print("")
    }
    return try String(contentsOf: url)
}



public func _DefaultEnvironment() -> Environment {
    let env = Environment(table: [:], parent: nil)
    // TODO: Configure env
    return env
}
