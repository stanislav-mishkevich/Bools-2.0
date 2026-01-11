//
//  PersistenceTests.swift
//  Bools 2.0Tests
//
//  Тесты для сохранения и загрузки рабочего пространства
//

import Testing
import Foundation
@testable import Bools
internal import CoreGraphics

@Suite("Persistence Tests")
@MainActor
struct PersistenceTests {
    
    @MainActor
    @Test("Save and load workspace")
    func testSaveAndLoad() async throws {
        let vm = WorkspaceViewModel()
        
        // Создать простую схему
        vm.addGate(named: "INPUT", at: CGPoint(x: 50, y: 100))
        vm.addGate(named: "AND", at: CGPoint(x: 200, y: 100))
        vm.addGate(named: "OUTPUT", at: CGPoint(x: 350, y: 100))
        
        // Создать временный файл
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("test_workspace.json")
        
        // Сохранить
        try vm.saveToURL(tempURL)
        
        // Создать новый экземпляр ViewModel и загрузить данные
        let vm2 = WorkspaceViewModel()
        try await vm2.loadFromURL(tempURL)
        
        let gatesCount = vm2.gates.count
        let firstGateBaseName = vm2.gates[0].baseName
        let secondGateBaseName = vm2.gates[1].baseName
        let thirdGateBaseName = vm2.gates[2].baseName
        #expect(gatesCount == 3)
        #expect(firstGateBaseName == "INPUT")
        #expect(secondGateBaseName == "AND")
        #expect(thirdGateBaseName == "OUTPUT")
        
        // Удалить временный файл
        try? FileManager.default.removeItem(at: tempURL)
    }
    
    @MainActor
    @Test("Save workspace with wires")
    func testSaveWithWires() async throws {
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
        
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("test_wires.json")
        
        try vm.saveToURL(tempURL)
        
        let vm2 = WorkspaceViewModel()
        try await vm2.loadFromURL(tempURL)
        
        let wiresCount = vm2.wires.count
        let firstWireFromGateID = vm2.wires.first?.fromGateID
        let firstWireToGateID = vm2.wires.first?.toGateID
        #expect(wiresCount == 1)
        #expect(firstWireFromGateID == wire.fromGateID)
        #expect(firstWireToGateID == wire.toGateID)
        
        try? FileManager.default.removeItem(at: tempURL)
    }
    
    @MainActor
    @Test("Save empty workspace")
    func testSaveEmptyWorkspace() async throws {
        let vm = WorkspaceViewModel()
        
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("test_empty.json")
        
        try vm.saveToURL(tempURL)
        
        let vm2 = WorkspaceViewModel()
        try await vm2.loadFromURL(tempURL)
        
        let gatesIsEmpty = vm2.gates.isEmpty
        let wiresIsEmpty = vm2.wires.isEmpty
        #expect(gatesIsEmpty)
        #expect(wiresIsEmpty)
        
        try? FileManager.default.removeItem(at: tempURL)
    }
    
    @MainActor
    @Test("Load corrupted file should throw")
    func testLoadCorruptedFile() async throws {
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("corrupted.json")
        
        // Записать некорректный JSON
        let corruptedData = "{ invalid json }".data(using: .utf8)!
        try corruptedData.write(to: tempURL)
        
        let vm = WorkspaceViewModel()
        
        // Должно выбросить ошибку
        var didThrow = false
        do {
            try await vm.loadFromURL(tempURL)
        } catch {
            didThrow = true
        }
        
        #expect(didThrow)
        
        try? FileManager.default.removeItem(at: tempURL)
    }
}
