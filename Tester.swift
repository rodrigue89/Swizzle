func measure(block: () -> ()) -> CFAbsoluteTime {
    let start = CFAbsoluteTimeGetCurrent()
    block()
    let end = CFAbsoluteTimeGetCurrent()
    return end - start
}

public class Tester {
    public typealias Test = (block: (Int) -> (), iterations: Int, name: String, repeated: Int)
    
    var tests = [Test]()
    public var log = true
    
    public func addTest(iterations: Int, name: String, repeating count: Int, block: @escaping (Int) -> ()) {
        tests.append((block, iterations, name, count))
    }
    public func testAll() {
        for test in tests {
            var times = [CFAbsoluteTime]()
            var maximum: CFAbsoluteTime = 0
            var sum: CFAbsoluteTime = 0
            for i in 1 ... test.repeated {
                if log {
                    print("Testing \(test.name) (\(i)):")
                }
                let time = measure {
                    for i in 1 ... test.iterations {
                        test.block(i)
                    }
                }
                times.append(time)
                maximum = max(maximum, time)
                sum += time
                if log {
                    let endMsg = "Completed \(test.iterations) iteration(s) in \(time) seconds"
                    print(endMsg)
                    print(String(repeating: "-", count: endMsg.count))
                }
            }
            print("Test Results (in \(sum) second\(sum == 1 ? "" : "s")):")
            var longest = 0
            for (i, time) in times.enumerated() {
                let counter = i + 1
                let graph = "\(i + 1):\(String(repeating: " ", count: 5 - counter.description.count))" + String(repeating: "■", count: Int(time / maximum * 50))
                longest = max(longest, graph.count)
                print(graph)
            }
            print(String(repeating: "-", count: longest))
        }
    }
}
