public class VirtualMachine {
    internal var queue = [UInt8]()//ContiguousBuffer<UInt8>(growthFactor: 2)
    internal var lines = [Int]()
    internal var stack = [Int32]()//ContiguousBuffer<Int32>(growthFactor: 2)
    public var disassemble = false
    
    public func enqueue(_ byte: UInt8, line: Int) {
        queue.append(byte)
        lines.append(line)
    }
    public func enqueue(value: Int32) {
        let value = UInt32(bitPattern: value)
        let seg1 = UInt8(value << 24 & 0xFF)
        let seg2 = UInt8(value << 16 & 0xFF)
        let seg3 = UInt8(value << 8 & 0xFF)
        let seg4 = UInt8(value & 0xFF)
        queue.append(seg1)
        queue.append(seg2)
        queue.append(seg3)
        queue.append(seg4)
    }
    
    func push(_ value: Int32) {
        stack.append(value)
    }
    func pop() -> Int32? {
        return stack.popLast()
    }
    func dequeue() -> (UInt8, Int)? {
        if queue.isEmpty {
            return nil
        } else {
            return (queue.removeFirst(), lines.removeFirst())
        }
    }
    func dequeueValue() -> UInt8? {
        return queue.isEmpty ? nil : queue.removeFirst()
    }
    
    func _binaryOp(_ op: (Int32, Int32) -> Int32) throws {
        if let rhs = pop(), let lhs = pop() {
            let result = op(lhs, rhs)
            push(result)
        } else {
            throw Error.notEnoughBytes
        }
    }
    
    public enum Error: Swift.Error {
        case notEnoughBytes
        case invalidBytes
    }
    
    public func execute() throws -> Bool {
        if let (byte, line) = dequeue(), let instruction = BytecodeInstruction(rawValue: byte) {
            if disassemble {
                print(instruction, "(line: \(line))")
            }
            switch instruction {
            case .end:
                return false
            case .print:
                if let top = pop() {
                    if let scalar = UnicodeScalar(UInt32(bitPattern: top)) {
                        print(scalar.description)
                    } else {
                        throw Error.invalidBytes
                    }
                } else {
                    throw Error.notEnoughBytes
                }
            case .push_num:
                if let seg1 = dequeueValue(), let seg2 = dequeueValue(), let seg3 = dequeueValue(), let seg4 = dequeueValue() {
                    let data = Data(bytes: [seg1, seg2, seg3, seg4])
                    
                    let bigEndianValue: Int32 = data.withUnsafeBytes {
                        return $0.pointee
                    }
                    let value = Int32(bigEndian: bigEndianValue)
                    push(value)
                } else {
                    throw Error.notEnoughBytes
                }
            case .push_bool:
                if let bool = dequeueValue() {
                    if bool == 0 {
                        push(0)
                    } else if bool == 1 {
                        push(1)
                    } else {
                        throw Error.invalidBytes
                    }
                } else {
                    throw Error.notEnoughBytes
                }
            case .negate:
                if let top = pop() {
                    push(-top)
                } else {
                    throw Error.notEnoughBytes
                }
            case .minus:
                try _binaryOp(&-)
            case .plus:
                try _binaryOp(&+)
            default:
                return false
            }
            return true
        }
        return false
    }
    
    public func executeAll() throws {
        if try execute() {
            try executeAll()
        }
    }
}
