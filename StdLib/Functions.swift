// MARK: Print
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
    i.stream?.write(Transfers.shouldTraceExec ? final : result)
    print(final, terminator: i.printTerminator)
}

// MARK: Operations
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
    let set = SetStatement(object: i.asToken(object), key: i.asToken(key), value: Expression(rep: .anyToken(i.asToken(value))))
    i.visit(set)
}
i.addFunc("ast_objc_set2", ["object", "key", "object2", "value2"]) { (_, args) in
    let object = i.nowhite(args[0])
    let key = i.nowhite(args[1])
    let object2 = i.nowhite(args[2])
    let value2 = i.nowhite(args[3])
    let access = AccessStatement(object: i.asToken(object2), key: i.asToken(value2))
    let set = SetStatement(object: i.asToken(object), key: i.asToken(key), value: Expression(rep: .access(access)))
    i.visit(set)
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
