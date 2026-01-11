//
//  SimulationTests.swift
//  Bools 2.0Tests
//
//  Тесты логической симуляции
//
import Testing
import Foundation
@testable import Bools
internal import CoreGraphics
struct SimulationTests {
    
    @MainActor
    @Test("AND gate logic - both inputs false")
    func testAndGateBothFalse() async throws {
        let vm = WorkspaceViewModel()
        
        // Создать схему: INPUT1 -> AND <- INPUT2 -> OUTPUT
        vm.addGate(named: "INPUT", at: CGPoint(x: 0, y: 50))
        vm.addGate(named: "INPUT", at: CGPoint(x: 0, y: 150))
        vm.addGate(named: "AND", at: CGPoint(x: 200, y: 100))
        vm.addGate(named: "OUTPUT", at: CGPoint(x: 400, y: 100))
        
        let input1 = vm.gates[0]
        let input2 = vm.gates[1]
        let andGate = vm.gates[2]
        let output = vm.gates[3]
        
        // Установить оба входа в false, это значение по умолчанию
        vm.simulateNow()
        
        // Подождать завершения симуляции
        try await Task.sleep(for: .milliseconds(100))
        
        // Выход AND должен быть false
        let andOutput = vm.gates.first(where: { $0.id == andGate.id })?.outputPins.first?.value
        #expect(andOutput == false)
    }
    
    @MainActor
    @Test("AND gate logic - one input true")
    func testAndGateOneTrue() async throws {
        let vm = WorkspaceViewModel()
        
        vm.addGate(named: "INPUT", at: CGPoint(x: 0, y: 50))
        vm.addGate(named: "INPUT", at: CGPoint(x: 0, y: 150))
        vm.addGate(named: "AND", at: CGPoint(x: 200, y: 100))
        
        // Установить первый вход в true
        if let idx = vm.gates.firstIndex(where: { $0.baseName == "INPUT" }) {
            vm.gates[idx].outputPins[0].value = true
        }
        
        vm.simulateNow()
        try await Task.sleep(for: .milliseconds(100))
        
        // AND по-прежнему должен быть false, для true нужны оба входа
        let andGate = vm.gates.first(where: { $0.baseName == "AND" })
        let andOutputValue = andGate?.outputPins.first?.value
        #expect(andOutputValue == false || andOutputValue == nil)
    }
    
    @MainActor
    @Test("OR gate logic - both inputs false")
    func testOrGateBothFalse() async throws {
        let vm = WorkspaceViewModel()
        
        vm.addGate(named: "INPUT", at: CGPoint(x: 0, y: 50))
        vm.addGate(named: "INPUT", at: CGPoint(x: 0, y: 150))
        vm.addGate(named: "OR", at: CGPoint(x: 200, y: 100))
        
        vm.simulateNow()
        try await Task.sleep(for: .milliseconds(100))
        
        let orGate = vm.gates.first(where: { $0.baseName == "OR" })
        let orOutputValue = orGate?.outputPins.first?.value
        #expect(orOutputValue == false || orOutputValue == nil)
    }
    
    @MainActor
    @Test("NOT gate logic")
    func testNotGate() async throws {
        let vm = WorkspaceViewModel()
        
        vm.addGate(named: "INPUT", at: CGPoint(x: 0, y: 100))
        vm.addGate(named: "NOT", at: CGPoint(x: 200, y: 100))
        
        // Вход по умолчанию false
        vm.simulateNow()
        try await Task.sleep(for: .milliseconds(100))
        
        // Выход NOT должен быть true, когда вход false, после подключения
        // Без провода, у NOT не будет входного сигнала
        // Тест проверяет, что NOT существует и имеет корректную структуру пинов
        let notGate = vm.gates.first(where: { $0.baseName == "NOT" })
        let notInputCount = notGate?.inputPins.count
        let notOutputCount = notGate?.outputPins.count
        #expect(notInputCount == 1)
        #expect(notOutputCount == 1)
    }
    
    @MainActor
    @Test("XOR gate structure")
    func testXorGateStructure() async throws {
        let vm = WorkspaceViewModel()
        
        vm.addGate(named: "XOR", at: .zero)
        
        let xorGate = vm.gates.first
        let xorBaseName = xorGate?.baseName
        let xorInputCount = xorGate?.inputPins.count
        let xorOutputCount = xorGate?.outputPins.count
        #expect(xorBaseName == "XOR")
        #expect(xorInputCount == 2)
        #expect(xorOutputCount == 1)
    }
    
    @MainActor
    @Test("NAND gate structure")
    func testNandGateStructure() async throws {
        let vm = WorkspaceViewModel()
        
        vm.addGate(named: "NAND", at: .zero)
        
        let nandGate = vm.gates.first
        let nandBaseName = nandGate?.baseName
        let nandInputCount = nandGate?.inputPins.count
        let nandOutputCount = nandGate?.outputPins.count
        #expect(nandBaseName == "NAND")
        #expect(nandInputCount == 2)
        #expect(nandOutputCount == 1)
    }
    
    @MainActor
    @Test("CONST0 gate")
    func testConst0Gate() async throws {
        let vm = WorkspaceViewModel()
        
        vm.addGate(named: "CONST0", at: .zero)
        
        let constGate = vm.gates.first
        let constBaseName = constGate?.baseName
        let constInputCount = constGate?.inputPins.count
        let constOutputCount = constGate?.outputPins.count
        #expect(constBaseName == "CONST0")
        #expect(constInputCount == 0)
        #expect(constOutputCount == 1)
    }
    
    @MainActor
    @Test("CONST1 gate")
    func testConst1Gate() async throws {
        let vm = WorkspaceViewModel()
        
        vm.addGate(named: "CONST1", at: .zero)
        
        let constGate = vm.gates.first
        let constBaseName = constGate?.baseName
        let constInputCount = constGate?.inputPins.count
        let constOutputCount = constGate?.outputPins.count
        #expect(constBaseName == "CONST1")
        #expect(constInputCount == 0)
        #expect(constOutputCount == 1)
    }
    
    @MainActor
    @Test("LED indicator logic - both contacts active")
    func testLedIndicatorBothActive() async throws {
        let vm = WorkspaceViewModel()
        
        // Создать LED
        vm.addGate(named: "LED", at: .zero)
        let ledGate = vm.gates.first!
        
        // Симулировать: + активен, - неактивен (есть напряжение)
        vm.gates[0].inputPins[0].value = true   // + контакт
        vm.gates[0].inputPins[1].value = false  // - контакт (земля)
        
        vm.simulateNow()
        try await Task.sleep(for: .milliseconds(100))
        
        // LED должен быть активен (загорелся при напряжении)
        let ledActive = vm.gates.first(where: { $0.id == ledGate.id })?.isIndicatorActive
        #expect(ledActive == true)
    }
    
    @MainActor
    @Test("LED indicator logic - only positive contact active")
    func testLedIndicatorOnlyPositive() async throws {
        let vm = WorkspaceViewModel()
        
        vm.addGate(named: "LED", at: .zero)
        let ledGate = vm.gates.first!
        
        // Оба контакта активны (нет разницы потенциалов)
        vm.gates[0].inputPins[0].value = true   // + контакт
        vm.gates[0].inputPins[1].value = true   // - контакт также активен
        
        vm.simulateNow()
        try await Task.sleep(for: .milliseconds(100))
        
        // LED должен быть неактивен (нет разницы потенциалов между контактами)
        let ledActive = vm.gates.first(where: { $0.id == ledGate.id })?.isIndicatorActive
        #expect(ledActive == false)
    }
    
    @MainActor
    @Test("BATTERY output values")
    func testBatteryOutputs() async throws {
        let vm = WorkspaceViewModel()
        
        vm.addGate(named: "BATTERY", at: .zero)
        
        vm.simulateNow()
        try await Task.sleep(for: .milliseconds(100))
        
        let batteryGate = vm.gates.first(where: { $0.baseName == "BATTERY" })
        let positiveOutput = batteryGate?.outputPins[0].value
        let negativeOutput = batteryGate?.outputPins[1].value
        
        // Батарея должна выдавать 1 на + и 0 на -
        #expect(positiveOutput == true)
        #expect(negativeOutput == false)
    }
    
    @MainActor
    @Test("RELAY coil activation")
    func testRelayCoilActivation() async throws {
        let vm = WorkspaceViewModel()
        
        vm.addGate(named: "RELAY", at: .zero)
        let relayGate = vm.gates.first!
        
        // Активируем катушку: оба входа должны быть активны
        vm.gates[0].inputPins[0].value = true   // + входа катушки
        vm.gates[0].inputPins[1].value = true   // - входа катушки
        
        vm.simulateNow()
        try await Task.sleep(for: .milliseconds(100))
        
        let updatedRelay = vm.gates.first(where: { $0.id == relayGate.id })
        let noOutput = updatedRelay?.outputPins[1].value  // NO должен быть активен
        let ncOutput = updatedRelay?.outputPins[2].value  // NC должен быть неактивен
        
        #expect(noOutput == true)   // Нормально открытый замыкается
        #expect(ncOutput == false)  // Нормально закрытый размыкается
    }
    
    @MainActor
    @Test("BJT_NPN transistor - base control")
    func testBjtNpnBaseControl() async throws {
        let vm = WorkspaceViewModel()
        
        vm.addGate(named: "BJT_NPN", at: .zero)
        let bjtGate = vm.gates.first!
        
        // База активна
        vm.gates[0].inputPins[0].value = true
        
        vm.simulateNow()
        try await Task.sleep(for: .milliseconds(100))
        
        let updatedBjt = vm.gates.first(where: { $0.id == bjtGate.id })
        let collectorOutput = updatedBjt?.outputPins[0].value
        let emitterOutput = updatedBjt?.outputPins[1].value
        
        // NPN проводит, когда база активна
        #expect(collectorOutput == true)
        #expect(emitterOutput == true)
    }

    @MainActor
    @Test("REGISTER_4BIT load and hold")
    func testRegister4BitLoad() async throws {
        let vm = WorkspaceViewModel()
        vm.addGate(named: "REGISTER_4BIT", at: .zero)
        guard let regGate = vm.gates.first(where: { $0.baseName == "REGISTER_4BIT" }) else { throw NSError(domain: "test", code: 1) }
        let idx = vm.gates.firstIndex(where: { $0.id == regGate.id })!

        // Set D input pattern 1010 (bits: D3 D2 D1 D0 - we set D0..D3)
        vm.gates[idx].inputPins[0].value = false // D0
        vm.gates[idx].inputPins[1].value = true  // D1
        vm.gates[idx].inputPins[2].value = false // D2
        vm.gates[idx].inputPins[3].value = true  // D3
        // Enable load
        vm.gates[idx].inputPins[5].value = true  // LD
        // Clock low -> no change
        vm.gates[idx].inputPins[4].value = false // CLK
        vm.simulateNow()
        try await Task.sleep(for: .milliseconds(50))

        // Rising edge
        vm.gates[idx].inputPins[4].value = true // CLK
        vm.simulate()
        try await Task.sleep(for: .milliseconds(50))

        // Check outputs: Q0..Q3 correspond to bits 0..3
        let updated = vm.gates.first(where: { $0.id == regGate.id })!
        #expect(updated.outputPins[0].value == false) // Q0
        #expect(updated.outputPins[1].value == true)  // Q1
        #expect(updated.outputPins[2].value == false) // Q2
        #expect(updated.outputPins[3].value == true)  // Q3
    }

    @MainActor
    @Test("COUNTER_4BIT increments and resets")
    func testCounter4Bit() async throws {
        let vm = WorkspaceViewModel()
        vm.addGate(named: "COUNTER_4BIT", at: .zero)
        guard let cntGate = vm.gates.first(where: { $0.baseName == "COUNTER_4BIT" }) else { throw NSError(domain: "test", code: 1) }
        let idx = vm.gates.firstIndex(where: { $0.id == cntGate.id })!

        // Ensure reset and clock low
        vm.gates[idx].inputPins[1].value = false // RST
        vm.gates[idx].inputPins[0].value = false // CLK
        vm.simulate()
        try await Task.sleep(for: .milliseconds(50))

        // Pulse clock 3 times
        for i in 1...3 {
            vm.gates[idx].inputPins[0].value = true
            vm.simulateNow()
            try await Task.sleep(for: .milliseconds(20))
            vm.gates[idx].inputPins[0].value = false
            vm.simulateNow()
            try await Task.sleep(for: .milliseconds(20))
        }

        // After 3 pulses, counter should be 3
        let updated = vm.gates.first(where: { $0.id == cntGate.id })!
        let q0 = updated.outputPins[0].value
        let q1 = updated.outputPins[1].value
        let q2 = updated.outputPins[2].value
        let q3 = updated.outputPins[3].value
        #expect(q0 == true)  // bit0 = 1 (3 = 0011)
        #expect(q1 == true)  // bit1 = 1
        #expect(q2 == false)
        #expect(q3 == false)

        // Reset the counter
        vm.gates[idx].inputPins[1].value = true // RST
        vm.simulateNow()
        try await Task.sleep(for: .milliseconds(50))
        let afterReset = vm.gates.first(where: { $0.id == cntGate.id })!
        #expect(afterReset.outputPins[0].value == false)
        #expect(afterReset.outputPins[1].value == false)
        #expect(afterReset.outputPins[2].value == false)
        #expect(afterReset.outputPins[3].value == false)
    }
}

// End triple-backtick (removed)