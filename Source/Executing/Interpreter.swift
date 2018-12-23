//
//  Interpreter.swift
//  
//
//  Created by Ethan Uppal on 12/23/18.
//

import Foundation

public class Interpreter: Visitor {
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
            //            print("a:", a)
            let args = a.compactMap { i.visit(stmt: $0) }.reduce([String]()) { (acc, next) -> [String] in
                if let next = next {
                    return acc + next
                } else {
                    return acc
                }
                }.reduce(into: [String]()) { (r, n) in
                    r
                    n
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
    public struct Object: CustomStringConvertible {
        public let name: String
        public var values: [String:String]
        let stmt: InitStatement
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
        public func printToConsole() {
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
        }
    }
    
    // MARK: Variable-length
    static let _variableLengthParameters = ["*VARIABLE_LENGTH"]
    
    // MARK: Properties
    let code: String
    var statements = [Statement]()
    public var stackTrace: Bool
    public var alwaysTraverseDebug: Bool = false
    public var header: Header?
    
    // MARK: Init
    public init(code: String, debug: Bool = false, stackTrace: Bool) throws {
        self.code = code
        self.stackTrace = stackTrace
        configureDefaults()
        let lexer = Lexer(code)
        var tokens = [Token]()
        lexer.formTokens(&tokens)
        if debug {
            print("Tokens:", tokens)
        }
        let parser = Parser(stream: tokens)
        parser.isDebugging = debug
        do {
            try parser.formStatements(&statements)
        }
        catch {
            let words = String(describing: error).camelCaseToWords().capitalized
            throw Error(message: words, line: parser.currentLine())
        }
        if debug {
            print("Statements:", statements)
        }
    }
    
    
    // MARK: Included Library
    let printSeperator = ""
    let printTerminator = "\n"
    
    func configureDefaults() {
        statements.append(IncludedLibraries.Float)
        
        addFunc("print", Interpreter._variableLengthParameters) { (i, args) in
            var result = ""
            for index in args.indices {
                let val = self.unstringify(args[index])
                if index + 1 == args.endIndex {
                    result += val
                } else {
                    result += val + self.printSeperator
                }
            }
            print(self.frmPfx, result, separator: "", terminator: self.printTerminator)
        }
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
        logMsg("Constructing an object with type of '\(name)' and storing in variable named '\(objcName)'")
        let args = constr.args.compactMap { visit($0) }
        let reduced = args.reduce([String]()) { $0 + $1 }
        guard let names = objectDecls[name]?.declarations.map({ $0.name.lexme }) else { return }
        let values = Dictionary(keys: names, values: reduced)
        let object = Object(name: name, values: values, stmt: constr)
        objects[objcName] = object
    }
    
    func nowhite(_ s: String) -> String {
        var trailing = s.drop(while: { $0 == " " })
        while trailing.last == " " {
            trailing.removeLast()
        }
        return String(trailing)
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
        logMsg("Visiting a function call\(end)", true, ui: "Call: \(callName) with args: \(callArgs).")
        _ = functions[callName]?.call(self, callArgs) != nil
        
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
        logMsg("Getting data from expression.", ui: "Expression: \(expr)")
        let rep = expr.rep
        if let tkn = rep.anyToken {
            if let object = objects[tkn.lexme], let val = object.values["*value"] {
                return [val]
            }
            return [tkn.lexme]
        } else if let literal = rep.literal {
            return [String(describing: literal)]
        } else if rep.call != nil {
            // TODO: Allow function creation with returns
        } else if let access = rep.access {
            return visit(access)
        }
        return nil
    }
    public func visit(_ assign: AssignStatement) -> Interpreter.Result {
        let varName = assign.name.lexme
        logMsg("Visiting assignment named '\(varName)'.", ui: "Statement: \(assign)")
        if assign.decl.type == .varDecl && variables[varName] != nil {
            logMsg("Cannot assign to already initilaized.", ui: "Already created value: \(variables[varName]!)")
            reportError("CCannot create the variable \(varName) because it already exists, did you mean to use 'set' instead?")
            return nil
        } else if assign.decl.type == .setDecl && variables[varName] == nil {
            logMsg("Cannot assign to nothing.")
            reportError("Cannot set to \(varName), did you mean to use 'var' instead?")
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
                let `init` = InitStatement(objectName: IncludedLibraries.Float.name, args: [Expression(rep: .literal(num))])
                let object = Object(name: "Float", values: ["*value":num.description], stmt: `init`)
                objects[varName] = object
            }
        }
        return nil
    }
    public func visit(_ set: SetStatement) -> Interpreter.Result {
        logMsg("Setting and editing an object..")
        objects[set.object.lexme]?.values[set.key.lexme] = visit(set.value)?.first
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
        if let importStmts = self.header?.imports {
            for stmt in importStmts {
                logMsg("Importing \"\(stmt.file)\"")
                if let code = stmt.code() {
                    let l = Lexer(code)
                    var t = [Token]()
                    l.formTokens(&t)
                    var p = Parser(stream: t)
                    var s = [Statement]()
                    try p.formStatements(&s)
                    for stmt in s {
                        self.visit(stmt: stmt)
                        if error != nil {
                            throw Error(message: "Error importing file", line: -2)
                        }
                    }
                }
            }
        }
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
