//
//  GateTests.swift
//  Bools 2.0Tests
//
//  Модульные тесты для модели Gate
//

import Testing
import Foundation
@testable import Bools
internal import CoreGraphics

@Suite("Gate Model Tests")
@MainActor
struct GateTests {
    
    @MainActor
    @Test("Gate initialization with default values")
    func testGateInitialization() async throws {
        let gate = Gate(name: "AND", position: CGPoint(x: 100, y: 200))
        
        let baseName = gate.baseName
        let position = gate.position
        let inputPinsCount = gate.inputPins.count
        let outputPinsCount = gate.outputPins.count
        let userSuffix = gate.userSuffix
        
        #expect(baseName == "AND")
        #expect(position.x == 100)
        #expect(position.y == 200)
        #expect(inputPinsCount == 1)
        #expect(outputPinsCount == 1)
        #expect(userSuffix == nil)
    }
    
    @MainActor
    @Test("Gate initialization with custom pin counts")
    func testGateWithCustomPins() async throws {
        let gate = Gate(name: "OR", position: .zero, inputCount: 2, outputCount: 1)
        
        let inputPinsCount = gate.inputPins.count
        let outputPinsCount = gate.outputPins.count
        
        #expect(inputPinsCount == 2)
        #expect(outputPinsCount == 1)
    }
    
    @MainActor
    @Test("Gate display name without suffix")
    func testDisplayNameWithoutSuffix() async throws {
        let gate = Gate(name: "XOR", position: .zero)
        let displayName = gate.displayName
        #expect(displayName == "XOR")
    }
    
    @MainActor
    @Test("Gate display name with suffix")
    func testDisplayNameWithSuffix() async throws {
        var gate = Gate(name: "AND", position: .zero)
        gate.userSuffix = "1"
        
        let displayName = gate.displayName
        #expect(displayName == "AND 1")
    }
    
    @MainActor
    @Test("Gate encoding and decoding")
    func testGateCodable() async throws {
        let original = Gate(name: "NAND", position: CGPoint(x: 50, y: 75), inputCount: 2, outputCount: 1)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Gate.self, from: data)
        
        let decodedBaseName = decoded.baseName
        let decodedPosition = decoded.position
        let decodedInputPinsCount = decoded.inputPins.count
        let decodedOutputPinsCount = decoded.outputPins.count
        
        let originalBaseName = original.baseName
        let originalPosition = original.position
        let originalInputPinsCount = original.inputPins.count
        let originalOutputPinsCount = original.outputPins.count
        
        #expect(decodedBaseName == originalBaseName)
        #expect(decodedPosition.x == originalPosition.x)
        #expect(decodedPosition.y == originalPosition.y)
        #expect(decodedInputPinsCount == originalInputPinsCount)
        #expect(decodedOutputPinsCount == originalOutputPinsCount)
    }
    
    @MainActor
    @Test("Gate with description")
    func testGateWithDescription() async throws {
        let description = "Test gate description"
        let gate = Gate(name: "TEST", position: .zero, description: description)
        
        let gateDescription = gate.description
        #expect(gateDescription == description)
    }
}
