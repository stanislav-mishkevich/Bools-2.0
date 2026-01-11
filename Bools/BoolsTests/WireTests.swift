//
//  WireTests.swift
//  Bools 2.0Tests
//
//  Тесты соединений проводов
//

import Testing
import Foundation
@testable import Bools
internal import CoreGraphics

@Suite("Wire Tests")
@MainActor
struct WireTests {
    
    @MainActor
    @Test("Wire initialization")
    func testWireInitialization() async throws {
        let fromID = UUID()
        let toID = UUID()
        
        let wire = Wire(
            fromGateID: fromID,
            fromPinIndex: 0,
            toGateID: toID,
            toPinIndex: 0
        )
        
        let wireSignal = wire.signal
        
        #expect(wire.fromGateID == fromID)
        #expect(wire.toGateID == toID)
        #expect(wire.fromPinIndex == 0)
        #expect(wire.toPinIndex == 0)
        #expect(wireSignal == false) // Сигнал по умолчанию
    }
    
    @MainActor
    @Test("Wire encoding and decoding")
    func testWireCodable() async throws {
        let original = Wire(
            fromGateID: UUID(),
            fromPinIndex: 0,
            toGateID: UUID(),
            toPinIndex: 1
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Wire.self, from: data)
        
        #expect(decoded.fromGateID == original.fromGateID)
        #expect(decoded.toGateID == original.toGateID)
        #expect(decoded.fromPinIndex == original.fromPinIndex)
        #expect(decoded.toPinIndex == original.toPinIndex)
    }
    
    @MainActor
    @Test("Add wire to workspace")
    func testAddWire() async throws {
        let vm = WorkspaceViewModel()
        
        // Добавить два гейта
        vm.addGate(named: "INPUT", at: CGPoint(x: 0, y: 100))
        vm.addGate(named: "OUTPUT", at: CGPoint(x: 200, y: 100))
        
        let inputGate = vm.gates[0]
        let outputGate = vm.gates[1]
        
        // Создать провод
        let wire = Wire(
            fromGateID: inputGate.id,
            fromPinIndex: 0,
            toGateID: outputGate.id,
            toPinIndex: 0
        )
        
        vm.wires.append(wire)
        
        let wiresCount = vm.wires.count
        let firstWire = vm.wires.first
        
        #expect(wiresCount == 1)
        #expect(firstWire?.fromGateID == inputGate.id)
        #expect(firstWire?.toGateID == outputGate.id)
    }
    
    @MainActor
    @Test("Delete wire")
    func testDeleteWire() async throws {
        let vm = WorkspaceViewModel()
        
        vm.addGate(named: "INPUT", at: .zero)
        vm.addGate(named: "OUTPUT", at: CGPoint(x: 100, y: 0))
        
        let wire = Wire(
            fromGateID: vm.gates[0].id,
            fromPinIndex: 0,
            toGateID: vm.gates[1].id,
            toPinIndex: 0
        )
        vm.wires.append(wire)
        
        let wiresCountBefore = vm.wires.count
        #expect(wiresCountBefore == 1)
        
        vm.deleteWire(id: wire.id)
        
        let wiresIsEmpty = vm.wires.isEmpty
        #expect(wiresIsEmpty)
    }
}
