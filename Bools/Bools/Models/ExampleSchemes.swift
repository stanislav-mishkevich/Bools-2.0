import Foundation
import CoreGraphics

struct ExampleScheme {
    let name: String
    let description: String
    let category: String
    let gates: [Gate]
    let wires: [Wire]
}

class ExampleSchemes {
    static var all: [ExampleScheme] {
        return [
            halfAdder,
            fullAdder,
            srLatch,
            dFlipFlop,
            ringOscillator,
            pulseOscillator,
            srLatchWithLED,
            relayLatch,
            andGateFromNand,
            xorFromBasic,
            multiplexer2to1,
            simpleLEDCircuit,
            pushButtonLED,
            relayCircuit,
            relaySwitch,
            buzzerAlarm,
            trafficLight,
            binaryCalculatorWithDisplay,
            // Новые примеры с компонентами Logisim
            dFlipFlopCounter,
            tFlipFlopToggle,
            jkFlipFlopExample,
            mux4to1DataSelector,
            demux1to4Distributor,
            counter4BitExample,
            register4BitExample,
            decoder3to8Example,
            comparator4BitExample,
            transistorSwitch
        ]
    }
    
    // MARK: - Half Adder (Полусумматор)
    static var halfAdder: ExampleScheme {
        let inputA = UUID()
        let inputB = UUID()
        let xorGate = UUID()
        let andGate = UUID()
        let outputSum = UUID()
        let outputCarry = UUID()
        
        return ExampleScheme(
            name: NSLocalizedString("example.halfAdder.name", comment: ""),
            description: NSLocalizedString("example.halfAdder.desc", comment: ""),
            category: NSLocalizedString("example.halfAdder.category", comment: ""),
            gates: [
                Gate(id: inputA, name: "INPUT", position: CGPoint(x: 100, y: 100), inputCount: 0, outputCount: 1, description: NSLocalizedString("gateInstance.inputA", comment: "")),
                Gate(id: inputB, name: "INPUT", position: CGPoint(x: 100, y: 200), inputCount: 0, outputCount: 1, description: NSLocalizedString("gateInstance.inputB", comment: "")),
                Gate(id: xorGate, name: "XOR", position: CGPoint(x: 300, y: 150), inputCount: 2, outputCount: 1, description: NSLocalizedString("gateInstance.outputSum", comment: "")),
                Gate(id: andGate, name: "AND", position: CGPoint(x: 300, y: 250), inputCount: 2, outputCount: 1, description: NSLocalizedString("gateInstance.outputCarry", comment: "")),
                Gate(id: outputSum, name: "OUTPUT", position: CGPoint(x: 500, y: 150), inputCount: 1, outputCount: 0, description: NSLocalizedString("gateInstance.outputSum", comment: "")),
                Gate(id: outputCarry, name: "OUTPUT", position: CGPoint(x: 500, y: 250), inputCount: 1, outputCount: 0, description: NSLocalizedString("gateInstance.outputCarry", comment: ""))
            ],
            wires: [
                Wire(fromGateID: inputA, fromPinIndex: 0, toGateID: xorGate, toPinIndex: 0),
                Wire(fromGateID: inputB, fromPinIndex: 0, toGateID: xorGate, toPinIndex: 1),
                Wire(fromGateID: inputA, fromPinIndex: 0, toGateID: andGate, toPinIndex: 0),
                Wire(fromGateID: inputB, fromPinIndex: 0, toGateID: andGate, toPinIndex: 1),
                Wire(fromGateID: xorGate, fromPinIndex: 0, toGateID: outputSum, toPinIndex: 0),
                Wire(fromGateID: andGate, fromPinIndex: 0, toGateID: outputCarry, toPinIndex: 0)
            ]
        )
    }
    
    // MARK: - Full Adder (Полный сумматор)
    static var fullAdder: ExampleScheme {
        let inputA = UUID()
        let inputB = UUID()
        let inputCin = UUID()
        let xor1 = UUID()
        let xor2 = UUID()
        let and1 = UUID()
        let and2 = UUID()
        let orGate = UUID()
        let outputSum = UUID()
        let outputCout = UUID()
        
        return ExampleScheme(
            name: NSLocalizedString("example.fullAdder.name", comment: ""),
            description: NSLocalizedString("example.fullAdder.desc", comment: ""),
            category: NSLocalizedString("example.fullAdder.category", comment: ""),
            gates: [
                Gate(id: inputA, name: "INPUT", position: CGPoint(x: 50, y: 100), inputCount: 0, outputCount: 1, description: NSLocalizedString("gateInstance.inputA", comment: "")),
                Gate(id: inputB, name: "INPUT", position: CGPoint(x: 50, y: 200), inputCount: 0, outputCount: 1, description: NSLocalizedString("gateInstance.inputB", comment: "")),
                Gate(id: inputCin, name: "INPUT", position: CGPoint(x: 50, y: 300), inputCount: 0, outputCount: 1, description: NSLocalizedString("gateInstance.inputCin", comment: "")),
                Gate(id: xor1, name: "XOR", position: CGPoint(x: 200, y: 150), inputCount: 2, outputCount: 1),
                Gate(id: xor2, name: "XOR", position: CGPoint(x: 350, y: 200), inputCount: 2, outputCount: 1),
                Gate(id: and1, name: "AND", position: CGPoint(x: 200, y: 250), inputCount: 2, outputCount: 1),
                Gate(id: and2, name: "AND", position: CGPoint(x: 350, y: 300), inputCount: 2, outputCount: 1),
                Gate(id: orGate, name: "OR", position: CGPoint(x: 500, y: 275), inputCount: 2, outputCount: 1),
                Gate(id: outputSum, name: "OUTPUT", position: CGPoint(x: 600, y: 200), inputCount: 1, outputCount: 0, description: NSLocalizedString("gateInstance.outputSum", comment: "")),
                Gate(id: outputCout, name: "OUTPUT", position: CGPoint(x: 600, y: 275), inputCount: 1, outputCount: 0, description: NSLocalizedString("gateInstance.outputCout", comment: ""))
            ],
            wires: [
                Wire(fromGateID: inputA, fromPinIndex: 0, toGateID: xor1, toPinIndex: 0),
                Wire(fromGateID: inputB, fromPinIndex: 0, toGateID: xor1, toPinIndex: 1),
                Wire(fromGateID: xor1, fromPinIndex: 0, toGateID: xor2, toPinIndex: 0),
                Wire(fromGateID: inputCin, fromPinIndex: 0, toGateID: xor2, toPinIndex: 1),
                Wire(fromGateID: inputA, fromPinIndex: 0, toGateID: and1, toPinIndex: 0),
                Wire(fromGateID: inputB, fromPinIndex: 0, toGateID: and1, toPinIndex: 1),
                Wire(fromGateID: xor1, fromPinIndex: 0, toGateID: and2, toPinIndex: 0),
                Wire(fromGateID: inputCin, fromPinIndex: 0, toGateID: and2, toPinIndex: 1),
                Wire(fromGateID: and1, fromPinIndex: 0, toGateID: orGate, toPinIndex: 0),
                Wire(fromGateID: and2, fromPinIndex: 0, toGateID: orGate, toPinIndex: 1),
                Wire(fromGateID: xor2, fromPinIndex: 0, toGateID: outputSum, toPinIndex: 0),
                Wire(fromGateID: orGate, fromPinIndex: 0, toGateID: outputCout, toPinIndex: 0)
            ]
        )
    }
    
    // MARK: - SR Latch (Триггер)
    static var srLatch: ExampleScheme {
        let inputS = UUID()
        let inputR = UUID()
        let nor1 = UUID()
        let nor2 = UUID()
        let outputQ = UUID()
        let outputQNot = UUID()
        
        return ExampleScheme(
            name: NSLocalizedString("example.srLatch.name", comment: ""),
            description: NSLocalizedString("example.srLatch.desc", comment: ""),
            category: NSLocalizedString("example.srLatch.category", comment: ""),
            gates: [
                Gate(id: inputS, name: "INPUT", position: CGPoint(x: 100, y: 150), inputCount: 0, outputCount: 1, description: NSLocalizedString("gateInstance.inputS", comment: "")),
                Gate(id: inputR, name: "INPUT", position: CGPoint(x: 100, y: 250), inputCount: 0, outputCount: 1, description: NSLocalizedString("gateInstance.inputR", comment: "")),
                Gate(id: nor1, name: "NOR", position: CGPoint(x: 300, y: 150), inputCount: 2, outputCount: 1),
                Gate(id: nor2, name: "NOR", position: CGPoint(x: 300, y: 250), inputCount: 2, outputCount: 1),
                Gate(id: outputQ, name: "OUTPUT", position: CGPoint(x: 500, y: 150), inputCount: 1, outputCount: 0, description: NSLocalizedString("gateInstance.outputQ", comment: "")),
                Gate(id: outputQNot, name: "OUTPUT", position: CGPoint(x: 500, y: 250), inputCount: 1, outputCount: 0, description: NSLocalizedString("gateInstance.outputQNot", comment: ""))
            ],
            wires: [
                Wire(fromGateID: inputS, fromPinIndex: 0, toGateID: nor1, toPinIndex: 0),
                Wire(fromGateID: inputR, fromPinIndex: 0, toGateID: nor2, toPinIndex: 1),
                Wire(fromGateID: nor1, fromPinIndex: 0, toGateID: nor2, toPinIndex: 0),
                Wire(fromGateID: nor2, fromPinIndex: 0, toGateID: nor1, toPinIndex: 1),
                Wire(fromGateID: nor1, fromPinIndex: 0, toGateID: outputQ, toPinIndex: 0),
                Wire(fromGateID: nor2, fromPinIndex: 0, toGateID: outputQNot, toPinIndex: 0)
            ]
        )
    }
    
    // MARK: - D Flip-Flop (D-триггер)
    static var dFlipFlop: ExampleScheme {
        let inputD = UUID()
        let inputClk = UUID()
        let nand1 = UUID()
        let nand2 = UUID()
        let nand3 = UUID()
        let nand4 = UUID()
        let not1 = UUID()
        let outputQ = UUID()
        let outputQNot = UUID()
        
        return ExampleScheme(
            name: NSLocalizedString("example.dFlipFlop.name", comment: ""),
            description: NSLocalizedString("example.dFlipFlop.desc", comment: ""),
            category: NSLocalizedString("example.dFlipFlop.category", comment: ""),
            gates: [
                Gate(id: inputD, name: "INPUT", position: CGPoint(x: 80, y: 150), inputCount: 0, outputCount: 1, description: NSLocalizedString("gateInstance.inputD", comment: "")),
                Gate(id: inputClk, name: "INPUT", position: CGPoint(x: 80, y: 280), inputCount: 0, outputCount: 1, description: NSLocalizedString("gateInstance.inputClk", comment: "")),
                Gate(id: not1, name: "NOT", position: CGPoint(x: 200, y: 220), inputCount: 1, outputCount: 1),
                Gate(id: nand1, name: "NAND", position: CGPoint(x: 320, y: 150), inputCount: 2, outputCount: 1),
                Gate(id: nand2, name: "NAND", position: CGPoint(x: 320, y: 250), inputCount: 2, outputCount: 1),
                Gate(id: nand3, name: "NAND", position: CGPoint(x: 480, y: 180), inputCount: 2, outputCount: 1),
                Gate(id: nand4, name: "NAND", position: CGPoint(x: 480, y: 280), inputCount: 2, outputCount: 1),
                Gate(id: outputQ, name: "OUTPUT", position: CGPoint(x: 640, y: 180), inputCount: 1, outputCount: 0, description: NSLocalizedString("gateInstance.outputQ", comment: "")),
                Gate(id: outputQNot, name: "OUTPUT", position: CGPoint(x: 640, y: 280), inputCount: 1, outputCount: 0, description: NSLocalizedString("gateInstance.outputQNot", comment: ""))
            ],
            wires: [
                Wire(fromGateID: inputD, fromPinIndex: 0, toGateID: nand1, toPinIndex: 0),
                Wire(fromGateID: inputD, fromPinIndex: 0, toGateID: not1, toPinIndex: 0),
                Wire(fromGateID: not1, fromPinIndex: 0, toGateID: nand2, toPinIndex: 0),
                Wire(fromGateID: inputClk, fromPinIndex: 0, toGateID: nand1, toPinIndex: 1),
                Wire(fromGateID: inputClk, fromPinIndex: 0, toGateID: nand2, toPinIndex: 1),
                Wire(fromGateID: nand1, fromPinIndex: 0, toGateID: nand3, toPinIndex: 0),
                Wire(fromGateID: nand2, fromPinIndex: 0, toGateID: nand4, toPinIndex: 1),
                Wire(fromGateID: nand3, fromPinIndex: 0, toGateID: nand4, toPinIndex: 0),
                Wire(fromGateID: nand4, fromPinIndex: 0, toGateID: nand3, toPinIndex: 1),
                Wire(fromGateID: nand3, fromPinIndex: 0, toGateID: outputQ, toPinIndex: 0),
                Wire(fromGateID: nand4, fromPinIndex: 0, toGateID: outputQNot, toPinIndex: 0)
            ]
        )
    }
    
    // MARK: - Ring Oscillator (Кольцевой генератор)
    static var ringOscillator: ExampleScheme {
        let not1 = UUID()
        let not2 = UUID()
        let not3 = UUID()
        let output1 = UUID()
        
        return ExampleScheme(
            name: NSLocalizedString("example.ringOscillator.name", comment: ""),
            description: NSLocalizedString("example.ringOscillator.desc", comment: ""),
            category: NSLocalizedString("example.ringOscillator.category", comment: ""),
            gates: [
                Gate(id: not1, name: "NOT", position: CGPoint(x: 200, y: 200), inputCount: 1, outputCount: 1, description: "Инвертор 1"),
                Gate(id: not2, name: "NOT", position: CGPoint(x: 350, y: 250), inputCount: 1, outputCount: 1, description: "Инвертор 2"),
                Gate(id: not3, name: "NOT", position: CGPoint(x: 350, y: 150), inputCount: 1, outputCount: 1, description: "Инвертор 3"),
                Gate(id: output1, name: "OUTPUT", position: CGPoint(x: 500, y: 200), inputCount: 1, outputCount: 0, description: NSLocalizedString("gateInstance.outputOscillator", comment: ""))
            ],
            wires: [
                Wire(fromGateID: not1, fromPinIndex: 0, toGateID: not3, toPinIndex: 0),
                Wire(fromGateID: not3, fromPinIndex: 0, toGateID: not2, toPinIndex: 0),
                Wire(fromGateID: not2, fromPinIndex: 0, toGateID: not1, toPinIndex: 0),
                Wire(fromGateID: not1, fromPinIndex: 0, toGateID: output1, toPinIndex: 0)
            ]
        )
    }
    
    // MARK: - Pulse Oscillator (Импульсный генератор из базовых элементов)
    static var pulseOscillator: ExampleScheme {
        let button = UUID()
        let delay1 = UUID()  // NOT 1
        let delay2 = UUID()  // NOT 2
        let delay3 = UUID()  // NOT 3
        let and1 = UUID()    // AND для создания импульсов
        let led = UUID()     // LED для визуализации
        let ground = UUID()  // CONST0 для земли
        
        return ExampleScheme(
            name: NSLocalizedString("example.pulseOscillator.name", comment: "Pulse Oscillator"),
            description: NSLocalizedString("example.pulseOscillator.desc", comment: "Simple pulse generator built from NOT gates and AND"),
            category: NSLocalizedString("example.pulseOscillator.category", comment: "Generators"),
            gates: [
                Gate(id: button, name: "BUTTON", position: CGPoint(x: 100, y: 150), inputCount: 0, outputCount: 2, description: "Кнопка (управление)"),
                Gate(id: delay1, name: "NOT", position: CGPoint(x: 250, y: 120), inputCount: 1, outputCount: 1, description: "Задержка 1"),
                Gate(id: delay2, name: "NOT", position: CGPoint(x: 350, y: 120), inputCount: 1, outputCount: 1, description: "Задержка 2"),
                Gate(id: delay3, name: "NOT", position: CGPoint(x: 450, y: 120), inputCount: 1, outputCount: 1, description: "Задержка 3"),
                Gate(id: and1, name: "AND", position: CGPoint(x: 300, y: 200), inputCount: 2, outputCount: 1, description: "Импульсный генератор"),
                Gate(id: led, name: "LED", position: CGPoint(x: 500, y: 200), inputCount: 2, outputCount: 0, description: "Индикатор импульсов"),
                Gate(id: ground, name: "CONST0", position: CGPoint(x: 600, y: 250), inputCount: 0, outputCount: 1, description: "Земля (-)")
            ],
            wires: [
                Wire(fromGateID: button, fromPinIndex: 0, toGateID: delay1, toPinIndex: 0),      // Кнопка -> Задержка1
                Wire(fromGateID: delay1, fromPinIndex: 0, toGateID: delay2, toPinIndex: 0),      // Задержка1 -> Задержка2
                Wire(fromGateID: delay2, fromPinIndex: 0, toGateID: delay3, toPinIndex: 0),      // Задержка2 -> Задержка3
                Wire(fromGateID: button, fromPinIndex: 0, toGateID: and1, toPinIndex: 0),        // Кнопка (исходный сигнал) -> AND вход 1
                Wire(fromGateID: delay3, fromPinIndex: 0, toGateID: and1, toPinIndex: 1),        // Задержка3 -> AND вход 2
                Wire(fromGateID: and1, fromPinIndex: 0, toGateID: led, toPinIndex: 0),           // AND выход -> LED (+)
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: led, toPinIndex: 1)          // Земля -> LED (-)
            ]
        )
    }
    
    // MARK: - SR Latch with LED (SR-триггер со светодиодом)
    static var srLatchWithLED: ExampleScheme {
        let buttonS = UUID()
        let buttonR = UUID()
        let ground = UUID()
        let nor1 = UUID()
        let nor2 = UUID()
        let ledQ = UUID()
        let ledQNot = UUID()
        
        return ExampleScheme(
            name: NSLocalizedString("example.srLatchLED.name", comment: ""),
            description: NSLocalizedString("example.srLatchLED.desc", comment: ""),
            category: NSLocalizedString("example.srLatchLED.category", comment: ""),
            gates: [
                Gate(id: ground, name: "CONST0", position: CGPoint(x: 50, y: 200), inputCount: 0, outputCount: 1, description: "Земля (-)"),
                Gate(id: buttonS, name: "BUTTON", position: CGPoint(x: 150, y: 150), inputCount: 0, outputCount: 2, description: NSLocalizedString("gateInstance.inputS", comment: "")),
                Gate(id: buttonR, name: "BUTTON", position: CGPoint(x: 150, y: 250), inputCount: 0, outputCount: 2, description: NSLocalizedString("gateInstance.inputR", comment: "")),
                Gate(id: nor1, name: "NOR", position: CGPoint(x: 320, y: 150), inputCount: 2, outputCount: 1),
                Gate(id: nor2, name: "NOR", position: CGPoint(x: 320, y: 250), inputCount: 2, outputCount: 1),
                Gate(id: ledQ, name: "LED", position: CGPoint(x: 520, y: 150), inputCount: 2, outputCount: 0, description: NSLocalizedString("gateInstance.outputQ", comment: "")),
                Gate(id: ledQNot, name: "LED", position: CGPoint(x: 520, y: 250), inputCount: 2, outputCount: 0, description: NSLocalizedString("gateInstance.outputQNot", comment: ""))
            ],
            wires: [
                // Кнопки к NOR элементам
                Wire(fromGateID: buttonS, fromPinIndex: 0, toGateID: nor1, toPinIndex: 0),
                Wire(fromGateID: buttonR, fromPinIndex: 0, toGateID: nor2, toPinIndex: 1),
                // Обратная связь
                Wire(fromGateID: nor1, fromPinIndex: 0, toGateID: nor2, toPinIndex: 0),
                Wire(fromGateID: nor2, fromPinIndex: 0, toGateID: nor1, toPinIndex: 1),
                // К светодиодам
                Wire(fromGateID: nor1, fromPinIndex: 0, toGateID: ledQ, toPinIndex: 0),     // NOR Q к LED +
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: ledQ, toPinIndex: 1),   // Земля к LED -
                Wire(fromGateID: nor2, fromPinIndex: 0, toGateID: ledQNot, toPinIndex: 0),  // NOR Q' к LED +
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: ledQNot, toPinIndex: 1) // Земля к LED -
            ]
        )
    }
    
    // MARK: - Relay Latch (Защёлка на реле)
    static var relayLatch: ExampleScheme {
        let power = UUID()
        let buttonSet = UUID()
        let orGate = UUID()
        let relay1 = UUID()
        let bulb1 = UUID()
        
        return ExampleScheme(
            name: NSLocalizedString("example.relayLatch.name", comment: ""),
            description: NSLocalizedString("example.relayLatch.desc", comment: ""),
            category: NSLocalizedString("example.relayLatch.category", comment: ""),
            gates: [
                Gate(id: power, name: "INPUT", position: CGPoint(x: 80, y: 100), inputCount: 0, outputCount: 1, description: "Источник питания"),
                Gate(id: buttonSet, name: "BUTTON", position: CGPoint(x: 180, y: 180), inputCount: 0, outputCount: 2, description: "Кнопка включения"),
                Gate(id: orGate, name: "OR", position: CGPoint(x: 320, y: 200), inputCount: 2, outputCount: 1),
                Gate(id: relay1, name: "RELAY", position: CGPoint(x: 470, y: 225), inputCount: 2, outputCount: 3, description: "Удерживающее реле"),
                Gate(id: bulb1, name: "BULB", position: CGPoint(x: 650, y: 150), inputCount: 2, outputCount: 0, description: "Лампа")
            ],
            wires: [
                // Питание
                Wire(fromGateID: power, fromPinIndex: 0, toGateID: buttonSet, toPinIndex: 0),  // К кнопке (это будет через логику)
                // Кнопка Set и обратная связь через OR
                Wire(fromGateID: buttonSet, fromPinIndex: 0, toGateID: orGate, toPinIndex: 0),
                Wire(fromGateID: relay1, fromPinIndex: 1, toGateID: orGate, toPinIndex: 1),  // NO обратная связь
                // OR выход к катушке реле (+)
                Wire(fromGateID: orGate, fromPinIndex: 0, toGateID: relay1, toPinIndex: 0),
                // Земля к катушке реле (-) - используем второй пин кнопки
                Wire(fromGateID: buttonSet, fromPinIndex: 1, toGateID: relay1, toPinIndex: 1),
                // NO контакт к лампе (+)
                Wire(fromGateID: relay1, fromPinIndex: 1, toGateID: bulb1, toPinIndex: 0)
            ]
        )
    }
    
    // MARK: - AND from NAND
    static var andGateFromNand: ExampleScheme {
        let inputA = UUID()
        let inputB = UUID()
        let nandGate = UUID()
        let notGate = UUID()
        let outputGate = UUID()
        
        return ExampleScheme(
            name: NSLocalizedString("example.andFromNand.name", comment: ""),
            description: NSLocalizedString("example.andFromNand.desc", comment: ""),
            category: NSLocalizedString("example.andFromNand.category", comment: ""),
            gates: [
                Gate(id: inputA, name: "INPUT", position: CGPoint(x: 100, y: 150), inputCount: 0, outputCount: 1, description: NSLocalizedString("gateInstance.inputA", comment: "")),
                Gate(id: inputB, name: "INPUT", position: CGPoint(x: 100, y: 250), inputCount: 0, outputCount: 1, description: NSLocalizedString("gateInstance.inputB", comment: "")),
                Gate(id: nandGate, name: "NAND", position: CGPoint(x: 300, y: 200), inputCount: 2, outputCount: 1),
                Gate(id: notGate, name: "NOT", position: CGPoint(x: 450, y: 200), inputCount: 1, outputCount: 1),
                Gate(id: outputGate, name: "OUTPUT", position: CGPoint(x: 600, y: 200), inputCount: 1, outputCount: 0, description: NSLocalizedString("gateInstance.outputOutput", comment: ""))
            ],
            wires: [
                Wire(fromGateID: inputA, fromPinIndex: 0, toGateID: nandGate, toPinIndex: 0),
                Wire(fromGateID: inputB, fromPinIndex: 0, toGateID: nandGate, toPinIndex: 1),
                Wire(fromGateID: nandGate, fromPinIndex: 0, toGateID: notGate, toPinIndex: 0),
                Wire(fromGateID: notGate, fromPinIndex: 0, toGateID: outputGate, toPinIndex: 0)
            ]
        )
    }
    
    // MARK: - XOR from basic gates
    static var xorFromBasic: ExampleScheme {
        let inputA = UUID()
        let inputB = UUID()
        let notA = UUID()
        let notB = UUID()
        let and1 = UUID()
        let and2 = UUID()
        let orGate = UUID()
        let outputXor = UUID()
        
        return ExampleScheme(
            name: NSLocalizedString("example.xorFromBasic.name", comment: ""),
            description: NSLocalizedString("example.xorFromBasic.desc", comment: ""),
            category: NSLocalizedString("example.xorFromBasic.category", comment: ""),
            gates: [
                Gate(id: inputA, name: "INPUT", position: CGPoint(x: 50, y: 150), inputCount: 0, outputCount: 1, description: NSLocalizedString("gateInstance.inputA", comment: "")),
                Gate(id: inputB, name: "INPUT", position: CGPoint(x: 50, y: 250), inputCount: 0, outputCount: 1, description: NSLocalizedString("gateInstance.inputB", comment: "")),
                Gate(id: notA, name: "NOT", position: CGPoint(x: 200, y: 120), inputCount: 1, outputCount: 1),
                Gate(id: notB, name: "NOT", position: CGPoint(x: 200, y: 280), inputCount: 1, outputCount: 1),
                Gate(id: and1, name: "AND", position: CGPoint(x: 350, y: 150), inputCount: 2, outputCount: 1),
                Gate(id: and2, name: "AND", position: CGPoint(x: 350, y: 250), inputCount: 2, outputCount: 1),
                Gate(id: orGate, name: "OR", position: CGPoint(x: 500, y: 200), inputCount: 2, outputCount: 1),
                Gate(id: outputXor, name: "OUTPUT", position: CGPoint(x: 650, y: 200), inputCount: 1, outputCount: 0, description: NSLocalizedString("gateInstance.outputXor", comment: ""))
            ],
            wires: [
                Wire(fromGateID: inputA, fromPinIndex: 0, toGateID: notA, toPinIndex: 0),
                Wire(fromGateID: inputB, fromPinIndex: 0, toGateID: notB, toPinIndex: 0),
                Wire(fromGateID: inputA, fromPinIndex: 0, toGateID: and2, toPinIndex: 0),
                Wire(fromGateID: notB, fromPinIndex: 0, toGateID: and1, toPinIndex: 1),
                Wire(fromGateID: notA, fromPinIndex: 0, toGateID: and2, toPinIndex: 1),
                Wire(fromGateID: inputB, fromPinIndex: 0, toGateID: and1, toPinIndex: 0),
                Wire(fromGateID: and1, fromPinIndex: 0, toGateID: orGate, toPinIndex: 0),
                Wire(fromGateID: and2, fromPinIndex: 0, toGateID: orGate, toPinIndex: 1),
                Wire(fromGateID: orGate, fromPinIndex: 0, toGateID: outputXor, toPinIndex: 0)
            ]
        )
    }
    
    // MARK: - 2:1 Multiplexer
    static var multiplexer2to1: ExampleScheme {
        let inputD0 = UUID()
        let inputD1 = UUID()
        let inputSelect = UUID()
        let notGate = UUID()
        let and1 = UUID()
        let and2 = UUID()
        let orGate = UUID()
        let outputGate = UUID()
        
        return ExampleScheme(
            name: NSLocalizedString("example.multiplexer.name", comment: ""),
            description: NSLocalizedString("example.multiplexer.desc", comment: ""),
            category: NSLocalizedString("example.multiplexer.category", comment: ""),
            gates: [
                Gate(id: inputD0, name: "INPUT", position: CGPoint(x: 50, y: 100), inputCount: 0, outputCount: 1, description: NSLocalizedString("gateInstance.inputD0", comment: "")),
                Gate(id: inputD1, name: "INPUT", position: CGPoint(x: 50, y: 200), inputCount: 0, outputCount: 1, description: NSLocalizedString("gateInstance.inputD1", comment: "")),
                Gate(id: inputSelect, name: "INPUT", position: CGPoint(x: 50, y: 300), inputCount: 0, outputCount: 1, description: NSLocalizedString("gateInstance.inputSelect", comment: "")),
                Gate(id: notGate, name: "NOT", position: CGPoint(x: 200, y: 300), inputCount: 1, outputCount: 1),
                Gate(id: and1, name: "AND", position: CGPoint(x: 350, y: 150), inputCount: 2, outputCount: 1),
                Gate(id: and2, name: "AND", position: CGPoint(x: 350, y: 250), inputCount: 2, outputCount: 1),
                Gate(id: orGate, name: "OR", position: CGPoint(x: 500, y: 200), inputCount: 2, outputCount: 1),
                Gate(id: outputGate, name: "OUTPUT", position: CGPoint(x: 650, y: 200), inputCount: 1, outputCount: 0, description: NSLocalizedString("gateInstance.outputOut", comment: ""))
            ],
            wires: [
                Wire(fromGateID: inputSelect, fromPinIndex: 0, toGateID: notGate, toPinIndex: 0),
                Wire(fromGateID: inputD0, fromPinIndex: 0, toGateID: and1, toPinIndex: 0),
                Wire(fromGateID: notGate, fromPinIndex: 0, toGateID: and1, toPinIndex: 1),
                Wire(fromGateID: inputD1, fromPinIndex: 0, toGateID: and2, toPinIndex: 0),
                Wire(fromGateID: inputSelect, fromPinIndex: 0, toGateID: and2, toPinIndex: 1),
                Wire(fromGateID: and1, fromPinIndex: 0, toGateID: orGate, toPinIndex: 0),
                Wire(fromGateID: and2, fromPinIndex: 0, toGateID: orGate, toPinIndex: 1),
                Wire(fromGateID: orGate, fromPinIndex: 0, toGateID: outputGate, toPinIndex: 0)
            ]
        )
    }
    
    // MARK: - Simple LED Circuit (Простая схема с LED)
    static var simpleLEDCircuit: ExampleScheme {
        let switch1 = UUID()
        let led1 = UUID()
        
        return ExampleScheme(
            name: NSLocalizedString("example.simpleLED.name", comment: "Simple LED Circuit"),
            description: NSLocalizedString("example.simpleLED.desc", comment: "Basic circuit with a switch and LED. Turn the switch on to light up the LED."),
            category: NSLocalizedString("example.simpleLED.category", comment: "Physical Components"),
            gates: [
                Gate(id: switch1, name: "SWITCH", position: CGPoint(x: 150, y: 200), inputCount: 0, outputCount: 1, description: "Power switch"),
                Gate(id: led1, name: "LED", position: CGPoint(x: 350, y: 200), inputCount: 1, outputCount: 0, description: "LED indicator")
            ],
            wires: [
                Wire(fromGateID: switch1, fromPinIndex: 0, toGateID: led1, toPinIndex: 0)
            ]
        )
    }
    
    // MARK: - Push Button LED (Кнопка с LED)
    static var pushButtonLED: ExampleScheme {
        let button1 = UUID()
        let button2 = UUID()
        let andGate = UUID()
        let ground = UUID()
        let led1 = UUID()
        
        return ExampleScheme(
            name: NSLocalizedString("example.buttonLED.name", comment: "Push Button LED"),
            description: NSLocalizedString("example.buttonLED.desc", comment: "Press both buttons simultaneously to light the LED. Demonstrates AND logic with physical components."),
            category: NSLocalizedString("example.buttonLED.category", comment: "Physical Components"),
            gates: [
                Gate(id: button1, name: "BUTTON", position: CGPoint(x: 100, y: 150), inputCount: 0, outputCount: 1, description: "Button A"),
                Gate(id: button2, name: "BUTTON", position: CGPoint(x: 100, y: 250), inputCount: 0, outputCount: 1, description: "Button B"),
                Gate(id: andGate, name: "AND", position: CGPoint(x: 300, y: 200), inputCount: 2, outputCount: 1, description: "AND gate"),
                Gate(id: ground, name: "CONST0", position: CGPoint(x: 400, y: 250), inputCount: 0, outputCount: 1, description: "Земля (-)"),
                Gate(id: led1, name: "LED", position: CGPoint(x: 500, y: 200), inputCount: 2, outputCount: 0, description: "Green LED")
            ],
            wires: [
                Wire(fromGateID: button1, fromPinIndex: 0, toGateID: andGate, toPinIndex: 0),
                Wire(fromGateID: button2, fromPinIndex: 0, toGateID: andGate, toPinIndex: 1),
                Wire(fromGateID: andGate, fromPinIndex: 0, toGateID: led1, toPinIndex: 0),   // AND выход к LED +
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: led1, toPinIndex: 1)     // Земля к LED -
            ]
        )
    }
    
        // MARK: - Relay Circuit (Схема с реле - нормально открытый контакт)
    static var relayCircuit: ExampleScheme {
        let switch1 = UUID()
        let ground = UUID()
        let relay1 = UUID()
        let bulb1 = UUID()
        
        return ExampleScheme(
            name: NSLocalizedString("example.relay.name", comment: "Relay Circuit"),
            description: NSLocalizedString("example.relay.desc", comment: "Control a light bulb using relay NO contact. When switch is ON, coil activates and NO contact closes, lighting the bulb."),
            category: NSLocalizedString("example.relay.category", comment: "Physical Components"),
            gates: [
                Gate(id: switch1, name: "SWITCH", position: CGPoint(x: 100, y: 200), inputCount: 0, outputCount: 2, description: "Control switch"),
                Gate(id: ground, name: "CONST0", position: CGPoint(x: 220, y: 260), inputCount: 0, outputCount: 1, description: "Земля (-)"),
                Gate(id: relay1, name: "RELAY", position: CGPoint(x: 320, y: 200), inputCount: 2, outputCount: 3, description: "Electromagnetic relay"),
                Gate(id: bulb1, name: "BULB", position: CGPoint(x: 520, y: 200), inputCount: 2, outputCount: 0, description: "Light bulb")
            ],
            wires: [
                // Подключаем катушку реле
                Wire(fromGateID: switch1, fromPinIndex: 0, toGateID: relay1, toPinIndex: 0),  // + катушки
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: relay1, toPinIndex: 1),   // - катушки (земля)
                // Используем NO контакт для управления лампой
                Wire(fromGateID: relay1, fromPinIndex: 1, toGateID: bulb1, toPinIndex: 0),    // NO -> Bulb+
                Wire(fromGateID: switch1, fromPinIndex: 1, toGateID: bulb1, toPinIndex: 1)    // Switch- -> Bulb-
            ]
        )
    }
    
    // MARK: - Relay Switch (Схема с переключающим реле)
    static var relaySwitch: ExampleScheme {
        let button1 = UUID()
        let ground = UUID()
        let relay1 = UUID()
        let ledGreen = UUID()
        let ledRed = UUID()
        
        return ExampleScheme(
            name: NSLocalizedString("example.relaySwitch.name", comment: "Relay Switch"),
            description: NSLocalizedString("example.relaySwitch.desc", comment: "Relay as a switch between two LEDs. When button is released, NC contact lights red LED. When pressed, NO contact lights green LED."),
            category: NSLocalizedString("example.relaySwitch.category", comment: "Physical Components"),
            gates: [
                Gate(id: button1, name: "BUTTON", position: CGPoint(x: 100, y: 250), inputCount: 0, outputCount: 2, description: "Control button"),
                Gate(id: ground, name: "CONST0", position: CGPoint(x: 220, y: 310), inputCount: 0, outputCount: 1, description: "Земля (-)"),
                Gate(id: relay1, name: "RELAY", position: CGPoint(x: 320, y: 250), inputCount: 2, outputCount: 3, description: "Switching relay"),
                Gate(id: ledGreen, name: "LED", position: CGPoint(x: 520, y: 180), inputCount: 2, outputCount: 0, description: "Green LED (NO)"),
                Gate(id: ledRed, name: "LED", position: CGPoint(x: 520, y: 320), inputCount: 2, outputCount: 0, description: "Red LED (NC)")
            ],
            wires: [
                // Подключаем катушку реле к кнопке
                Wire(fromGateID: button1, fromPinIndex: 0, toGateID: relay1, toPinIndex: 0),  // + катушки
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: relay1, toPinIndex: 1),   // - катушки
                // NO контакт -> зелёный LED (включается при нажатии)
                Wire(fromGateID: relay1, fromPinIndex: 1, toGateID: ledGreen, toPinIndex: 0), // NO -> Green+
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: ledGreen, toPinIndex: 1), // - Green
                // NC контакт -> красный LED (включен по умолчанию)
                Wire(fromGateID: relay1, fromPinIndex: 2, toGateID: ledRed, toPinIndex: 0),   // NC -> Red+
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: ledRed, toPinIndex: 1)    // - Red
            ]
        )
    }
    
    // MARK: - Buzzer Alarm (Сигнализация с динамиком)
    static var buzzerAlarm: ExampleScheme {
        let button1 = UUID()
        let button2 = UUID()
        let orGate = UUID()
        let ground = UUID()
        let buzzer1 = UUID()
        let led1 = UUID()
        
        return ExampleScheme(
            name: NSLocalizedString("example.buzzer.name", comment: "Buzzer Alarm"),
            description: NSLocalizedString("example.buzzer.desc", comment: "Simple alarm system. Press any button to activate the buzzer and LED. Uses OR gate logic."),
            category: NSLocalizedString("example.buzzer.category", comment: "Physical Components"),
            gates: [
                Gate(id: button1, name: "BUTTON", position: CGPoint(x: 100, y: 150), inputCount: 0, outputCount: 1, description: "Alarm button 1"),
                Gate(id: button2, name: "BUTTON", position: CGPoint(x: 100, y: 250), inputCount: 0, outputCount: 1, description: "Alarm button 2"),
                Gate(id: orGate, name: "OR", position: CGPoint(x: 300, y: 200), inputCount: 2, outputCount: 1, description: "OR gate"),
                Gate(id: ground, name: "CONST0", position: CGPoint(x: 400, y: 300), inputCount: 0, outputCount: 1, description: "Земля (-)"),
                Gate(id: buzzer1, name: "BUZZER", position: CGPoint(x: 500, y: 150), inputCount: 2, outputCount: 0, description: "Alarm buzzer"),
                Gate(id: led1, name: "LED", position: CGPoint(x: 500, y: 250), inputCount: 2, outputCount: 0, description: "Alarm LED")
            ],
            wires: [
                Wire(fromGateID: button1, fromPinIndex: 0, toGateID: orGate, toPinIndex: 0),
                Wire(fromGateID: button2, fromPinIndex: 0, toGateID: orGate, toPinIndex: 1),
                Wire(fromGateID: orGate, fromPinIndex: 0, toGateID: buzzer1, toPinIndex: 0),   // OR -> BUZZER +
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: buzzer1, toPinIndex: 1),  // Ground -> BUZZER -
                Wire(fromGateID: orGate, fromPinIndex: 0, toGateID: led1, toPinIndex: 0),      // OR -> LED +
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: led1, toPinIndex: 1)       // Ground -> LED -
            ]
        )
    }
    
    // MARK: - Traffic Light (Светофор)
    static var trafficLight: ExampleScheme {
        let button1 = UUID()
        let button2 = UUID()
        let not1 = UUID()
        let and1 = UUID()
        let and2 = UUID()
        let ground = UUID()
        let ledRed = UUID()
        let ledYellow = UUID()
        let ledGreen = UUID()
        
        return ExampleScheme(
            name: NSLocalizedString("example.traffic.name", comment: "Traffic Light Controller"),
            description: NSLocalizedString("example.traffic.desc", comment: "Simple traffic light logic. Different button combinations produce different light signals: Red (both off), Yellow (one on), Green (both on)."),
            category: NSLocalizedString("example.traffic.category", comment: "Physical Components"),
            gates: [
                Gate(id: button1, name: "BUTTON", position: CGPoint(x: 80, y: 150), inputCount: 0, outputCount: 1, description: "Control A"),
                Gate(id: button2, name: "BUTTON", position: CGPoint(x: 80, y: 300), inputCount: 0, outputCount: 1, description: "Control B"),
                Gate(id: not1, name: "NOT", position: CGPoint(x: 220, y: 100), inputCount: 1, outputCount: 1, description: "Inverter"),
                Gate(id: and1, name: "AND", position: CGPoint(x: 350, y: 225), inputCount: 2, outputCount: 1, description: "Yellow logic"),
                Gate(id: and2, name: "AND", position: CGPoint(x: 350, y: 350), inputCount: 2, outputCount: 1, description: "Green logic"),
                Gate(id: ground, name: "CONST0", position: CGPoint(x: 450, y: 450), inputCount: 0, outputCount: 1, description: "Земля (-)"),
                Gate(id: ledRed, name: "LED", position: CGPoint(x: 550, y: 100), inputCount: 2, outputCount: 0, description: "Red light"),
                Gate(id: ledYellow, name: "LED", position: CGPoint(x: 550, y: 225), inputCount: 2, outputCount: 0, description: "Yellow light"),
                Gate(id: ledGreen, name: "LED", position: CGPoint(x: 550, y: 350), inputCount: 2, outputCount: 0, description: "Green light")
            ],
            wires: [
                Wire(fromGateID: button1, fromPinIndex: 0, toGateID: not1, toPinIndex: 0),
                Wire(fromGateID: not1, fromPinIndex: 0, toGateID: ledRed, toPinIndex: 0),
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: ledRed, toPinIndex: 1),
                Wire(fromGateID: button1, fromPinIndex: 0, toGateID: and1, toPinIndex: 0),
                Wire(fromGateID: button2, fromPinIndex: 0, toGateID: and1, toPinIndex: 1),
                Wire(fromGateID: button1, fromPinIndex: 0, toGateID: and2, toPinIndex: 0),
                Wire(fromGateID: button2, fromPinIndex: 0, toGateID: and2, toPinIndex: 1),
                Wire(fromGateID: and1, fromPinIndex: 0, toGateID: ledYellow, toPinIndex: 0),
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: ledYellow, toPinIndex: 1),
                Wire(fromGateID: and2, fromPinIndex: 0, toGateID: ledGreen, toPinIndex: 0),
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: ledGreen, toPinIndex: 1)
            ]
        )
    }
    
    // MARK: - Binary Calculator with 8-Bit Display (Двоичный калькулятор с дисплеем)
    static var binaryCalculatorWithDisplay: ExampleScheme {
        let b0 = UUID()
        let b1 = UUID()
        let b2 = UUID()
        let b3 = UUID()
        let b4 = UUID()
        let b5 = UUID()
        let b6 = UUID()
        let b7 = UUID()
        let battery = UUID()
        let display = UUID()
        
        return ExampleScheme(
            name: NSLocalizedString("example.binaryCalculator.name", comment: ""),
            description: NSLocalizedString("example.binaryCalculator.desc", comment: ""),
            category: NSLocalizedString("example.binaryCalculator.category", comment: ""),
            gates: [
                Gate(id: b0, name: "BUTTON", position: CGPoint(x: 50, y: 150), inputCount: 0, outputCount: 2, description: "B0 (LSB) - Вес 1"),
                Gate(id: b1, name: "BUTTON", position: CGPoint(x: 50, y: 220), inputCount: 0, outputCount: 2, description: "B1 - Вес 2"),
                Gate(id: b2, name: "BUTTON", position: CGPoint(x: 50, y: 290), inputCount: 0, outputCount: 2, description: "B2 - Вес 4"),
                Gate(id: b3, name: "BUTTON", position: CGPoint(x: 50, y: 360), inputCount: 0, outputCount: 2, description: "B3 - Вес 8"),
                Gate(id: b4, name: "BUTTON", position: CGPoint(x: 50, y: 430), inputCount: 0, outputCount: 2, description: "B4 - Вес 16"),
                Gate(id: b5, name: "BUTTON", position: CGPoint(x: 50, y: 500), inputCount: 0, outputCount: 2, description: "B5 - Вес 32"),
                Gate(id: b6, name: "BUTTON", position: CGPoint(x: 50, y: 570), inputCount: 0, outputCount: 2, description: "B6 - Вес 64"),
                Gate(id: b7, name: "BUTTON", position: CGPoint(x: 50, y: 640), inputCount: 0, outputCount: 2, description: "B7 (MSB) - Вес 128"),
                Gate(id: battery, name: "BATTERY", position: CGPoint(x: 300, y: 500), inputCount: 0, outputCount: 2, description: "Источник питания +5V"),
                Gate(id: display, name: "DISPLAY8BIT", position: CGPoint(x: 400, y: 350), inputCount: 10, outputCount: 0, description: "8-битный дисплей (0-255)")
            ],
            wires: [
                // Подключаем биты к дисплею
                // Расположение пинов на дисплее слева сверху вниз: пин0=B7, пин1=B6, ..., пин7=B0
                Wire(fromGateID: b7, fromPinIndex: 0, toGateID: display, toPinIndex: 0),  // B7 -> пин 0
                Wire(fromGateID: b6, fromPinIndex: 0, toGateID: display, toPinIndex: 1),  // B6 -> пин 1
                Wire(fromGateID: b5, fromPinIndex: 0, toGateID: display, toPinIndex: 2),  // B5 -> пин 2
                Wire(fromGateID: b4, fromPinIndex: 0, toGateID: display, toPinIndex: 3),  // B4 -> пин 3
                Wire(fromGateID: b3, fromPinIndex: 0, toGateID: display, toPinIndex: 4),  // B3 -> пин 4
                Wire(fromGateID: b2, fromPinIndex: 0, toGateID: display, toPinIndex: 5),  // B2 -> пин 5
                Wire(fromGateID: b1, fromPinIndex: 0, toGateID: display, toPinIndex: 6),  // B1 -> пин 6
                Wire(fromGateID: b0, fromPinIndex: 0, toGateID: display, toPinIndex: 7),  // B0 -> пин 7 (LSB)
                // Подключаем батарею к питанию дисплея (внизу)
                Wire(fromGateID: battery, fromPinIndex: 0, toGateID: display, toPinIndex: 8),  // Батарея + -> Display +
                Wire(fromGateID: battery, fromPinIndex: 1, toGateID: display, toPinIndex: 9)   // Батарея - -> Display -
            ]
        )
    }
    
    // MARK: - D Flip-Flop Counter (Счетчик на D-триггерах)
    static var dFlipFlopCounter: ExampleScheme {
        let clock = UUID()
        let dff1 = UUID()
        let dff2 = UUID()
        let not1 = UUID()
        let not2 = UUID()
        let led1 = UUID()
        let led2 = UUID()
        let ground = UUID()
        
        return ExampleScheme(
            name: NSLocalizedString("example.dFlipFlopCounter.name", comment: "D Flip-Flop Counter"),
            description: NSLocalizedString("example.dFlipFlopCounter.desc", comment: "2-bit counter using D flip-flops. Each flip-flop stores one bit and toggles on clock edge."),
            category: NSLocalizedString("example.dFlipFlopCounter.category", comment: "Flip-Flops & Latches"),
            gates: [
                Gate(id: clock, name: "CLOCK", position: CGPoint(x: 50, y: 200), inputCount: 0, outputCount: 1, description: "Генератор тактов"),
                Gate(id: dff1, name: "D_FLIPFLOP", position: CGPoint(x: 200, y: 150), inputCount: 2, outputCount: 2, description: "D-триггер 1 (младший бит)"),
                Gate(id: not1, name: "NOT", position: CGPoint(x: 350, y: 120), inputCount: 1, outputCount: 1, description: "Инвертор 1"),
                Gate(id: dff2, name: "D_FLIPFLOP", position: CGPoint(x: 200, y: 300), inputCount: 2, outputCount: 2, description: "D-триггер 2 (старший бит)"),
                Gate(id: not2, name: "NOT", position: CGPoint(x: 350, y: 270), inputCount: 1, outputCount: 1, description: "Инвертор 2"),
                Gate(id: led1, name: "LED", position: CGPoint(x: 500, y: 150), inputCount: 2, outputCount: 0, description: "Индикатор бита 0"),
                Gate(id: led2, name: "LED", position: CGPoint(x: 500, y: 300), inputCount: 2, outputCount: 0, description: "Индикатор бита 1"),
                Gate(id: ground, name: "CONST0", position: CGPoint(x: 600, y: 250), inputCount: 0, outputCount: 1, description: "Земля (-)")
            ],
            wires: [
                // Тактовый сигнал к обоим триггерам
                Wire(fromGateID: clock, fromPinIndex: 0, toGateID: dff1, toPinIndex: 1),  // CLK -> DFF1 CLK
                Wire(fromGateID: dff1, fromPinIndex: 0, toGateID: dff2, toPinIndex: 1),   // DFF1 Q -> DFF2 CLK (делитель на 2)
                // Обратная связь для переключения
                Wire(fromGateID: dff1, fromPinIndex: 1, toGateID: not1, toPinIndex: 0),   // DFF1 Q̄ -> NOT1
                Wire(fromGateID: not1, fromPinIndex: 0, toGateID: dff1, toPinIndex: 0),   // NOT1 -> DFF1 D
                Wire(fromGateID: dff2, fromPinIndex: 1, toGateID: not2, toPinIndex: 0),   // DFF2 Q̄ -> NOT2
                Wire(fromGateID: not2, fromPinIndex: 0, toGateID: dff2, toPinIndex: 0),   // NOT2 -> DFF2 D
                // Светодиоды
                Wire(fromGateID: dff1, fromPinIndex: 0, toGateID: led1, toPinIndex: 0),   // DFF1 Q -> LED1 +
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: led1, toPinIndex: 1), // GND -> LED1 -
                Wire(fromGateID: dff2, fromPinIndex: 0, toGateID: led2, toPinIndex: 0),   // DFF2 Q -> LED2 +
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: led2, toPinIndex: 1)  // GND -> LED2 -
            ]
        )
    }
    
    // MARK: - T Flip-Flop Toggle (Переключатель на T-триггере)
    static var tFlipFlopToggle: ExampleScheme {
        let button = UUID()
        let const1 = UUID()
        let tff = UUID()
        let led = UUID()
        let ground = UUID()
        
        return ExampleScheme(
            name: NSLocalizedString("example.tFlipFlopToggle.name", comment: "T Flip-Flop Toggle"),
            description: NSLocalizedString("example.tFlipFlopToggle.desc", comment: "Toggle flip-flop: each button press toggles the output state. T input is always high."),
            category: NSLocalizedString("example.tFlipFlopToggle.category", comment: "Flip-Flops & Latches"),
            gates: [
                Gate(id: button, name: "BUTTON", position: CGPoint(x: 100, y: 200), inputCount: 0, outputCount: 1, description: "Кнопка (такт)"),
                Gate(id: const1, name: "CONST1", position: CGPoint(x: 100, y: 120), inputCount: 0, outputCount: 1, description: "Всегда 1"),
                Gate(id: tff, name: "T_FLIPFLOP", position: CGPoint(x: 300, y: 160), inputCount: 2, outputCount: 2, description: "T-триггер"),
                Gate(id: led, name: "LED", position: CGPoint(x: 500, y: 150), inputCount: 2, outputCount: 0, description: "Индикатор состояния"),
                Gate(id: ground, name: "CONST0", position: CGPoint(x: 600, y: 200), inputCount: 0, outputCount: 1, description: "Земля (-)")
            ],
            wires: [
                Wire(fromGateID: const1, fromPinIndex: 0, toGateID: tff, toPinIndex: 0),   // 1 -> T (всегда переключать)
                Wire(fromGateID: button, fromPinIndex: 0, toGateID: tff, toPinIndex: 1),   // Button -> CLK
                Wire(fromGateID: tff, fromPinIndex: 0, toGateID: led, toPinIndex: 0),      // TFF Q -> LED +
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: led, toPinIndex: 1)    // GND -> LED -
            ]
        )
    }
    
    // MARK: - JK Flip-Flop Example (Пример JK-триггера)
    static var jkFlipFlopExample: ExampleScheme {
        let buttonJ = UUID()
        let buttonK = UUID()
        let buttonClk = UUID()
        let jkff = UUID()
        let ledQ = UUID()
        let ledQNot = UUID()
        let ground = UUID()
        
        return ExampleScheme(
            name: NSLocalizedString("example.jkFlipFlop.name", comment: "JK Flip-Flop"),
            description: NSLocalizedString("example.jkFlipFlop.desc", comment: "JK flip-flop demonstration: J=1,K=0 sets; J=0,K=1 resets; J=1,K=1 toggles on clock edge."),
            category: NSLocalizedString("example.jkFlipFlop.category", comment: "Flip-Flops & Latches"),
            gates: [
                Gate(id: buttonJ, name: "BUTTON", position: CGPoint(x: 80, y: 120), inputCount: 0, outputCount: 1, description: "Вход J"),
                Gate(id: buttonK, name: "BUTTON", position: CGPoint(x: 80, y: 240), inputCount: 0, outputCount: 1, description: "Вход K"),
                Gate(id: buttonClk, name: "BUTTON", position: CGPoint(x: 80, y: 180), inputCount: 0, outputCount: 1, description: "Такт (CLK)"),
                Gate(id: jkff, name: "JK_FLIPFLOP", position: CGPoint(x: 280, y: 180), inputCount: 3, outputCount: 2, description: "JK-триггер"),
                Gate(id: ledQ, name: "LED", position: CGPoint(x: 480, y: 150), inputCount: 2, outputCount: 0, description: "Выход Q"),
                Gate(id: ledQNot, name: "LED", position: CGPoint(x: 480, y: 210), inputCount: 2, outputCount: 0, description: "Выход Q̄"),
                Gate(id: ground, name: "CONST0", position: CGPoint(x: 580, y: 200), inputCount: 0, outputCount: 1, description: "Земля (-)")
            ],
            wires: [
                Wire(fromGateID: buttonJ, fromPinIndex: 0, toGateID: jkff, toPinIndex: 0),     // J -> JKFF J
                Wire(fromGateID: buttonClk, fromPinIndex: 0, toGateID: jkff, toPinIndex: 1),   // CLK -> JKFF CLK
                Wire(fromGateID: buttonK, fromPinIndex: 0, toGateID: jkff, toPinIndex: 2),     // K -> JKFF K
                Wire(fromGateID: jkff, fromPinIndex: 0, toGateID: ledQ, toPinIndex: 0),        // JKFF Q -> LED Q +
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: ledQ, toPinIndex: 1),      // GND -> LED Q -
                Wire(fromGateID: jkff, fromPinIndex: 1, toGateID: ledQNot, toPinIndex: 0),     // JKFF Q̄ -> LED Q̄ +
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: ledQNot, toPinIndex: 1)    // GND -> LED Q̄ -
            ]
        )
    }
    
    // MARK: - Multiplexer 4-to-1 Data Selector (Мультиплексор 4:1)
    static var mux4to1DataSelector: ExampleScheme {
        let input0 = UUID()
        let input1 = UUID()
        let input2 = UUID()
        let input3 = UUID()
        let select0 = UUID()
        let select1 = UUID()
        let mux = UUID()
        let led = UUID()
        let ground = UUID()
        
        return ExampleScheme(
            name: NSLocalizedString("example.mux4to1.name", comment: "4-to-1 Multiplexer"),
            description: NSLocalizedString("example.mux4to1.desc", comment: "Data selector: selects one of 4 inputs based on 2 select lines (S1S0: 00→D0, 01→D1, 10→D2, 11→D3)."),
            category: NSLocalizedString("example.mux4to1.category", comment: "Multiplexers & Demultiplexers"),
            gates: [
                Gate(id: input0, name: "BUTTON", position: CGPoint(x: 50, y: 100), inputCount: 0, outputCount: 1, description: "Вход D0"),
                Gate(id: input1, name: "BUTTON", position: CGPoint(x: 50, y: 160), inputCount: 0, outputCount: 1, description: "Вход D1"),
                Gate(id: input2, name: "BUTTON", position: CGPoint(x: 50, y: 220), inputCount: 0, outputCount: 1, description: "Вход D2"),
                Gate(id: input3, name: "BUTTON", position: CGPoint(x: 50, y: 280), inputCount: 0, outputCount: 1, description: "Вход D3"),
                Gate(id: select0, name: "BUTTON", position: CGPoint(x: 150, y: 350), inputCount: 0, outputCount: 1, description: "Селектор S0"),
                Gate(id: select1, name: "BUTTON", position: CGPoint(x: 230, y: 350), inputCount: 0, outputCount: 1, description: "Селектор S1"),
                Gate(id: mux, name: "MUX_4TO1", position: CGPoint(x: 300, y: 190), inputCount: 6, outputCount: 1, description: "Мультиплексор 4:1"),
                Gate(id: led, name: "LED", position: CGPoint(x: 480, y: 190), inputCount: 2, outputCount: 0, description: "Выход"),
                Gate(id: ground, name: "CONST0", position: CGPoint(x: 580, y: 240), inputCount: 0, outputCount: 1, description: "Земля (-)")
            ],
            wires: [
                Wire(fromGateID: input0, fromPinIndex: 0, toGateID: mux, toPinIndex: 0),   // D0 -> MUX
                Wire(fromGateID: input1, fromPinIndex: 0, toGateID: mux, toPinIndex: 1),   // D1 -> MUX
                Wire(fromGateID: input2, fromPinIndex: 0, toGateID: mux, toPinIndex: 2),   // D2 -> MUX
                Wire(fromGateID: input3, fromPinIndex: 0, toGateID: mux, toPinIndex: 3),   // D3 -> MUX
                Wire(fromGateID: select0, fromPinIndex: 0, toGateID: mux, toPinIndex: 4),  // S0 -> MUX
                Wire(fromGateID: select1, fromPinIndex: 0, toGateID: mux, toPinIndex: 5),  // S1 -> MUX
                Wire(fromGateID: mux, fromPinIndex: 0, toGateID: led, toPinIndex: 0),      // MUX OUT -> LED +
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: led, toPinIndex: 1)    // GND -> LED -
            ]
        )
    }
    
    // MARK: - Demultiplexer 1-to-4 Distributor (Демультиплексор 1:4)
    static var demux1to4Distributor: ExampleScheme {
        let input = UUID()
        let select0 = UUID()
        let select1 = UUID()
        let demux = UUID()
        let led0 = UUID()
        let led1 = UUID()
        let led2 = UUID()
        let led3 = UUID()
        let ground = UUID()
        
        return ExampleScheme(
            name: NSLocalizedString("example.demux1to4.name", comment: "1-to-4 Demultiplexer"),
            description: NSLocalizedString("example.demux1to4.desc", comment: "Data distributor: routes input to one of 4 outputs based on 2 select lines (S1S0: 00→OUT0, 01→OUT1, 10→OUT2, 11→OUT3)."),
            category: NSLocalizedString("example.demux1to4.category", comment: "Multiplexers & Demultiplexers"),
            gates: [
                Gate(id: input, name: "BUTTON", position: CGPoint(x: 50, y: 200), inputCount: 0, outputCount: 1, description: "Вход данных"),
                Gate(id: select0, name: "BUTTON", position: CGPoint(x: 150, y: 300), inputCount: 0, outputCount: 1, description: "Селектор S0"),
                Gate(id: select1, name: "BUTTON", position: CGPoint(x: 230, y: 300), inputCount: 0, outputCount: 1, description: "Селектор S1"),
                Gate(id: demux, name: "DEMUX_1TO4", position: CGPoint(x: 300, y: 200), inputCount: 3, outputCount: 4, description: "Демультиплексор 1:4"),
                Gate(id: led0, name: "LED", position: CGPoint(x: 480, y: 130), inputCount: 2, outputCount: 0, description: "Выход 0"),
                Gate(id: led1, name: "LED", position: CGPoint(x: 480, y: 185), inputCount: 2, outputCount: 0, description: "Выход 1"),
                Gate(id: led2, name: "LED", position: CGPoint(x: 480, y: 240), inputCount: 2, outputCount: 0, description: "Выход 2"),
                Gate(id: led3, name: "LED", position: CGPoint(x: 480, y: 295), inputCount: 2, outputCount: 0, description: "Выход 3"),
                Gate(id: ground, name: "CONST0", position: CGPoint(x: 580, y: 220), inputCount: 0, outputCount: 1, description: "Земля (-)")
            ],
            wires: [
                Wire(fromGateID: input, fromPinIndex: 0, toGateID: demux, toPinIndex: 0),     // IN -> DEMUX
                Wire(fromGateID: select0, fromPinIndex: 0, toGateID: demux, toPinIndex: 1),   // S0 -> DEMUX
                Wire(fromGateID: select1, fromPinIndex: 0, toGateID: demux, toPinIndex: 2),   // S1 -> DEMUX
                Wire(fromGateID: demux, fromPinIndex: 0, toGateID: led0, toPinIndex: 0),      // OUT0 -> LED0 +
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: led0, toPinIndex: 1),     // GND -> LED0 -
                Wire(fromGateID: demux, fromPinIndex: 1, toGateID: led1, toPinIndex: 0),      // OUT1 -> LED1 +
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: led1, toPinIndex: 1),     // GND -> LED1 -
                Wire(fromGateID: demux, fromPinIndex: 2, toGateID: led2, toPinIndex: 0),      // OUT2 -> LED2 +
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: led2, toPinIndex: 1),     // GND -> LED2 -
                Wire(fromGateID: demux, fromPinIndex: 3, toGateID: led3, toPinIndex: 0),      // OUT3 -> LED3 +
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: led3, toPinIndex: 1)      // GND -> LED3 -
            ]
        )
    }
    
    // MARK: - 4-Bit Counter Example (4-битный счетчик)
    static var counter4BitExample: ExampleScheme {
        let clock = UUID()
        let reset = UUID()
        let counter = UUID()
        let led0 = UUID()
        let led1 = UUID()
        let led2 = UUID()
        let led3 = UUID()
        let ground = UUID()
        
        return ExampleScheme(
            name: NSLocalizedString("example.counter4bit.name", comment: "4-Bit Counter"),
            description: NSLocalizedString("example.counter4bit.desc", comment: "4-bit binary counter: counts from 0 to 15 on each clock pulse. Reset button clears to 0."),
            category: NSLocalizedString("example.counter4bit.category", comment: "Counters & Registers"),
            gates: [
                Gate(id: clock, name: "CLOCK", position: CGPoint(x: 80, y: 150), inputCount: 0, outputCount: 1, description: "Генератор тактов"),
                Gate(id: reset, name: "BUTTON", position: CGPoint(x: 80, y: 220), inputCount: 0, outputCount: 1, description: "Сброс"),
                Gate(id: counter, name: "COUNTER_4BIT", position: CGPoint(x: 280, y: 185), inputCount: 2, outputCount: 4, description: "4-битный счетчик"),
                Gate(id: led0, name: "LED", position: CGPoint(x: 480, y: 130), inputCount: 2, outputCount: 0, description: "Бит 0 (LSB)"),
                Gate(id: led1, name: "LED", position: CGPoint(x: 480, y: 180), inputCount: 2, outputCount: 0, description: "Бит 1"),
                Gate(id: led2, name: "LED", position: CGPoint(x: 480, y: 230), inputCount: 2, outputCount: 0, description: "Бит 2"),
                Gate(id: led3, name: "LED", position: CGPoint(x: 480, y: 280), inputCount: 2, outputCount: 0, description: "Бит 3 (MSB)"),
                Gate(id: ground, name: "CONST0", position: CGPoint(x: 580, y: 220), inputCount: 0, outputCount: 1, description: "Земля (-)")
            ],
            wires: [
                Wire(fromGateID: clock, fromPinIndex: 0, toGateID: counter, toPinIndex: 0),   // CLK -> Counter
                Wire(fromGateID: reset, fromPinIndex: 0, toGateID: counter, toPinIndex: 1),   // RST -> Counter
                Wire(fromGateID: counter, fromPinIndex: 0, toGateID: led0, toPinIndex: 0),    // Q0 -> LED0 +
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: led0, toPinIndex: 1),     // GND -> LED0 -
                Wire(fromGateID: counter, fromPinIndex: 1, toGateID: led1, toPinIndex: 0),    // Q1 -> LED1 +
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: led1, toPinIndex: 1),     // GND -> LED1 -
                Wire(fromGateID: counter, fromPinIndex: 2, toGateID: led2, toPinIndex: 0),    // Q2 -> LED2 +
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: led2, toPinIndex: 1),     // GND -> LED2 -
                Wire(fromGateID: counter, fromPinIndex: 3, toGateID: led3, toPinIndex: 0),    // Q3 -> LED3 +
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: led3, toPinIndex: 1)      // GND -> LED3 -
            ]
        )
    }
    
    // MARK: - 4-Bit Register Example (4-битный регистр)
    static var register4BitExample: ExampleScheme {
        let data0 = UUID()
        let data1 = UUID()
        let data2 = UUID()
        let data3 = UUID()
        let clock = UUID()
        let load = UUID()
        let register = UUID()
        let led0 = UUID()
        let led1 = UUID()
        let led2 = UUID()
        let led3 = UUID()
        let ground = UUID()
        
        return ExampleScheme(
            name: NSLocalizedString("example.register4bit.name", comment: "4-Bit Register"),
            description: NSLocalizedString("example.register4bit.desc", comment: "4-bit data register: stores 4-bit value when LOAD is high on clock edge. Outputs retain value until new load."),
            category: NSLocalizedString("example.register4bit.category", comment: "Counters & Registers"),
            gates: [
                Gate(id: data0, name: "BUTTON", position: CGPoint(x: 50, y: 100), inputCount: 0, outputCount: 1, description: "Данные D0"),
                Gate(id: data1, name: "BUTTON", position: CGPoint(x: 50, y: 160), inputCount: 0, outputCount: 1, description: "Данные D1"),
                Gate(id: data2, name: "BUTTON", position: CGPoint(x: 50, y: 220), inputCount: 0, outputCount: 1, description: "Данные D2"),
                Gate(id: data3, name: "BUTTON", position: CGPoint(x: 50, y: 280), inputCount: 0, outputCount: 1, description: "Данные D3"),
                Gate(id: clock, name: "BUTTON", position: CGPoint(x: 150, y: 350), inputCount: 0, outputCount: 1, description: "Такт (CLK)"),
                Gate(id: load, name: "BUTTON", position: CGPoint(x: 230, y: 350), inputCount: 0, outputCount: 1, description: "Загрузка (LOAD)"),
                Gate(id: register, name: "REGISTER_4BIT", position: CGPoint(x: 280, y: 190), inputCount: 6, outputCount: 4, description: "4-битный регистр"),
                Gate(id: led0, name: "LED", position: CGPoint(x: 480, y: 145), inputCount: 2, outputCount: 0, description: "Выход Q0"),
                Gate(id: led1, name: "LED", position: CGPoint(x: 480, y: 195), inputCount: 2, outputCount: 0, description: "Выход Q1"),
                Gate(id: led2, name: "LED", position: CGPoint(x: 480, y: 245), inputCount: 2, outputCount: 0, description: "Выход Q2"),
                Gate(id: led3, name: "LED", position: CGPoint(x: 480, y: 295), inputCount: 2, outputCount: 0, description: "Выход Q3"),
                Gate(id: ground, name: "CONST0", position: CGPoint(x: 580, y: 240), inputCount: 0, outputCount: 1, description: "Земля (-)")
            ],
            wires: [
                Wire(fromGateID: data0, fromPinIndex: 0, toGateID: register, toPinIndex: 0),     // D0 -> Register
                Wire(fromGateID: data1, fromPinIndex: 0, toGateID: register, toPinIndex: 1),     // D1 -> Register
                Wire(fromGateID: data2, fromPinIndex: 0, toGateID: register, toPinIndex: 2),     // D2 -> Register
                Wire(fromGateID: data3, fromPinIndex: 0, toGateID: register, toPinIndex: 3),     // D3 -> Register
                Wire(fromGateID: clock, fromPinIndex: 0, toGateID: register, toPinIndex: 4),     // CLK -> Register
                Wire(fromGateID: load, fromPinIndex: 0, toGateID: register, toPinIndex: 5),      // LOAD -> Register
                Wire(fromGateID: register, fromPinIndex: 0, toGateID: led0, toPinIndex: 0),      // Q0 -> LED0 +
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: led0, toPinIndex: 1),        // GND -> LED0 -
                Wire(fromGateID: register, fromPinIndex: 1, toGateID: led1, toPinIndex: 0),      // Q1 -> LED1 +
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: led1, toPinIndex: 1),        // GND -> LED1 -
                Wire(fromGateID: register, fromPinIndex: 2, toGateID: led2, toPinIndex: 0),      // Q2 -> LED2 +
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: led2, toPinIndex: 1),        // GND -> LED2 -
                Wire(fromGateID: register, fromPinIndex: 3, toGateID: led3, toPinIndex: 0),      // Q3 -> LED3 +
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: led3, toPinIndex: 1)         // GND -> LED3 -
            ]
        )
    }
    
    // MARK: - 3-to-8 Decoder Example (Декодер 3:8)
    static var decoder3to8Example: ExampleScheme {
        let input0 = UUID()
        let input1 = UUID()
        let input2 = UUID()
        let decoder = UUID()
        let led0 = UUID()
        let led1 = UUID()
        let led2 = UUID()
        let led3 = UUID()
        let led4 = UUID()
        let led5 = UUID()
        let led6 = UUID()
        let led7 = UUID()
        let ground = UUID()
        
        return ExampleScheme(
            name: NSLocalizedString("example.decoder3to8.name", comment: "3-to-8 Decoder"),
            description: NSLocalizedString("example.decoder3to8.desc", comment: "Binary decoder: converts 3-bit binary input (0-7) to one-hot 8-bit output. Only one LED lights at a time."),
            category: NSLocalizedString("example.decoder3to8.category", comment: "Decoders & Encoders"),
            gates: [
                Gate(id: input0, name: "BUTTON", position: CGPoint(x: 50, y: 150), inputCount: 0, outputCount: 1, description: "Вход A0 (LSB)"),
                Gate(id: input1, name: "BUTTON", position: CGPoint(x: 50, y: 210), inputCount: 0, outputCount: 1, description: "Вход A1"),
                Gate(id: input2, name: "BUTTON", position: CGPoint(x: 50, y: 270), inputCount: 0, outputCount: 1, description: "Вход A2 (MSB)"),
                Gate(id: decoder, name: "DECODER_3TO8", position: CGPoint(x: 240, y: 270), inputCount: 3, outputCount: 8, description: "Декодер 3:8"),
                Gate(id: led0, name: "LED", position: CGPoint(x: 420, y: 140), inputCount: 2, outputCount: 0, description: "Выход Y0"),
                Gate(id: led1, name: "LED", position: CGPoint(x: 420, y: 180), inputCount: 2, outputCount: 0, description: "Выход Y1"),
                Gate(id: led2, name: "LED", position: CGPoint(x: 420, y: 220), inputCount: 2, outputCount: 0, description: "Выход Y2"),
                Gate(id: led3, name: "LED", position: CGPoint(x: 420, y: 260), inputCount: 2, outputCount: 0, description: "Выход Y3"),
                Gate(id: led4, name: "LED", position: CGPoint(x: 420, y: 300), inputCount: 2, outputCount: 0, description: "Выход Y4"),
                Gate(id: led5, name: "LED", position: CGPoint(x: 420, y: 340), inputCount: 2, outputCount: 0, description: "Выход Y5"),
                Gate(id: led6, name: "LED", position: CGPoint(x: 420, y: 380), inputCount: 2, outputCount: 0, description: "Выход Y6"),
                Gate(id: led7, name: "LED", position: CGPoint(x: 420, y: 420), inputCount: 2, outputCount: 0, description: "Выход Y7"),
                Gate(id: ground, name: "CONST0", position: CGPoint(x: 520, y: 300), inputCount: 0, outputCount: 1, description: "Земля (-)")
            ],
            wires: [
                Wire(fromGateID: input0, fromPinIndex: 0, toGateID: decoder, toPinIndex: 0),    // A0 -> Decoder
                Wire(fromGateID: input1, fromPinIndex: 0, toGateID: decoder, toPinIndex: 1),    // A1 -> Decoder
                Wire(fromGateID: input2, fromPinIndex: 0, toGateID: decoder, toPinIndex: 2),    // A2 -> Decoder
                Wire(fromGateID: decoder, fromPinIndex: 0, toGateID: led0, toPinIndex: 0),      // Y0 -> LED0 +
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: led0, toPinIndex: 1),       // GND -> LED0 -
                Wire(fromGateID: decoder, fromPinIndex: 1, toGateID: led1, toPinIndex: 0),      // Y1 -> LED1 +
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: led1, toPinIndex: 1),       // GND -> LED1 -
                Wire(fromGateID: decoder, fromPinIndex: 2, toGateID: led2, toPinIndex: 0),      // Y2 -> LED2 +
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: led2, toPinIndex: 1),       // GND -> LED2 -
                Wire(fromGateID: decoder, fromPinIndex: 3, toGateID: led3, toPinIndex: 0),      // Y3 -> LED3 +
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: led3, toPinIndex: 1),       // GND -> LED3 -
                Wire(fromGateID: decoder, fromPinIndex: 4, toGateID: led4, toPinIndex: 0),      // Y4 -> LED4 +
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: led4, toPinIndex: 1),       // GND -> LED4 -
                Wire(fromGateID: decoder, fromPinIndex: 5, toGateID: led5, toPinIndex: 0),      // Y5 -> LED5 +
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: led5, toPinIndex: 1),       // GND -> LED5 -
                Wire(fromGateID: decoder, fromPinIndex: 6, toGateID: led6, toPinIndex: 0),      // Y6 -> LED6 +
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: led6, toPinIndex: 1),       // GND -> LED6 -
                Wire(fromGateID: decoder, fromPinIndex: 7, toGateID: led7, toPinIndex: 0),      // Y7 -> LED7 +
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: led7, toPinIndex: 1)        // GND -> LED7 -
            ]
        )
    }
    
    // MARK: - 4-Bit Comparator Example (4-битный компаратор)
    static var comparator4BitExample: ExampleScheme {
        let a0 = UUID(), a1 = UUID(), a2 = UUID(), a3 = UUID()
        let b0 = UUID(), b1 = UUID(), b2 = UUID(), b3 = UUID()
        let comparator = UUID()
        let ledGreater = UUID()
        let ledEqual = UUID()
        let ledLess = UUID()
        let ground = UUID()
        
        return ExampleScheme(
            name: NSLocalizedString("example.comparator4bit.name", comment: "4-Bit Comparator"),
            description: NSLocalizedString("example.comparator4bit.desc", comment: "Compares two 4-bit numbers A and B. Shows: A>B, A=B, or A<B."),
            category: NSLocalizedString("example.comparator4bit.category", comment: "Comparators"),
            gates: [
                Gate(id: a0, name: "BUTTON", position: CGPoint(x: 50, y: 100), inputCount: 0, outputCount: 1, description: "A0 (LSB)"),
                Gate(id: a1, name: "BUTTON", position: CGPoint(x: 50, y: 150), inputCount: 0, outputCount: 1, description: "A1"),
                Gate(id: a2, name: "BUTTON", position: CGPoint(x: 50, y: 200), inputCount: 0, outputCount: 1, description: "A2"),
                Gate(id: a3, name: "BUTTON", position: CGPoint(x: 50, y: 250), inputCount: 0, outputCount: 1, description: "A3 (MSB)"),
                Gate(id: b0, name: "BUTTON", position: CGPoint(x: 150, y: 100), inputCount: 0, outputCount: 1, description: "B0 (LSB)"),
                Gate(id: b1, name: "BUTTON", position: CGPoint(x: 150, y: 150), inputCount: 0, outputCount: 1, description: "B1"),
                Gate(id: b2, name: "BUTTON", position: CGPoint(x: 150, y: 200), inputCount: 0, outputCount: 1, description: "B2"),
                Gate(id: b3, name: "BUTTON", position: CGPoint(x: 150, y: 250), inputCount: 0, outputCount: 1, description: "B3 (MSB)"),
                Gate(id: comparator, name: "COMPARATOR_4BIT", position: CGPoint(x: 320, y: 175), inputCount: 8, outputCount: 3, description: "4-битный компаратор"),
                Gate(id: ledGreater, name: "LED", position: CGPoint(x: 500, y: 130), inputCount: 2, outputCount: 0, description: "A > B"),
                Gate(id: ledEqual, name: "LED", position: CGPoint(x: 500, y: 175), inputCount: 2, outputCount: 0, description: "A = B"),
                Gate(id: ledLess, name: "LED", position: CGPoint(x: 500, y: 220), inputCount: 2, outputCount: 0, description: "A < B"),
                Gate(id: ground, name: "CONST0", position: CGPoint(x: 600, y: 190), inputCount: 0, outputCount: 1, description: "Земля (-)")
            ],
            wires: [
                Wire(fromGateID: a0, fromPinIndex: 0, toGateID: comparator, toPinIndex: 0),
                Wire(fromGateID: a1, fromPinIndex: 0, toGateID: comparator, toPinIndex: 1),
                Wire(fromGateID: a2, fromPinIndex: 0, toGateID: comparator, toPinIndex: 2),
                Wire(fromGateID: a3, fromPinIndex: 0, toGateID: comparator, toPinIndex: 3),
                Wire(fromGateID: b0, fromPinIndex: 0, toGateID: comparator, toPinIndex: 4),
                Wire(fromGateID: b1, fromPinIndex: 0, toGateID: comparator, toPinIndex: 5),
                Wire(fromGateID: b2, fromPinIndex: 0, toGateID: comparator, toPinIndex: 6),
                Wire(fromGateID: b3, fromPinIndex: 0, toGateID: comparator, toPinIndex: 7),
                Wire(fromGateID: comparator, fromPinIndex: 0, toGateID: ledGreater, toPinIndex: 0),
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: ledGreater, toPinIndex: 1),
                Wire(fromGateID: comparator, fromPinIndex: 1, toGateID: ledEqual, toPinIndex: 0),
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: ledEqual, toPinIndex: 1),
                Wire(fromGateID: comparator, fromPinIndex: 2, toGateID: ledLess, toPinIndex: 0),
                Wire(fromGateID: ground, fromPinIndex: 0, toGateID: ledLess, toPinIndex: 1)
            ]
        )
    }
    
    // MARK: - Transistor Switch (Транзисторный переключатель)
    static var transistorSwitch: ExampleScheme {
        let battery = UUID()
        let button = UUID()
        let resistor = UUID()
        let transistor = UUID()
        let led = UUID()
        
        return ExampleScheme(
            name: NSLocalizedString("example.transistorSwitch.name", comment: "Transistor Switch"),
            description: NSLocalizedString("example.transistorSwitch.desc", comment: "NPN transistor as a switch: pressing button allows current to flow from collector to emitter, lighting the LED."),
            category: NSLocalizedString("example.transistorSwitch.category", comment: "Physical Components"),
            gates: [
                Gate(id: battery, name: "BATTERY", position: CGPoint(x: 100, y: 100), inputCount: 0, outputCount: 2, description: "Источник питания"),
                Gate(id: button, name: "BUTTON", position: CGPoint(x: 100, y: 250), inputCount: 0, outputCount: 1, description: "Управление"),
                Gate(id: resistor, name: "RESISTOR", position: CGPoint(x: 220, y: 250), inputCount: 1, outputCount: 1, description: "Резистор (ограничение тока)"),
                Gate(id: transistor, name: "BJT_NPN", position: CGPoint(x: 350, y: 200), inputCount: 1, outputCount: 2, description: "NPN транзистор"),
                Gate(id: led, name: "LED", position: CGPoint(x: 350, y: 100), inputCount: 2, outputCount: 0, description: "Светодиод")
            ],
            wires: [
                Wire(fromGateID: battery, fromPinIndex: 0, toGateID: led, toPinIndex: 0),        // Battery + -> LED анод (+)
                Wire(fromGateID: led, fromPinIndex: 1, toGateID: transistor, toPinIndex: 0),     // LED катод (-) -> Transistor C (коллектор, выход 0)
                Wire(fromGateID: transistor, fromPinIndex: 1, toGateID: battery, toPinIndex: 1), // Transistor E (эмиттер, выход 1) -> Battery -
                Wire(fromGateID: button, fromPinIndex: 0, toGateID: resistor, toPinIndex: 0),    // Button -> Resistor
                Wire(fromGateID: resistor, fromPinIndex: 0, toGateID: transistor, toPinIndex: 0) // Resistor -> Transistor B (база, вход 0)
            ]
        )
    }
    
    // Функция для загрузки схемы с автоматическим созданием связей
    static func loadScheme(_ scheme: ExampleScheme) -> (gates: [Gate], wires: [Wire]) {
        // Создаём копии вентилей с новыми ID
        var gateIDMap: [UUID: UUID] = [:]
        let newGates = scheme.gates.map { gate -> Gate in
            var g = gate
            let newID = UUID()
            gateIDMap[gate.id] = newID
            g.id = newID
            return g
        }
        
        // Создаём копии проводов с обновлёнными ID вентилей
        let newWires = scheme.wires.map { wire -> Wire in
            return Wire(
                id: UUID(),
                fromGateID: gateIDMap[wire.fromGateID] ?? wire.fromGateID,
                fromPinIndex: wire.fromPinIndex,
                toGateID: gateIDMap[wire.toGateID] ?? wire.toGateID,
                toPinIndex: wire.toPinIndex
            )
        }
        
        return (gates: newGates, wires: newWires)
    }
}
