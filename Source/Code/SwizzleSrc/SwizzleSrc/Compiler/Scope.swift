//
//  Scope.swift
//  
//
//  Created by Ethan Uppal on 1/9/19.
//

import Foundation

public final class Environment {
    var table = [String:Any]()
    weak var parent: Environment?
    
    public init(table: [String:Any], parent: Environment? = nil) {
        self.table = table
        self.parent = parent
    }
    
    public func define(name: String, value: Any) {
        self.table[name] = value
    }
    public func assign(name: String, value: Any) throws {
        try resolve(name: name).define(name: name, value: value)
    }
    public func lookup(name: String) throws -> Any {
        let env = try resolve(name: name)
        return env.table[name]!
    }
    
    public func resolve(name: String) throws -> Environment {
        if self.table[name] != nil {
            return self
        }
        guard let parent = parent else {
            throw CompilerError(description: "Could not resolve", context: name)
        }
        return try parent.resolve(name: name)
    }
    
    public func isDefined(name: String) -> Bool {
        do {
            _ = try resolve(name: name)
            return true
        }
        catch {
            return false
        }
    }
}

public extension Environment {
    public func defineFn(name: String, block: @escaping ([Any]) throws -> ()) {
        self.define(name: name, value: block as ([Any]) throws -> Any)
    }
    public func defineFnWithReturn(name: String, block: @escaping ([Any]) throws -> Any) {
        self.define(name: name, value: block)
    }
}
