import Foundation

public class ContiguousBuffer<Element> {
    internal var first: UnsafeMutablePointer<Element>
    internal var last: UnsafeMutablePointer<Element> {
        return first + count
    }
    internal let growthFactor: Int
    internal var count = 0 {
        didSet {
            if count >= capacity {
                _reserve(capacity: count)
            }
        }
    }
    internal var capacity = 0
    
    public init(growthFactor: Int) {
        self.first = UnsafeMutablePointer<Element>.allocate(capacity: 0)
        self.growthFactor = growthFactor
    }
    
    func _reserve(capacity newC: Int) {
        let newCapacity = max(newC * growthFactor, capacity)
        let new = UnsafeMutablePointer<Element>.allocate(capacity: newCapacity)
        new.assign(from: first, count: count)
        first = new
    }
    public func _value(at index: Int) -> Element? {
        guard count > index else { return nil }
        return (first + index).pointee
    }
    public func _append(_ value: Element) {
        (first + count).pointee = value
        count += 1
    }
    public func _removeFirst() {
        let new = first + 1
        first.deinitialize(count: 1)
        first.deallocate()
        first = new
    }
    
    deinit {
        first.deinitialize(count: count)
        first.deallocate()
    }
}

func measure(block: () -> ()) -> CFAbsoluteTime {
    let start = CFAbsoluteTimeGetCurrent()
    block()
    let end = CFAbsoluteTimeGetCurrent()
    return end - start
}

class Tester {
    public typealias Test = (block: (Int) -> (), iterations: Int, name: String, repeated: Int)
    var tests = [Test]()
    func addTest(iterations: Int, name: String, repeating count: Int, block: @escaping (Int) -> ()) {
        tests.append((block, iterations, name, count))
    }
    func testAll() {
        for test in tests {
            var times = [CFAbsoluteTime]()
            for i in 1 ... test.repeated {
                print("Testing \(test.name) (\(i)):")
                let time = measure {
                    for i in 1 ... test.iterations {
                        test.block(i)
                    }
                }
                times.append(time)
                let endMsg = "Completed \(test.iterations) iterations in \(time) seconds"
                print(endMsg)
                print(String(repeating: "-", count: endMsg.count))
            }
            print("Bar Graph")
            var longest = 0
            for (i, time) in times.enumerated() {
                let counter = i + 1
                let graph = "\(i + 1):\(String(repeating: " ", count: 5 - counter.description.count))" + String(repeating: "■", count: Int(time * 50))
                longest = max(longest, graph.count)
                print(graph)
            }
            print(String(repeating: "-", count: longest))
            //let finalMsg = "-------------------"
        }
    }
}


let buffer = ContiguousBuffer<Int>(growthFactor: 2)
let tester = Tester()

//measure {
//    buffer._append(1)
//}
//measure {
//    buffer._append(2)
//}
//measure {
//    buffer._value(at: 0)
//}
//measure {
//    buffer._value(at: 1)
//}

tester.addTest(iterations: 1000, name: "Reallocation (1)", repeating: 10) { i in
     buffer._append(i)
}
tester.testAll()


