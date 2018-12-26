let tester = Tester()
tester.addTest(iterations: 1, name: "Virtual Machine", repeating: 10) { _ in
    do {
        let vm = VirtualMachine()
        vm.disassemble = true
        vm.enqueue(BYTE_PUSH_NUM, line: 1)
        vm.enqueue(value: 100)
        vm.enqueue(BYTE_PUSH_NUM, line: 1)
        vm.enqueue(value: 20)
        vm.enqueue(BYTE_PLUS, line: 1)
        vm.enqueue(BYTE_PRINT, line: 1)
        try vm.executeAll()
        
    }
    catch {
        print(error)
    }
}
tester.testAll()
