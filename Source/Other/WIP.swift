////
////  WIP.swift
////  
////
////  Created by Ethan Uppal on 12/23/18.
////
//
//import Foundation
//
//public struct ImportStatement {
//    public let file: String
//    public func code() -> String? {
//        return IncludedLibraries.standardLibrary[file]
//    }
//}
//
//public class IncludedLibraries {
//    public static let Float = ObjectStatement(name: Token(type: .identifier, lexme: "Float", literal: nil, line: nil), declarations: [DeclarationStatement(name: Token(type: .identifier, lexme: "*value", literal: nil, line: nil), type: .float)])
//    public static let MutableBoxFile = """
//    objc MutableBox {
//        decl value;
//    }
//
//    func setValue(box, value) {
//        box = value;
//    }
//    func copyValue(box, dest) {
//        dest.value = box.value;
//    }
//    """
//    public static let TempTextFile = """
//    objc TempText {
//        decl String value;
//    }
//
//    func put(text, temp) {
//        temp.value = text
//    }
//    func print(temp) {
//        print(temp.value)
//    }
//    """
//    
//    public static let standardLibrary: [String:String] = [
//        "MutableBox":MutableBoxFile,
//        "TempText":TempTextFile
//    ]
//}
//
//public class Header {
//    public var imports = [ImportStatement]()
//    public init?(headerCode: String) {
//        for line in headerCode.components(separatedBy: "\n") {
//            let components = line.components(separatedBy: " ")
//            guard components.count == 2, components.last?.last == ";" else { return nil }
//            guard components[0] == "import" else { return nil }
//            let importStmt = ImportStatement(file: String(components[1].dropLast()))
//            imports.append(importStmt)
//        }
//    }
//}
