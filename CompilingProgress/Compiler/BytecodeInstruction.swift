public enum BytecodeInstruction: UInt8, CustomStringConvertible{
    case end
    case print
    case push_num
    case negate
    case minus
    case plus
    case multiply
    case divide
    case push_bool
    case not
    case and
    case or
    public var description: String {
        switch self {
        case .end: return "END"
        case .print: return "PRINT"
        case .push_num: return "PUSH_NUM"
        case .negate: return "NEGATE"
        case .minus: return "MINUS"
        case .plus: return "PLUS"
        case .multiply: return "MULTIPLY"
        case .divide: return "DIVIDE"
        case .push_bool: return "PUSH_BOOL"
        case .not: return "NOT"
        case .and: return "AND"
        case .or: return "OR"
        }
    }
}

public func disassemble<Stream: TextOutputStream>(_ byte: UInt8, to stream: inout Stream) {
    if let instruction = BytecodeInstruction(rawValue: byte) {
        stream.write(instruction.description)
    }
}

public func disassemble(_ byte: UInt8) {
    if let instruction = BytecodeInstruction(rawValue: byte) {
        print("BYTE_\(instruction.description)")
    }
}

public let BYTE_END = BytecodeInstruction.end.rawValue
public let BYTE_PRINT = BytecodeInstruction.print.rawValue
public let BYTE_PUSH_NUM = BytecodeInstruction.push_num.rawValue
public let BYTE_NEGATE = BytecodeInstruction.negate.rawValue
public let BYTE_MINUS = BytecodeInstruction.minus.rawValue
public let BYTE_PLUS = BytecodeInstruction.plus.rawValue
public let BYTE_MULTIPLY = BytecodeInstruction.multiply.rawValue
public let BYTE_DIVIDE = BytecodeInstruction.divide.rawValue
public let BYTE_PUSH_BOOL = BytecodeInstruction.push_bool.rawValue
public let BYTE_NOT = BytecodeInstruction.not.rawValue
public let BYTE_AND = BytecodeInstruction.and.rawValue
public let BYTE_OR = BytecodeInstruction.or.rawValue
