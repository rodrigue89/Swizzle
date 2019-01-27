//
//  Log.swift
//  Swizzle - Compiling
//
//  Created by Ethan Uppal on 1/16/19.
//  Copyright © 2019 Ethan Uppal. All rights reserved.
//

import Foundation

protocol LoggerDelegate: class {
    func log()
}

public final class Log {
    static let domainID = "Swizzle.Log"
    static let idKey = "id_key"
    
    static var id = {
        return (UserDefaults.standard.persistentDomain(forName: domainID)?[idKey] as? Int) ?? 0
    }()
    public static func new() throws {
        id += 1
        UserDefaults.standard.setPersistentDomain([idKey: id], forName: domainID)
        current = try Log(fileName: "swizzle.log-\(id)\t\(Date())")
    }
    public static func end() {
        current = nil
    }
    public static func log(_ strings: String..., separator: String = " ", terminator: String = "\n") {
        let string = strings.joined(separator: separator) + terminator
        Log.current?._appendText(string)
    }
    public static internal(set) var current: Log?
    
    let url: URL
    public init(fileName: String) throws {
        self.url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(fileName + ".txt")
    }
    
    var _text = Data()
    func _appendText(_ text: String) {
        _text.append(contentsOf: text.utf8)
    }
    
    public func log(_ strings: String..., separator: String = " ", terminator: String = "\n") {
        let string = strings.joined(separator: separator) + terminator
        _appendText(string)
    }
    public func write() throws {
        try _text.write(to: url)
    }
    public func write<OutputStream: TextOutputStream>(to stream: inout OutputStream, encoding: String.Encoding) -> Bool {
        guard let string = String(data: _text, encoding: encoding) else { return false }
        stream.write(string)
        return true
    }
}
