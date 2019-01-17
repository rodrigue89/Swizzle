//
//  Interpreter.swift
//
//
//  Created by Ethan Uppal on 12/23/18.
//

import Foundation

public final class IncludedLibraries {
    public static let MutableBox = ObjectStatement(
        name: Token(
            type: .identifier,
            lexme: "MutableBox",
            literal: nil,
            line: nil
        ),
        declarations: [
            DeclarationStatement(
                name: Token(
                    type: .identifier,
                    lexme: "value",
                    literal: nil,
                    line: nil
                ),
                type: .implied
            )
        ]
    )
    
    static var custom = [String:String]()
    public static func addLibrary(named name: String, code: String) {
        self.custom[name] = code
    }
    
    public static let Graphic = ObjectStatement(
        name: Token(
            type: .identifier,
            lexme: "Graphic",
            literal: nil,
            line: nil
        ),
        declarations: [
            DeclarationStatement(
                name: Token(
                    type: .identifier,
                    lexme: "text",
                    literal: nil,
                    line: nil
                ),
                type: .string
            ),
            DeclarationStatement(
                name: Token(
                    type: .identifier,
                    lexme: "size",
                    literal: nil,
                    line: nil
                ),
                type: .float
            )
        ]
    )
    public static let GraphicCtx = ObjectStatement(
        name: Token(
            type: .identifier,
            lexme: "GraphicCtx",
            literal: nil,
            line: nil
        ),
        declarations: [
            DeclarationStatement(
                name: Token(
                    type: .identifier,
                    lexme: "text",
                    literal: nil,
                    line: nil
                ),
                type: .string
            ),
            DeclarationStatement(
                name: Token(
                    type: .identifier,
                    lexme: "size",
                    literal: nil,
                    line: nil
                ),
                type: .float
            ),
            DeclarationStatement(
                name: Token(
                    type: .identifier,
                    lexme: "x",
                    literal: nil,
                    line: nil
                ),
                type: .float
            ),
            DeclarationStatement(
                name: Token(
                    type: .identifier,
                    lexme: "y",
                    literal: nil,
                    line: nil
                ),
                type: .float
            )
        ]
    )
    public static let NewGraphicCtx = ObjectStatement(
        name: Token(
            type: .identifier,
            lexme: "NewGraphicCtx",
            literal: nil,
            line: nil
        ),
        declarations: []
    )
    public static func importLibrary(_ name: String, _ i: Interpreter) {
        switch name {
        case "Graphics":
            i.statements.insert(Graphic, at: 0)
            i.statements.insert(GraphicCtx, at: 0)
            i.statements.insert(NewGraphicCtx, at: 0)
            i.addFunc("selectColor", ["ctx", "color"]) { (_, args) in
                let ctxName = i.nowhite(args[0]); let colorName = i.nowhite(args[1])
                guard let ctx = i.objects[ctxName] else {
                    i.reportError("Could not locate the graphic context named '\(ctxName)'")
                    return
                }
                guard let color = i.objects[colorName] else {
                    i.reportError("Could not locate the color named '\(colorName)'")
                    return
                }
                ctx.name = GraphicCtx.name.lexme
                ctx.values["_hue"] = color.values["hue"]
                ctx.values["_sat"] = color.values["saturation"]
                ctx.values["_bri"] = color.values["brightness"]
                ctx.values["_alp"] = color.values["alpha"]
            }
            i.addFunc("drawGraphic", ["ctx", "graphic", "point"]) { (_, args) in
                let ctxName = i.nowhite(args[0]); let graphicName = i.nowhite(args[1]); let pointName = i.nowhite(args[2])
                guard let ctx = i.objects[ctxName] else {
                    i.reportError("Could not locate the graphic context named '\(ctxName)'")
                    return
                }
                guard let graphic = i.objects[graphicName] else {
                    i.reportError("Could not locate the graphic named '\(graphicName)'")
                    return
                }
                guard let point = i.objects[pointName] else {
                    i.reportError("Could not locate the point named '\(pointName)'")
                    return
                }
                if let txt = graphic.values["text"] {
                    ctx.values["_text"] = i.unstringify(txt)
                }
                ctx.values["_size"] = graphic.values["size"]
                ctx.values["_x"] = point.values["x"]
                ctx.values["_y"] = point.values["y"]
            }
        case "MutableBox":
            i.statements.insert(MutableBox, at: 0)
            i.addFunc("copyValue", ["dest", "box"]) { (_, args) in
                let dest = i.nowhite(args[0]); let box = i.nowhite(args[1])
                i.objects[dest]?.values["value"] = i.objects[box]?.values["value"]
            }
        default:
            return
        }
    }
}

public final class StdLib {
    public static let StdFloat = ObjectStatement(
        name: Token(
            type: .identifier,
            lexme: "Float",
            literal: nil,
            line: nil
        ),
        declarations: [
            DeclarationStatement(
                name: Token(
                    type: .identifier,
                    lexme: "*value",
                    literal: nil,
                    line: nil
                ),
                type: .float
            )
        ]
    )
    
    public static let Point = ObjectStatement(
        name: Token(
            type: .identifier,
            lexme: "Point",
            literal: nil,
            line: nil
        ),
        declarations: [
            DeclarationStatement(
                name: Token(
                    type: .identifier,
                    lexme: "x",
                    literal: nil,
                    line: nil
                ),
                type: .float
            ),
            DeclarationStatement(
                name: Token(
                    type: .identifier,
                    lexme: "y",
                    literal: nil,
                    line: nil
                ),
                type: .float
            )
        ]
    )
    
    public static let Color = ObjectStatement(
        name: Token(
            type: .identifier,
            lexme: "Color",
            literal: nil,
            line: nil
        ),
        declarations: [
            DeclarationStatement(
                name: Token(
                    type: .identifier,
                    lexme: "hue",
                    literal: nil,
                    line: nil
                ),
                type: .float
            ),
            DeclarationStatement(
                name: Token(
                    type: .identifier,
                    lexme: "saturation",
                    literal: nil,
                    line: nil
                ),
                type: .float
            ),
            DeclarationStatement(
                name: Token(
                    type: .identifier,
                    lexme: "brightness",
                    literal: nil,
                    line: nil
                ),
                type: .float
            ),
            DeclarationStatement(
                name: Token(
                    type: .identifier,
                    lexme: "alpha",
                    literal: nil,
                    line: nil
                ),
                type: .float
            )
        ]
    )
    
    public static let Vector4 = ObjectStatement(
        name: Token(
            type: .identifier,
            lexme: "Vector4",
            literal: nil,
            line: nil
        ),
        declarations: [
            DeclarationStatement(
                name: Token(
                    type: .identifier,
                    lexme: "w",
                    literal: nil,
                    line: nil
                ),
                type: .float
            ),
            DeclarationStatement(
                name: Token(
                    type: .identifier,
                    lexme: "x",
                    literal: nil,
                    line: nil
                ),
                type: .float
            ),
            DeclarationStatement(
                name: Token(
                    type: .identifier,
                    lexme: "y",
                    literal: nil,
                    line: nil
                ),
                type: .float
            ),
            DeclarationStatement(
                name: Token(
                    type: .identifier,
                    lexme: "z",
                    literal: nil,
                    line: nil
                ),
                type: .float
            )
        ]
    )
    
    public static let Array = ObjectStatement(
        name: Token(
            type: .identifier,
            lexme: "Array",
            literal: nil,
            line: nil
        ),
        declarations: []
    )
    
    public static func configure(_ i: Interpreter) {
        i.statements.append(contentsOf: [StdFloat, Point, Color, Vector4, Array])
        // MARK: Basic Functions
        i.addFunc("print", Interpreter._variableLengthParameters) { (_, args) in
            var result = ""
            for index in args.indices {
                let val = i.unstringify(args[index])
                if index + 1 == args.endIndex {
                    result += val
                } else {
                    result += val + i.printSeperator
                }
            }
            let final = i.frmPfx + result
            i.stream?.write(final)
            print(final, terminator: i.printTerminator)
        }
        i.addFunc("formSum", ["r", "lhs", "rhs"]) { (_, args) in
            let r = i.nowhite(args[0])
            let a = i.nowhite(args[1])
            let b = i.nowhite(args[2])
            guard let lhs = Float(a), let rhs = Float(b) else {
                i.reportError("Cannot convert value of type *Any to type Float in call to `formSum(lhs: \(a), rhs: \(b))`")
                return
            }
            let sum = lhs + rhs
            i.makeFloat(val: sum, objcName: r)
        }
        i.addFunc("formDif", ["r", "lhs", "rhs"]) { (_, args) in
            let r = i.nowhite(args[0])
            let a = i.nowhite(args[1])
            let b = i.nowhite(args[2])
            guard let lhs = Float(a), let rhs = Float(b) else {
                i.reportError("Cannot convert value of type *Any to type Float in call to `formSum(lhs: \(a), rhs: \(b))`")
                return
            }
            let sum = lhs - rhs
            i.makeFloat(val: sum, objcName: r)
        }
        i.addFunc("formProd", ["r", "lhs", "rhs"]) { (_, args) in
            let r = i.nowhite(args[0])
            let a = i.nowhite(args[1])
            let b = i.nowhite(args[2])
            guard let lhs = Float(a), let rhs = Float(b) else {
                i.reportError("Cannot convert value of type *Any to type Float in call to `formSum(lhs: \(a), rhs: \(b))`")
                return
            }
            let sum = lhs * rhs
            i.makeFloat(val: sum, objcName: r)
        }
        i.addFunc("formQuo", ["r", "lhs", "rhs"]) { (_, args) in
            let r = i.nowhite(args[0])
            let a = i.nowhite(args[1])
            let b = i.nowhite(args[2])
            guard let lhs = Float(a), let rhs = Float(b) else {
                i.reportError("Cannot convert value of type *Any to type Float in call to `formSum(lhs: \(a), rhs: \(b))`")
                return
            }
            let sum = lhs / rhs
            i.makeFloat(val: sum, objcName: r)
        }
        i.addFunc("formRem", ["r", "lhs", "rhs"]) { (_, args) in
            let r = i.nowhite(args[0])
            let a = i.nowhite(args[1])
            let b = i.nowhite(args[2])
            guard let lhs = Float(a), let rhs = Float(b) else {
                i.reportError("Cannot convert value of type *Any to type Float in call to `formSum(lhs: \(a), rhs: \(b))`")
                return
            }
            let sum = lhs.remainder(dividingBy: rhs)
            i.makeFloat(val: sum, objcName: r)
        }
        
        // MARK: Debug Functions
        i.addFunc("ast_objc_set", ["object", "key", "value"]) { (_, args) in
            let object = i.nowhite(args[0])
            let key = i.nowhite(args[1])
            let value = i.nowhite(args[2])
            i.objects[object]?.values[key] = value
        }
        i.addFunc("ast_objc_set2", ["object", "key", "object2", "value2"]) { (_, args) in
            let object = i.nowhite(args[0])
            let key = i.nowhite(args[1])
            let object2 = i.nowhite(args[2])
            let value2 = i.nowhite(args[3])
             i.objects[object]?.values[key] = i.objects[object2]?.values[key2]
        }
        
        // MARK: File Functions
        i.addFunc("fileManagerDesktopGetString", ["dump", "path"]) { (_, args) in
            let dump = i.nowhite(args[0])
            let path = i.nowhite(args[1])
            do {
                let url = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!.appendingPathComponent(path)
                let string = try String(contentsOf: url)
                let assign = AssignStatement(decl: Token(type: .setDecl, lexme: "set", literal: nil, line: nil), name: i.asToken(dump), expression: Expression(rep: .literal(string)))
                i.visit(assign)
            }
            catch {
                i.reportError(String(describing: error))
            }
        }
        i.addFunc("fileManagerDocumentGetString", ["dump", "path"]) { (_, args) in
            let dump = i.nowhite(args[0])
            let path = i.nowhite(args[1])
            do {
                let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(path)
                let string = try String(contentsOf: url)
                let assign = AssignStatement(decl: Token(type: .setDecl, lexme: "set", literal: nil, line: nil), name: i.asToken(dump), expression: Expression(rep: .literal(string)))
                i.visit(assign)
            }
            catch {
                i.reportError(String(describing: error))
            }
        }
        i.addFunc("fileManagerDocumentWriteString", ["text", "path"]) { (_, args) in
            let text = i.nowhite(args[0])
            let path = i.nowhite(args[1])
            do {
                let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(path)
                try text.write(to: url, atomically: false, encoding: .utf8)
            }
            catch {
                i.reportError(String(describing: error))
            }
        }
        
        // MARK: Vector Functions
        i.addFunc("swizzle4", ["vector", "newLayout"]) { (_, args) in
            let vector4Name = i.nowhite(args[0])
            let newLayout = i.nowhite(args[1])
            guard let vector = i.objects[vector4Name], vector.name == StdLib.Vector4.name.lexme else {
                i.reportError("Cannot convert value of type *Any to type Vector4 in call to 'swizzle4(vector: \(vector4Name), newLayout: \(newLayout)'")
                return
            }
            let layout = newLayout.prefix(4)
            guard layout.count == 4 else {
                i.reportError("Expected a string with a length of 4 characters in call to 'swizzle4(vector: \(vector4Name), newLayout: \(newLayout)'")
                return
            }
            let originalValues = vector.values
            for character in layout {
                switch character {
                case "w":
                    vector.values["w"] = originalValues["w"]
                case "x":
                    vector.values["x"] = originalValues["x"]
                case "y":
                    vector.values["y"] = originalValues["y"]
                case "z":
                    vector.values["z"] = originalValues["z"]
                default:
                    i.reportError("Unexpcted character in layout string, please only use 'w', 'x', 'y', or 'z'")
                    return
                }
            }
        }
    }
}


public final class Interpreter: Visitor {
    // MARK: Visitor result
    public typealias Result = [String]?
    
    // MARK: Error
    public struct Error: Swift.Error, CustomStringConvertible {
        public let message: String
        public let line: Int
        public var description: String {
            if line == -1 {
                return "\(message) (line: unknown)"
            }
            if line == -2 {
                return "\(message)"
            }
            return "\(message) (line: \(line))"
        }
        public var localizedDescription: String {
            return description
        }
    }
    
    // MARK: Helper types
    struct Stack<Element>: Sequence {
        var flat = [Element]()
        mutating func push(_ newElement: Element) {
            flat.append(newElement)
        }
        mutating func pop() -> Element? {
            return flat.popLast()
        }
        mutating func removeAll() {
            flat.removeAll()
        }
        func makeIterator() -> AnyIterator<Element> {
            return AnyIterator(flat.reversed().makeIterator())
        }
    }
    public struct Queue<Element> {
        private var storage = [Element]()
        mutating public func enqueue(_ element: Element) {
            storage.append(element)
        }
        mutating public func dequeue() -> Element? {
            guard !storage.isEmpty else { return nil }
            return storage.removeFirst()
        }
        mutating public func empty() {
            storage = []
        }
        public func getFlat() -> [Element] {
            return storage
        }
        
        public var length: Int {
            return storage.count
        }
        public var isEmpty: Bool {
            return storage.isEmpty
        }
        public var last: Element? {
            return storage.last
        }
        public var next: Element? {
            return storage.first
        }
    }
    
    // MARK: A function
    public struct Function {
        public let name: String
        public let args: [String]
        public let block: (Interpreter, [String]) -> ()
        
        func _argDes() -> String {
            if args.isEmpty {
                return "()"
            } else if args == Interpreter._variableLengthParameters {
                return "(...)"
            } else {
                return "(\(args.map { "\($0):" }.joined()))"
            }
        }
        
        public func call(_ i: Interpreter, _ a: [Statement]) {
            var sep = true
            let args = a.compactMap { i.visit(stmt: $0) }.reduce([String]()) { (acc, next) -> [String] in
                if let next = next {
                    return acc + next
                } else {
                    return acc
                }
                }.reduce(into: [String]()) { (r, n) in
                    if n == "#" {
                        sep = false
                        if !r.isEmpty {
                            r[r.count - 1] = i.unstringify(r[r.count - 1])
                            if r[r.count - 1].last == " " {
                                r[r.count - 1].removeLast()
                            }
                        }
                        return
                    }
                    if sep == false {
                        if !r.isEmpty {
                            r[r.count - 1] = i.unstringify(r[r.count - 1])
                            if r[r.count - 1].last == " " {
                                r[r.count - 1].removeLast()
                            }
                        }
                        r[r.count - 1] += (i.unstringify(n) + " ")
                        sep = true
                    } else if sep == true {
                        let s = i.unstringify(n)
                        if s.first == " " {
                            r.append(" " + s + " ")
                        } else {
                            r.append(s + " ")
                        }
                        
                    }
            }
            block(i, args)
            i.logMsg("Function '\(name)\(_argDes())' was executed.")
        }
    }
    
    // MARK: An object
    public final class Object: CustomStringConvertible {
        public var name: String
        public var values: [String:String]
        public init(name: String, values: [String:String], stmt: ObjectStatement) {
            self.name = name
            self.values = values
            self.stmt = stmt
        }
        let stmt: ObjectStatement
        public var description: String {
            return "\(name)(\(values.map({ "\($0.key): \($0.value)" }).joined(separator: ", ")))"
        }
        
    }
    
    // MARK: A debugged frame
    public struct Debug {
        public let trigger: Int?
        public let log: String
        public let info: String?
        public init(trigger: Int?, log: String, info: String?) {
            self.trigger = trigger
            self.log = log
            self.info = info
        }
        
        public var printInfo = false
        public func printToConsole() -> String {
            var des = "Debug("
            if let trigger = trigger {
                des += "[caller = frame #\(trigger)] "
            }
            des += "\"\(log)\""
            if let info = info, printInfo {
                des += ", info: \"\(info)\""
            }
            des.append(")")
            print(des)
            return des
        }
    }
    
    // MARK: Variable-length
    static let _variableLengthParameters = ["*VARIABLE_LENGTH"]
    
    // MARK: Properties
    let code: String
    var statements = [Statement]()
    public var stackTrace: Bool
    public var alwaysTraverseDebug: Bool = false
    weak var stream: Streaming?
    //    public var header: Header?
    
    // MARK: Init
    public init(code: String, debug: Bool = false, stackTrace: Bool, stream: Streaming?) throws {
        self.code = code
        self.stackTrace = stackTrace
        self.stream = stream
        configureDefaults()
        let lexer = Lexer(code)
        var tokens = [Token]()
        let ls = CFAbsoluteTimeGetCurrent()
        lexer.formTokens(&tokens)
        let le = CFAbsoluteTimeGetCurrent()
        if debug {
            let tokenString = String(describing: tokens)
            print("Tokens (\(le - ls) seconds):", tokenString)
            stream?.write(tokenString)
            print("Tokens:", tokens)
        }
        let parser = Parser(stream: tokens)
        parser.isDebugging = debug
        let ps = CFAbsoluteTimeGetCurrent()
        do {
            try parser.formStatements(&statements)
        }
        catch {
            if let error = error as? Parser.Error {
                let words = String(describing: error.msg).camelCaseToWords().capitalized
                throw Error(message: words, line: error.line)
            }
        }
        let pe = CFAbsoluteTimeGetCurrent()
        if debug {
            let str = String(describing: statements)
            print("Statements (\(pe - ps) seconds):", str)
            stream?.write(str)
            stream?.write("")
        }
    }
    
    
    // MARK: Printing Constants
    let printSeperator = ""
    let printTerminator = "\n"
    
    func configureDefaults() {
        StdLib.configure(self)
    }
    
    // MARK: Helper functions
    func addFunc(_ name: String, _ args: [String], _ block: @escaping (Interpreter, [String]) -> ()) {
        functions[name] = Function(name: name, args: args, block: block)
    }
    
    func varValue(named name: String) -> AssignStatement? {
        return variables[name]
    }
    
    func unstringify(_ str: String) -> String {
        var str = str
        if str.first == "\"" {
            str.removeFirst()
        }
        if str.last == "\"" {
            str.removeLast()
        }
        return str
    }
    
    func makeObject(from constr: InitStatement, objcName: String) {
        let name = constr.objectName.lexme
        logMsg("Constructing an object with type of '\(name)' and storing in variable named '\(objcName)'.")
        let args = constr.args.compactMap { visit($0) }
        let reduced = args.reduce([String]()) { $0 + $1 }
        if name == StdLib.Array.name.lexme {
            var vals = [String:String]()
            var i = 0
            for arg in reduced {
                vals[i.description] = arg
                i += 1
            }
            vals["count"] = i.description
            let obj = Object(name: name, values: vals, stmt: StdLib.Array)
            objects[objcName] = obj
            return
        }
        guard let objectStmt = objectDecls[name] else { return }
        let names = objectStmt.declarations.map({ $0.name.lexme })
        let given = constr.args.count
        let expected = names.count
        if given != expected {
            logMsg("The entered argument count does not match the expected argument count.", ui: "Given: \(given), Expected: \(expected)")
            reportError("Expected \(expected) argument\(expected == 1 ? "" : "s") in initializer")
        }
        let values = Dictionary(keys: names, values: reduced)
        let object = Object(name: name, values: values, stmt: objectStmt)
        objects[objcName] = object
    }
    
    func makeFloat(val: Float, objcName: String) {
        let constr = InitStatement(objectName: StdLib.StdFloat.name, args: [Expression(rep: .literal(val))])
        makeObject(from: constr, objcName: objcName)
    }
    
    func nowhite(_ s: String) -> String {
        var trailing = s.drop(while: { $0 == " " })
        while trailing.last == " " {
            trailing.removeLast()
        }
        return String(trailing)
    }
    
    func asToken(_ str: String) -> Token {
        return Token(type: .identifier, lexme: str, literal: nil, line: nil)
    }
    
    // MARK: Storage
    var objectDecls = [String:ObjectStatement]()
    var objects = [String:Object]()
    var variables = [String:AssignStatement]()
    var functions = [String:Function]()
    
    var stack = Stack<String>()
    
    // MARK: Visitor implementation
    public func visit(_ call: CallStatement) -> Interpreter.Result {
        let end = call.line != nil ? " at line \(call.line!)" : ""
        let callName = call.name.lexme
        let callArgs = call.args
        guard let function = functions[callName] else {
            logMsg("Unknown function call to `\(callName)`\(end).", ui: "Statement: \(call)")
            reportError("The function `\(callName)` does not exist.")
            return nil
        }
        let override = Interpreter._variableLengthParameters == function.args
        let expected = function.args.count
        let given = callArgs.count
        guard given == expected || override else {
            logMsg("Unexpected arguments to function `\(function).", ui: "Given: \(given), Expected: \(expected)")
            reportError("Expected \(expected) parameters in function call to `\(function)`.")
            return nil
        }
        logMsg("Visiting a function call\(end)", true, ui: "Call: \(callName) with args: \(callArgs).")
        _ = function.call(self, callArgs)
        
        return nil
    }
    public func visit(_ access: AccessStatement) -> Interpreter.Result {
        let objectName = access.object.lexme
        let objectKey = access.key.lexme
        if let val = objects[objectName]?.values[objectKey] {
            return [val]
        }
        return nil
    }
    public func visit(_ constr: InitStatement) -> Interpreter.Result {
        guard let objcName = stack.pop() else { return nil }
        makeObject(from: constr, objcName: objcName)
        return nil
    }
    public func visit(_ objc: ObjectStatement) -> Interpreter.Result {
        objectDecls[objc.name.lexme] = objc
        return nil
    }
    public func visit(_ decl: DeclarationStatement) -> Interpreter.Result {
        return nil
    }
    public func visit(_ expr: Expression) -> Interpreter.Result {
        logMsg("Getting data from expression.", ui: "Data: \(expr)")
        let rep = expr.rep
        if let tkn = rep.anyToken {
            let name = tkn.lexme
            if let object = objects[name], let val = object.values["*value"] {
                return [val]
            } else if let assign = variables[name], let result = assign.value.accept(self) {
                return result
            }
            return [name]
        } else if let literal = rep.literal {
            return [String(describing: literal)]
        } else if rep.call != nil {
            // TODO: Allow function creation with returns
        } else if let access = rep.access {
            return visit(access)
        } else if let list = rep.list {
            return list.map { $0.lexme }
        }
        return nil
    }
    public func visit(_ assign: AssignStatement) -> Interpreter.Result {
        let varName = assign.name.lexme
        logMsg("Setting value to the variable '\(varName)'.", ui: "Statement: \(assign)")
        if assign.decl.type == .varDecl && variables[varName] != nil {
            logMsg("Cannot assign to already initialized.", ui: "Already created value: \(variables[varName]!)")
            reportError("Cannot create the variable \(varName) because it already exists, did you mean to use 'set' instead?")
            return nil
        } else if assign.decl.type == .setDecl && variables[varName] == nil {
            logMsg("Cannot assign to nothing.")
            reportError("Cannot set to \(varName) because \(varName) does not exist yet, did you mean to use 'var' instead?")
            return nil
        }
        variables[varName] = assign
        stack.push(varName)
        let rep = assign.value.rep
        if let call = rep.call {
            logMsg("Represents a call.")
            call.accept(self)
        } else if let constr = rep.constr {
            logMsg("Represents a constructor.")
            constr.accept(self)
        } else if let lit = rep.literal {
            if let num = lit as? Float {
                let object = Object(name: "Float", values: ["*value":num.description], stmt: StdLib.StdFloat)
                objects[varName] = object
            }
        } else if let access = rep.access {
            return access.accept(self)
        }
        return nil
    }
    public func visit(_ set: SetStatement) -> Interpreter.Result {
        logMsg("Setting and editing an object.")
        guard let object = objects[set.object.lexme] else {
            reportError("Cannot assign to variable because variable does not exist.")
            return nil
        }
        
        object.values[set.key.lexme] = visit(set.value)?.first
        return nil
    }
    public func visit(_ binary: BinaryExpression) -> Interpreter.Result {
        return nil
    }
    public func visit(_ cond: IfStatement) -> [String]? {
        let condition = visit(cond.condition)?.first
        logMsg("Visiting IfStatement", true, ui: "Evaluating if statement to choose what code to run")
        if condition == "true" {
            for stmt in cond.ifTrue {
                visit(stmt: stmt)
                if let error = error {
                    reportError(error)
                }
            }
        } else if condition == "false" {
            for stmt in cond.ifFalse {
                visit(stmt: stmt)
                if let error = error {
                    reportError(error)
                }
            }
        } else {
            reportError("Expected true or false return value for expression in if statement")
        }
        return nil
    }
    public func visit(_ funct: FunctionStatement) -> [String]? {
        let funcName = funct.name.lexme
        logMsg("Visiting declaration of '\(funcName)(_:)'.", ui: "Statement: \(funct)")
        guard functions[funcName] == nil else {
            logMsg("Unable to insert function named '\(funcName)' into hash table because the bucket is full", ui: "Function: \(funct)")
            reportError("Cannot declare function '\(funcName)' because it already exists")
            return nil
        }
        let args = funct.args.map { $0.lexme }
        let argCount = args.count
        let body = funct.body
        let function = Function(name: funcName, args: args) { [unowned self] (i, a) in
            guard argCount == a.count && !(args == Interpreter._variableLengthParameters) else {
                if self.stackTrace {
                    self.logMsg("Incorrect number of arguments. Expected \(argCount), given: \(a.count).", ui: "Input arguments: \(a), required arguments: \(args).")
                    self.logMsg("Arguments are not variable length.", ui: "Only varible length functions can have variable amounts of input arguments.")
                }
                self.reportError("Expected \(argCount) argument\(argCount == 1 ? "" : "s") in function call to '\(funcName)(_:)'")
                return
            }
            for statement in body {
                if let call = statement as? CallStatement {
                    var i = 0
                    var ua = 0
                    var newArgs = [Expression]()
                    call.args.forEach { (expr) in
                        if let n = expr.rep.anyToken?.lexme {
                            if ua < a.endIndex,  n == args[ua] {
                                let result = Token(type: TokenType.literal, lexme: a[ua], literal: nil, line: nil)
                                let newExpr = Expression(rep: .anyToken(result))
                                self.visit(newExpr)
                                newArgs.append(newExpr)
                                ua += 1
                            } else {
                                newArgs.append(expr)
                            }
                            
                        } else if let access = expr.rep.access {
                            access
                            guard let index = args.index(where: { $0 == access.object.lexme }) else {
                                self.reportError("Unresolved identifier '\(access.key.lexme)'")
                                return
                                
                            }
                            
                            let objcName = self.nowhite(a[index])
                            
                            guard let val = self.objects[objcName]?.values[access.key.lexme] else {
                                self.reportError("Unknown property '\(access.key.lexme)'")
                                return
                            }
                            let result = Token(type: .literal, lexme: val, literal: val, line: nil)
                            let newExpr = Expression(rep: .anyToken(result))
                            self.visit(newExpr)
                            newArgs.append(newExpr)
                            ua += 1
                        }
                        i += 1
                    }
                    let newCall = CallStatement(name: call.name, args: newArgs)
                    self.visit(newCall)
                } else if let cond = statement as? IfStatement {
                    
                }
            }
        }
        functions[funcName] = function
        return nil
    }
    
    public typealias FunctionTupleInput = (interpreter: Interpreter, args: [String])
    public func registerExternalFunction(name: String, block: @escaping (FunctionTupleInput) -> ()) {
        addFunc(name, Interpreter._variableLengthParameters, block)
    }
    
    // MARK: Error reporting
    var error: String?
    
    public func reportError(_ msg: String) {
        error = msg
    }
    
    // MARK: Logging
    var logs = Queue<String>()
    var info = [Int:Debug]()
    var triggers = Queue<Int>()
    var _onTrigger = false
    
    func _resetST() {
        logs.empty()
        triggers.empty()
        _onTrigger = false
        _lastCaller = nil
        _frame = 1
        info.removeAll()
    }
    
    var frmPfx: String {
        if self.stackTrace {
            return "Frame #\(_frame): "
        } else {
            return ""
        }
    }
    
    func logMsg(_ msg: String, _ trigger: Bool = false, _ c: Int = 1, ui: String? = nil) {
        if stackTrace {
            let end = _onTrigger ? " (caller: frame #\(triggers.dequeue() ?? -1))" : ""
            let m = "*** \(frmPfx)\(msg)\(end)"
            logs.enqueue(m)
            if let ui = ui {
                info[_frame] = Debug(trigger: _lastCaller, log: msg, info: ui)
            }
            if trigger {
                for _ in 0 ..< c { triggers.enqueue(_frame) }
                _lastCaller = _frame
                _onTrigger = true
            } else {
                _onTrigger = false
            }
            _frame += 1
        }
    }
    
    var _frame = 0
    var _lastCaller: Int?
    
    func logAll() {
        if stackTrace {
            print("\nTrace:")
            print("------")
            while let msg = logs.dequeue() {
                print(msg)
            }
            if alwaysTraverseDebug {
                traverseStackTrace {
                    $0.printToConsole()
                }
            }
        }
    }
    
    // MARK: Execution
    public func execute() throws -> CFAbsoluteTime {
        _resetST()
        error = nil
        let start = CFAbsoluteTimeGetCurrent()
        var i = 0
        for statement in statements {
            logMsg("\(i == statements.count ? "Last" : (i == 0 ? "First" : "Next")) iteration: \(type(of: statement))")
            self.visit(stmt: statement)
            if let error = error {
                logAll()
                throw Error(message: error, line: -2)
            }
            i += 1
        }
        logAll()
        let end = CFAbsoluteTimeGetCurrent()
        return end - start
    }
    
    // MARK: Debug
    public func debug(frame: Int) -> Debug? {
        return info[frame]
    }
    public func traverseStackTrace(by body: @escaping (Debug) -> ()) {
        print("\nDebug:")
        print("------")
        for (_, debug) in info.sorted(by: { $0.key < $1.key }) {
            body(debug)
        }
    }
    public func clearDebug() {
        info.removeAll()
    }
}

public protocol Streaming: class, TextOutputStream {
    func write(_ string: String)
}
