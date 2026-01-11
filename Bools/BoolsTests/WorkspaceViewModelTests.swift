//
//  WorkspaceViewModelTests.swift
//  Bools 2.0Tests
//
//  Модульные тесты для WorkspaceViewModel
//

import Testing
import Foundation
@testable import Bools
internal import CoreGraphics

@Suite("WorkspaceViewModel Tests")
@MainActor
struct WorkspaceViewModelTests {
    
    @MainActor
    @Test("ViewModel initialization")
    func testViewModelInitialization() async throws {
        let vm = WorkspaceViewModel()
        
        let gatesIsEmpty = vm.gates.isEmpty
        let wiresIsEmpty = vm.wires.isEmpty
        let zoom = vm.zoom
        let panOffset = vm.panOffset
        let selectedGateIDsIsEmpty = vm.selectedGateIDs.isEmpty
        #expect(gatesIsEmpty)
        #expect(wiresIsEmpty)
        #expect(zoom == 1.0)
        #expect(panOffset == .zero)
        #expect(selectedGateIDsIsEmpty)
    }
    
    @MainActor
    @Test("Add INPUT gate")
    func testAddInputGate() async throws {
        let vm = WorkspaceViewModel()
        
        vm.addGate(named: "INPUT", at: CGPoint(x: 100, y: 100))
        
        let gatesCount = vm.gates.count
        let firstGateBaseName = vm.gates.first?.baseName
        let firstGateInputPinsCount = vm.gates.first?.inputPins.count
        let firstGateOutputPinsCount = vm.gates.first?.outputPins.count
        #expect(gatesCount == 1)
        #expect(firstGateBaseName == "INPUT")
        #expect(firstGateInputPinsCount == 0)
        #expect(firstGateOutputPinsCount == 1)
    }
    
    @MainActor
    @Test("Add OUTPUT gate")
    func testAddOutputGate() async throws {
        let vm = WorkspaceViewModel()
        
        vm.addGate(named: "OUTPUT", at: CGPoint(x: 200, y: 100))
        
        let gatesCount = vm.gates.count
        let firstGateBaseName = vm.gates.first?.baseName
        let firstGateInputPinsCount = vm.gates.first?.inputPins.count
        let firstGateOutputPinsCount = vm.gates.first?.outputPins.count
        #expect(gatesCount == 1)
        #expect(firstGateBaseName == "OUTPUT")
        #expect(firstGateInputPinsCount == 1)
        #expect(firstGateOutputPinsCount == 0)
    }
    
    @MainActor
    @Test("Add AND gate")
    func testAddAndGate() async throws {
        let vm = WorkspaceViewModel()
        
        vm.addGate(named: "AND", at: CGPoint(x: 150, y: 150))
        
        let gatesCount = vm.gates.count
        let firstGateBaseName = vm.gates.first?.baseName
        let firstGateInputPinsCount = vm.gates.first?.inputPins.count
        let firstGateOutputPinsCount = vm.gates.first?.outputPins.count
        #expect(gatesCount == 1)
        #expect(firstGateBaseName == "AND")
        #expect(firstGateInputPinsCount == 2)
        #expect(firstGateOutputPinsCount == 1)
    }
    
    @MainActor
    @Test("Add multiple gates")
    func testAddMultipleGates() async throws {
        let vm = WorkspaceViewModel()
        
        vm.addGate(named: "INPUT", at: CGPoint(x: 50, y: 100))
        vm.addGate(named: "AND", at: CGPoint(x: 150, y: 100))
        vm.addGate(named: "OUTPUT", at: CGPoint(x: 250, y: 100))
        
        let gatesCount = vm.gates.count
        #expect(gatesCount == 3)
    }
    
    @MainActor
    @Test("Delete gate by ID")
    func testDeleteGate() async throws {
        let vm = WorkspaceViewModel()
        
        vm.addGate(named: "AND", at: .zero)
        let gateID = vm.gates.first!.id
        
        vm.deleteGate(id: gateID)
        
        let gatesIsEmpty = vm.gates.isEmpty
        #expect(gatesIsEmpty)
    }
    
    @MainActor
    @Test("Select gate")
    func testSelectGate() async throws {
        let vm = WorkspaceViewModel()
        
        vm.addGate(named: "OR", at: .zero)
        let gateID = vm.gates.first!.id
        
        vm.selectGate(gateID, multi: false)
        
        let selectedGateIDsContains = vm.selectedGateIDs.contains(gateID)
        #expect(selectedGateIDsContains)
    }
    
    @MainActor
    @Test("Multi-select gates")
    func testMultiSelectGates() async throws {
        let vm = WorkspaceViewModel()
        
        vm.addGate(named: "AND", at: CGPoint(x: 0, y: 0))
        vm.addGate(named: "OR", at: CGPoint(x: 100, y: 0))
        
        let gate1ID = vm.gates[0].id
        let gate2ID = vm.gates[1].id
        
        vm.selectGate(gate1ID, multi: false)
        vm.selectGate(gate2ID, multi: true)
        
        let selectedGateIDsCount = vm.selectedGateIDs.count
        let selectedGateIDsContains1 = vm.selectedGateIDs.contains(gate1ID)
        let selectedGateIDsContains2 = vm.selectedGateIDs.contains(gate2ID)
        #expect(selectedGateIDsCount == 2)
        #expect(selectedGateIDsContains1)
        #expect(selectedGateIDsContains2)
    }
    
    @MainActor
    @Test("Zoom in")
    func testZoomIn() async throws {
        let vm = WorkspaceViewModel()
        let initialZoom = vm.zoom
        
        vm.performZoom(factor: 1.5, anchorInView: .zero)
        
        let zoom = vm.zoom
        #expect(zoom == initialZoom * 1.5)
    }
    
    @MainActor
    @Test("Zoom out")
    func testZoomOut() async throws {
        let vm = WorkspaceViewModel()
        vm.zoom = 2.0
        
        vm.performZoom(factor: 0.5, anchorInView: .zero)
        
        let zoom = vm.zoom
        #expect(zoom == 1.0)
    }
    
    @MainActor
    @Test("Undo functionality")
    func testUndo() async throws {
        let vm = WorkspaceViewModel()
        
        // Начальное состояние
        let gatesIsEmpty1 = vm.gates.isEmpty
        let canUndo1 = vm.canUndo
        #expect(gatesIsEmpty1)
        #expect(!canUndo1)
        
        // Добавляем гейт
        vm.addGate(named: "AND", at: .zero)
        let gatesCount1 = vm.gates.count
        let canUndo2 = vm.canUndo
        #expect(gatesCount1 == 1)
        #expect(canUndo2)
        
        // Отменяем
        vm.undo()
        let gatesIsEmpty2 = vm.gates.isEmpty
        #expect(gatesIsEmpty2)
    }
    
    @MainActor
    @Test("Redo functionality")
    func testRedo() async throws {
        let vm = WorkspaceViewModel()
        
        vm.addGate(named: "OR", at: .zero)
        let gatesCount1 = vm.gates.count
        #expect(gatesCount1 == 1)
        
        vm.undo()
        let gatesIsEmpty = vm.gates.isEmpty
        let canRedo = vm.canRedo
        #expect(gatesIsEmpty)
        #expect(canRedo)
        
        vm.redo()
        let gatesCount2 = vm.gates.count
        let firstGateBaseName = vm.gates.first?.baseName
        #expect(gatesCount2 == 1)
        #expect(firstGateBaseName == "OR")
    }
    
    @MainActor
    @Test("Multiple undo/redo operations")
    func testMultipleUndoRedo() async throws {
        let vm = WorkspaceViewModel()
        
        vm.addGate(named: "INPUT", at: .zero)
        vm.addGate(named: "AND", at: CGPoint(x: 100, y: 0))
        vm.addGate(named: "OUTPUT", at: CGPoint(x: 200, y: 0))
        
        let gatesCount1 = vm.gates.count
        #expect(gatesCount1 == 3)
        
        vm.undo() // Удаляем OUTPUT
        let gatesCount2 = vm.gates.count
        #expect(gatesCount2 == 2)
        
        vm.undo() // Удаляем AND
        let gatesCount3 = vm.gates.count
        #expect(gatesCount3 == 1)
        
        vm.redo() // Возвращаем AND
        let gatesCount4 = vm.gates.count
        #expect(gatesCount4 == 2)
    }
}
