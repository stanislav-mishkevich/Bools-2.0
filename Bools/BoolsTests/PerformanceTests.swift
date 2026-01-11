//
//  PerformanceTests.swift
//  Bools 2.0Tests
//
//  Тесты производительности для больших схем
//

import Testing
import Foundation
@testable import Bools

@Suite("Performance Tests")
@MainActor
struct PerformanceTests {
    
    @MainActor
    @Test("Add 100 gates performance")
    func testAdd100Gates() async throws {
        let vm = WorkspaceViewModel()
        
        let startTime = Date()
        
        for i in 0..<100 {
            let x = CGFloat(i % 10) * 150
            let y = CGFloat(i / 10) * 150
            vm.addGate(named: "AND", at: CGPoint(x: x, y: y))
        }
        
        let elapsed = Date().timeIntervalSince(startTime)
        
        let gatesCount = vm.gates.count
        #expect(gatesCount == 100)
        #expect(elapsed < 1.0) // Выполняется менее чем за 1 секунду
    }
    
    @MainActor
    @Test("Simulation with 50 gates")
    func testSimulation50Gates() async throws {
        let vm = WorkspaceViewModel()
        
        // Создать цепочку гейтов
        for i in 0..<50 {
            vm.addGate(named: i % 2 == 0 ? "AND" : "OR", at: CGPoint(x: CGFloat(i * 100), y: 100))
        }
        
        let startTime = Date()
        vm.simulateNow()
        try await Task.sleep(for: .milliseconds(200))
        let elapsed = Date().timeIntervalSince(startTime)
        
        #expect(elapsed < 0.5) // Симуляция должна быть быстрой
    }
    
    @MainActor
    @Test("Undo/Redo with many operations")
    func testUndoRedoPerformance() async throws {
        let vm = await WorkspaceViewModel()
        
        // Выполнить 20 операций
        for i in 0..<20 {
            vm.addGate(named: "AND", at: CGPoint(x: CGFloat(i * 50), y: 100))
        }
        
        let startTime = Date()
        
        // Отменить все операции
        for _ in 0..<20 {
            vm.undo()
        }
        
        // Вернуть все операции
        for _ in 0..<20 {
            vm.redo()
        }
        
        let elapsed = Date().timeIntervalSince(startTime)
        
        let gatesCount = vm.gates.count
        #expect(gatesCount == 20)
        #expect(elapsed < 0.5)
    }
    
    @MainActor
    @Test("Large workspace save/load")
    func testLargeWorkspaceSaveLoad() async throws {
        let vm = WorkspaceViewModel()
        
        // Создать большую схему
        for i in 0..<100 {
            vm.addGate(named: "AND", at: CGPoint(x: CGFloat(i * 50), y: CGFloat((i % 10) * 50)))
        }
        
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("large_workspace.json")
        
        let startSave = Date()
        try vm.saveToURL(tempURL)
        let saveDuration = Date().timeIntervalSince(startSave)
        
        let vm2 = WorkspaceViewModel()
        
        let startLoad = Date()
        try await vm2.loadFromURL(tempURL)
        let loadDuration = Date().timeIntervalSince(startLoad)
        
        let gatesCount = vm2.gates.count
        #expect(gatesCount == 100)
        #expect(saveDuration < 1.0)
        #expect(loadDuration < 1.0)
        
        try? FileManager.default.removeItem(at: tempURL)
    }
}
