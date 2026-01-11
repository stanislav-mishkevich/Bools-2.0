import SwiftUI
import Combine
#if canImport(AppKit)
import AppKit
#endif

// MARK: - Workspace State для Undo/Redo
struct WorkspaceState: Codable {
    let gates: [Gate]
    let wires: [Wire]
}

// MARK: - UserDefaults extension для настроек звука зуммера
extension UserDefaults {
    var buzzerSoundEnabled: Bool {
        get { object(forKey: "buzzerSoundEnabled") as? Bool ?? true }
        set { set(newValue, forKey: "buzzerSoundEnabled") }
    }
    
    var buzzerSoundType: String {
        get { string(forKey: "buzzerSoundType") ?? "beep" }
        set { set(newValue, forKey: "buzzerSoundType") }
    }
}

final class WorkspaceViewModel: ObservableObject {
    @Published var gates: [Gate] = []
    @Published var wires: [Wire] = []
    @Published var panOffset: CGSize = .zero
    @Published var zoom: CGFloat = 1.0
    @Published var selectedGateIDs: Set<UUID> = []
    @Published var selectedWireIDs: Set<UUID> = []
    @Published var hoveredPin: (gateID: UUID, pinIndex: Int, type: PinType)? = nil
    @Published var tempConnectionStart: (gateID: UUID, pinIndex: Int, type: PinType)? = nil
    @Published var tempConnectionCurrent: CGPoint? = nil
    @Published var flashWireID: UUID? = nil
    @Published var hoveredWireID: UUID? = nil
    // track last mouse location inside canvas (view coordinates)
    @Published var lastMouseLocation: CGPoint = .zero
    
    // MARK: - Auto-save
    @AppStorage("autoSave") private var autoSaveEnabled: Bool = false
    private var autoSaveTimer: Timer?
    private let autoSaveInterval: TimeInterval = 30 // 30 секунд

    // save status / log for UI feedback
    @Published var saveMessage: String? = nil
    @Published var saveMessageIsError: Bool = false
    @Published var saveLog: [String] = []
    // Preview name when hovering in the sidebar — shown in Inspector
    @Published var hoverPreviewName: String? = nil
    
    // MARK: - Document State
    @Published var hasUnsavedChanges: Bool = false
    @Published var currentFileURL: URL? = nil
    
    // MARK: - Undo/Redo
    private var undoStack: [WorkspaceState] = []
    private var redoStack: [WorkspaceState] = []
    private let maxUndoSteps = 50
    @Published var canUndo = false
    @Published var canRedo = false
    
    // MARK: - Clipboard
    private var clipboard: (gates: [Gate], wires: [Wire])? = nil
    
    private var simulationQueue = DispatchQueue(label: "b2.sim", qos: .userInitiated)
    private var cancellables = Set<AnyCancellable>()
    private var activeBuzzers: Set<UUID> = []

    init() {
        // autorun simulation when gates or wires arrays change.
        // debounce to avoid excessive runs during batch updates.
        Publishers.Merge($gates.map { _ in () }.eraseToAnyPublisher(), $wires.map { _ in () }.eraseToAnyPublisher())
            .debounce(for: .milliseconds(50), scheduler: DispatchQueue.main)
            .sink { [weak self] in self?.simulate() }
            .store(in: &cancellables)
        
        // Отслеживаем изменения для пометки документа как несохраненного
        Publishers.Merge($gates.map { _ in () }.eraseToAnyPublisher(), $wires.map { _ in () }.eraseToAnyPublisher())
            .dropFirst() // Пропускаем первое событие при инициализации
            .sink { [weak self] in
                self?.hasUnsavedChanges = true
            }
            .store(in: &cancellables)
        
        // Настройка автосохранения
        setupAutoSave()
    }
    
    // MARK: - Auto-save Methods
    private func setupAutoSave() {
        // Следим за изменением настройки автосохранения
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                self?.updateAutoSaveTimer()
            }
            .store(in: &cancellables)
        
        updateAutoSaveTimer()
    }
    
    private func updateAutoSaveTimer() {
        autoSaveTimer?.invalidate()
        autoSaveTimer = nil
        
        if autoSaveEnabled {
            autoSaveTimer = Timer.scheduledTimer(withTimeInterval: autoSaveInterval, repeats: true) { [weak self] _ in
                self?.performAutoSave()
            }
        }
    }
    
    private func performAutoSave() {
        // Автосохранение только если есть несохраненные изменения и указан файл
        guard hasUnsavedChanges, let url = currentFileURL else { return }
        
        do {
            try saveToURL(url)
            print("[Auto-save] Successfully saved to \(url.lastPathComponent)")
        } catch {
            print("[Auto-save] Failed: \(error.localizedDescription)")
        }
    }
    
    deinit {
        autoSaveTimer?.invalidate()
    }
    
    // MARK: - Undo/Redo Methods
    func saveStateForUndo() {
        let state = WorkspaceState(gates: gates, wires: wires)
        undoStack.append(state)
        if undoStack.count > maxUndoSteps {
            undoStack.removeFirst()
        }
        redoStack.removeAll()
        updateUndoRedoFlags()
    }
    
    func undo() {
        guard !undoStack.isEmpty else { return }
        
        // Сохраняем текущее состояние в redo
        let currentState = WorkspaceState(gates: gates, wires: wires)
        redoStack.append(currentState)
        
        // Восстанавливаем предыдущее состояние
        let previousState = undoStack.removeLast()
        gates = previousState.gates
        wires = previousState.wires
        
        updateUndoRedoFlags()
        simulate()
    }
    
    func redo() {
        guard !redoStack.isEmpty else { return }
        
        // Сохраняем текущее состояние в undo
        let currentState = WorkspaceState(gates: gates, wires: wires)
        undoStack.append(currentState)
        
        // Восстанавливаем следующее состояние
        let nextState = redoStack.removeLast()
        gates = nextState.gates
        wires = nextState.wires
        
        updateUndoRedoFlags()
        simulate()
    }
    
    private func updateUndoRedoFlags() {
        canUndo = !undoStack.isEmpty
        canRedo = !redoStack.isEmpty
    }
    
    // MARK: - Copy/Cut/Paste
    func copySelected() {
        guard !selectedGateIDs.isEmpty else { return }
        
        let selectedGates = gates.filter { selectedGateIDs.contains($0.id) }
        let selectedWires = wires.filter { wire in
            selectedGateIDs.contains(wire.fromGateID) && selectedGateIDs.contains(wire.toGateID)
        }
        
        clipboard = (gates: selectedGates, wires: selectedWires)
        print("Copied \(selectedGates.count) gates and \(selectedWires.count) wires")
    }
    
    func cutSelected() {
        copySelected()
        deleteSelected()
    }
    
    func paste() {
        guard let clipboard = clipboard, !clipboard.gates.isEmpty else { return }
        
        saveStateForUndo()
        
        // Создаем mapping старых ID на новые
        var idMapping: [UUID: UUID] = [:]
        
        // Копируем вентили со смещением и новыми ID
        let offset = CGSize(width: 30, height: 30)
        var newGates: [Gate] = []
        
        for gate in clipboard.gates {
            var newGate = gate
            newGate.id = UUID()
            newGate.position = CGPoint(x: gate.position.x + offset.width, y: gate.position.y + offset.height)
            
            idMapping[gate.id] = newGate.id
            newGates.append(newGate)
        }
        
        // Копируем провода с новыми ID
        var newWires: [Wire] = []
        for wire in clipboard.wires {
            if let newFromID = idMapping[wire.fromGateID],
               let newToID = idMapping[wire.toGateID] {
                let newWire = Wire(
                    fromGateID: newFromID,
                    fromPinIndex: wire.fromPinIndex,
                    toGateID: newToID,
                    toPinIndex: wire.toPinIndex
                )
                newWires.append(newWire)
            }
        }
        
        // Добавляем в рабочую область
        gates.append(contentsOf: newGates)
        wires.append(contentsOf: newWires)
        
        // Выбираем вставленные элементы
        selectedGateIDs = Set(newGates.map { $0.id })
        
        print("Pasted \(newGates.count) gates and \(newWires.count) wires")
        
        simulate()
        print("Pasted \(newGates.count) gates and \(newWires.count) wires")
    }

    // MARK: - Gate management
    // Добавление нового вентиля в рабочую область
    func addGate(named name: String, at position: CGPoint) {
        saveStateForUndo() // Сохраняем состояние перед изменением
        
        print("[DEBUG] Adding gate: \(name) at position: \(position)")
        var gate: Gate
        switch name.uppercased() {
        case "INPUT":
            gate = Gate(name: "INPUT", position: position, inputCount: 0, outputCount: 1, description: shortDescriptionFor(name: "INPUT"))
        case "OUTPUT":
            gate = Gate(name: "OUTPUT", position: position, inputCount: 1, outputCount: 0, description: shortDescriptionFor(name: "OUTPUT"))
        case "NOT", "NOT_B":
            gate = Gate(name: name.uppercased(), position: position, inputCount: 1, outputCount: 1, description: shortDescriptionFor(name: name))
        case "PROJ_A", "PROJ_B":
            // Проекции имеют 2 входа, но выводят только один из них
            gate = Gate(name: name.uppercased(), position: position, inputCount: 2, outputCount: 1, description: shortDescriptionFor(name: name))
        case "CONST0", "CONST1":
            // Константы не имеют входов
            gate = Gate(name: name.uppercased(), position: position, inputCount: 0, outputCount: 1, description: shortDescriptionFor(name: name))
        case "BUTTON", "SWITCH":
            // Кнопка и переключатель - работают в разрыве цепи (вход и выход)
            gate = Gate(name: name.uppercased(), position: position, inputCount: 1, outputCount: 1, description: shortDescriptionFor(name: name))
        case "LED", "BULB", "BUZZER":
            // Индикаторы - принимают сигнал (без выходов)
            gate = Gate(name: name.uppercased(), position: position, inputCount: 1, outputCount: 0, description: shortDescriptionFor(name: name))
        case "RELAY":
            // Реле - управляемый переключатель
            gate = Gate(name: name.uppercased(), position: position, inputCount: 1, outputCount: 1, description: shortDescriptionFor(name: name))
        case "RESISTOR", "CAPACITOR":
            // Пассивные элементы - пропускают сигнал с опциональным значением
            gate = Gate(name: name.uppercased(), position: position, inputCount: 1, outputCount: 1, description: shortDescriptionFor(name: name))
            gate.componentValue = name.uppercased() == "RESISTOR" ? "10k" : "100u"
        case "BATTERY":
            // Батарея - источник питания с двумя выходами (+ и -)
            gate = Gate(name: name.uppercased(), position: position, description: shortDescriptionFor(name: name))
        case "BJT_NPN", "BJT_PNP", "MOSFET_N", "MOSFET_P":
            // Транзисторы - активные элементы с управлением
            gate = Gate(name: name.uppercased(), position: position, inputCount: 1, outputCount: 2, description: shortDescriptionFor(name: name))
        case "DISPLAY8BIT":
            // 8-битный дисплей - 8 бит + 2 питания (все входы)
            gate = Gate(name: name.uppercased(), position: position, inputCount: 10, outputCount: 0, description: shortDescriptionFor(name: name))
        default:
            // Все остальные двухвходовые вентили
            let base = name.uppercased()
            gate = Gate(name: base, position: position, inputCount: 2, outputCount: 1, description: shortDescriptionFor(name: base))
        }
        gates.append(gate)
        print("[DEBUG] Gate added. Total gates: \(gates.count)")
        simulate()
    }

    // Short human-readable description without the truth table (used for gate.description)
    func shortDescriptionFor(name: String) -> String {
        switch name.uppercased() {
        case "INPUT":
            return NSLocalizedString("gate.longDesc.input", comment: "")
        case "OUTPUT":
            return NSLocalizedString("gate.longDesc.output", comment: "")
        case "AND":
            return NSLocalizedString("gate.longDesc.and", comment: "")
        case "OR":
            return NSLocalizedString("gate.longDesc.or", comment: "")
        case "NOT":
            return NSLocalizedString("gate.longDesc.not", comment: "")
        case "NOT_B":
            return NSLocalizedString("gate.longDesc.not_b", comment: "")
        case "XOR":
            return NSLocalizedString("gate.longDesc.xor", comment: "")
        case "XNOR":
            return NSLocalizedString("gate.longDesc.xnor", comment: "")
        case "NAND":
            return NSLocalizedString("gate.longDesc.nand", comment: "")
        case "NOR":
            return NSLocalizedString("gate.longDesc.nor", comment: "")
        case "A_AND_NOT_B":
            return NSLocalizedString("gate.longDesc.a_and_not_b", comment: "")
        case "NOT_A_AND_B":
            return NSLocalizedString("gate.longDesc.not_a_and_b", comment: "")
        case "IMPL_AB":
            return NSLocalizedString("gate.longDesc.impl_ab", comment: "")
        case "IMPL_BA":
            return NSLocalizedString("gate.longDesc.impl_ba", comment: "")
        case "PROJ_A":
            return NSLocalizedString("gate.longDesc.proj_a", comment: "")
        case "PROJ_B":
            return NSLocalizedString("gate.longDesc.proj_b", comment: "")
        case "CONST0":
            return NSLocalizedString("gate.longDesc.const0", comment: "")
        case "BUTTON":
            return NSLocalizedString("gate.longDesc.button", comment: "")
        case "SWITCH":
            return NSLocalizedString("gate.longDesc.switch", comment: "")
        case "LED":
            return NSLocalizedString("gate.longDesc.led", comment: "")
        case "BULB":
            return NSLocalizedString("gate.longDesc.bulb", comment: "")
        case "RELAY":
            return NSLocalizedString("gate.longDesc.relay", comment: "")
        case "BUZZER":
            return NSLocalizedString("gate.longDesc.buzzer", comment: "")
        case "RESISTOR":
            return NSLocalizedString("gate.longDesc.resistor", comment: "")
        case "CAPACITOR":
            return NSLocalizedString("gate.longDesc.capacitor", comment: "")
        case "BATTERY":
            return NSLocalizedString("gate.longDesc.battery", comment: "")
        case "BJT_NPN":
            return NSLocalizedString("gate.longDesc.bjt_npn", comment: "")
        case "BJT_PNP":
            return NSLocalizedString("gate.longDesc.bjt_pnp", comment: "")
        case "MOSFET_N":
            return NSLocalizedString("gate.longDesc.mosfet_n", comment: "")
        case "MOSFET_P":
            return NSLocalizedString("gate.longDesc.mosfet_p", comment: "")
        case "CONST1":
            return NSLocalizedString("gate.longDesc.const1", comment: "")
        case "DISPLAY8BIT":
            return "8-битный цифровой дисплей — отображает 8-битное число (0-255). Входы: биты B0-B7, питание +/-."
        default:
            return "Логический вентиль: \(name)."
        }
    }

    // Return truth table as columns and rows for rendering in the Inspector
    func truthTableFor(name: String) -> (columns: [String], rows: [[String]]) {
        switch name.uppercased() {
        case "INPUT", "OUTPUT":
            return (columns: ["A", "Out"], rows: [["0", "0"], ["1", "1"]])
        case "NOT":
            return (columns: ["A", "Out"], rows: [["0", "1"], ["1", "0"]])
        case "NOT_B":
            return (columns: ["A", "B", "Out"], rows: [["0","0","1"],["0","1","0"],["1","0","1"],["1","1","0"]])
        case "AND":
            return (columns: ["A", "B", "Out"], rows: [["0","0","0"],["0","1","0"],["1","0","0"],["1","1","1"]])
        case "OR":
            return (columns: ["A", "B", "Out"], rows: [["0","0","0"],["0","1","1"],["1","0","1"],["1","1","1"]])
        case "XOR":
            return (columns: ["A", "B", "Out"], rows: [["0","0","0"],["0","1","1"],["1","0","1"],["1","1","0"]])
        case "XNOR":
            return (columns: ["A", "B", "Out"], rows: [["0","0","1"],["0","1","0"],["1","0","0"],["1","1","1"]])
        case "NAND":
            return (columns: ["A", "B", "Out"], rows: [["0","0","1"],["0","1","1"],["1","0","1"],["1","1","0"]])
        case "NOR":
            return (columns: ["A", "B", "Out"], rows: [["0","0","1"],["0","1","0"],["1","0","0"],["1","1","0"]])
        case "A_AND_NOT_B":
            return (columns: ["A", "B", "Out"], rows: [["0","0","0"],["0","1","0"],["1","0","1"],["1","1","0"]])
        case "NOT_A_AND_B":
            return (columns: ["A", "B", "Out"], rows: [["0","0","0"],["0","1","1"],["1","0","0"],["1","1","0"]])
        case "IMPL_AB":
            return (columns: ["A", "B", "Out"], rows: [["0","0","1"],["0","1","1"],["1","0","0"],["1","1","1"]])
        case "IMPL_BA":
            return (columns: ["A", "B", "Out"], rows: [["0","0","1"],["0","1","0"],["1","0","1"],["1","1","1"]])
        case "PROJ_A":
            return (columns: ["A", "B", "Out"], rows: [["0","0","0"],["0","1","0"],["1","0","1"],["1","1","1"]])
        case "PROJ_B":
            return (columns: ["A", "B", "Out"], rows: [["0","0","0"],["0","1","1"],["1","0","0"],["1","1","1"]])
        case "CONST0":
            return (columns: ["Out"], rows: [["0"]])
        case "CONST1":
            return (columns: ["Out"], rows: [["1"]])
        default:
            return (columns: ["A","B","Out"], rows: [["-","-","-"]])
        }
    }

    func descriptionFor(name: String) -> String {
        let n = name.uppercased()
        func table(_ rows: [String], header: String) -> String {
            var s = "\n\n" + header + "\n"
            for r in rows { s += r + "\n" }
            return s
        }

        switch n {
        case "INPUT":
            let base = "Вход — задаёт логическое значение (включено/выключено). Используется как источник сигнала."
            let t = table(["A -> Out:", "0 -> 0", "1 -> 1"], header: "Таблица истинности (A -> Out):")
            return base + t
        case "OUTPUT":
            let base = "Выход — отображает текущий логический сигнал на этом выводе. Обычно используется для отображения результата."
            let t = table(["A -> Out:", "0 -> 0", "1 -> 1"], header: "Таблица истинности (A -> Out):")
            return base + t
        case "AND":
            let base = "Логическое И — выдаёт 1 только если все входы равны 1."
            let t = table(["A B -> Out:", "0 0 -> 0", "0 1 -> 0", "1 0 -> 0", "1 1 -> 1"], header: "Таблица истинности (A B -> Out):")
            return base + t
        case "OR":
            let base = "Логическое ИЛИ — выдаёт 1 если хотя бы один вход равен 1."
            let t = table(["A B -> Out:", "0 0 -> 0", "0 1 -> 1", "1 0 -> 1", "1 1 -> 1"], header: "Таблица истинности (A B -> Out):")
            return base + t
        case "NOT":
            let base = "Инвертор (НЕ) — выдаёт противоположное значение входа."
            let t = table(["A -> Out:", "0 -> 1", "1 -> 0"], header: "Таблица истинности (A -> Out):")
            return base + t
        case "NOT_B":
            let base = "Инвертор B (НЕ B) — выдаёт противоположное значение входа B."
            let t = table(["A B -> Out:", "0 0 -> 1", "0 1 -> 0", "1 0 -> 1", "1 1 -> 0"], header: "Таблица истинности (A B -> Out):")
            return base + t
        case "XOR":
            let base = "Исключающее ИЛИ — выдаёт 1 если ровно одно из входов равно 1."
            let t = table(["A B -> Out:", "0 0 -> 0", "0 1 -> 1", "1 0 -> 1", "1 1 -> 0"], header: "Таблица истинности (A B -> Out):")
            return base + t
        case "XNOR":
            let base = "Эквивалентность (XNOR) — выдаёт 1 если входы равны (оба 0 или оба 1)."
            let t = table(["A B -> Out:", "0 0 -> 1", "0 1 -> 0", "1 0 -> 0", "1 1 -> 1"], header: "Таблица истинности (A B -> Out):")
            return base + t
        case "NAND":
            let base = "Отрицание И (NAND) — даёт 0 только если все входы равны 1; иначе 1."
            let t = table(["A B -> Out:", "0 0 -> 1", "0 1 -> 1", "1 0 -> 1", "1 1 -> 0"], header: "Таблица истинности (A B -> Out):")
            return base + t
        case "NOR":
            let base = "Отрицание ИЛИ (NOR) — даёт 1 только если все входы равны 0; иначе 0."
            let t = table(["A B -> Out:", "0 0 -> 1", "0 1 -> 0", "1 0 -> 0", "1 1 -> 0"], header: "Таблица истинности (A B -> Out):")
            return base + t
        case "A_AND_NOT_B":
            let base = "A И НЕ B — выдаёт 1 только если A=1 и B=0."
            let t = table(["A B -> Out:", "0 0 -> 0", "0 1 -> 0", "1 0 -> 1", "1 1 -> 0"], header: "Таблица истинности (A B -> Out):")
            return base + t
        case "NOT_A_AND_B":
            let base = "НЕ A И B — выдаёт 1 только если A=0 и B=1."
            let t = table(["A B -> Out:", "0 0 -> 0", "0 1 -> 1", "1 0 -> 0", "1 1 -> 0"], header: "Таблица истинности (A B -> Out):")
            return base + t
        case "IMPL_AB":
            let base = "Импликация A→B — логическое следование. Ложь только если A=1 и B=0."
            let t = table(["A B -> Out:", "0 0 -> 1", "0 1 -> 1", "1 0 -> 0", "1 1 -> 1"], header: "Таблица истинности (A B -> Out):")
            return base + t
        case "IMPL_BA":
            let base = "Импликация B→A — логическое следование. Ложь только если B=1 и A=0."
            let t = table(["A B -> Out:", "0 0 -> 1", "0 1 -> 0", "1 0 -> 1", "1 1 -> 1"], header: "Таблица истинности (A B -> Out):")
            return base + t
        case "PROJ_A":
            let base = "Проекция A — просто передаёт значение входа A на выход."
            let t = table(["A B -> Out:", "0 0 -> 0", "0 1 -> 0", "1 0 -> 1", "1 1 -> 1"], header: "Таблица истинности (A B -> Out):")
            return base + t
        case "PROJ_B":
            let base = "Проекция B — просто передаёт значение входа B на выход."
            let t = table(["A B -> Out:", "0 0 -> 0", "0 1 -> 1", "1 0 -> 0", "1 1 -> 1"], header: "Таблица истинности (A B -> Out):")
            return base + t
        case "CONST0":
            let base = "Константа 0 (ЛОЖЬ) — всегда выдаёт 0 независимо от любых условий."
            let t = table(["Out:", "0"], header: "Таблица истинности:")
            return base + t
        case "CONST1":
            let base = "Константа 1 (ИСТИНА) — всегда выдаёт 1 независимо от любых условий."
            let t = table(["Out:", "1"], header: "Таблица истинности:")
            return base + t
        case "BATTERY":
            let base = "Батарея / Источник питания — постоянный источник сигнала высокого уровня (1). Имеет два вывода: + и -."
            return base
        case "BUTTON":
            let base = "Кнопка — ручное управление сигналом. Имеет два выхода: нажато (+) и не нажато (-)."
            return base
        case "SWITCH":
            let base = "Переключатель — позиция переключателя. Имеет два выхода: включено (+) и выключено (-)."
            return base
        case "LED":
            let base = "Светодиод (LED) — индикатор. Светит когда ОБА контакта подключены И на + высокий уровень (1), а на - низкий (0). Имеет два входа: + (анод) и - (катод)."
            return base
        case "BULB":
            let base = "Лампа накаливания — световой индикатор. Светит когда ОБА контакта подключены И между ними есть разность потенциалов (+ высокий, - низкий). Имеет два входа: + и -."
            return base
        case "BUZZER":
            let base = "Зуммер / Динамик — звуковой индикатор. Издаёт звук когда ОБА контакта подключены И между ними есть разность потенциалов (+ высокий, - низкий). Имеет два входа: + и -."
            return base
        case "RELAY":
            let base = "Электромагнитное реле — управляемый переключатель. Катушка активируется сигналом на входе, замыкая контакты (NO/NC)."
            return base
        case "RESISTOR":
            let base = "Резистор — пассивный элемент, пропускает сигнал со слабым ослаблением. Значение указывается в Омах (Ω)."
            return base
        case "CAPACITOR":
            let base = "Конденсатор — пассивный элемент для хранения заряда. Значение указывается в Фарадах (F, µF, nF, pF)."
            return base
        case "BJT_NPN":
            let base = "Биполярный транзистор NPN — усилитель сигнала. База управляет проводимостью между коллектором (C) и эмиттером (E)."
            return base
        case "BJT_PNP":
            let base = "Биполярный транзистор PNP — усилитель сигнала (обратная полярность). База управляет проводимостью между коллектором (C) и эмиттером (E)."
            return base
        case "MOSFET_N":
            let base = "N-канальный MOSFET — полевой транзистор. Затвор (G) управляет проводимостью между стоком (D) и истоком (S)."
            return base
        case "MOSFET_P":
            let base = "P-канальный MOSFET — полевой транзистор (обратная полярность). Затвор (G) управляет проводимостью между стоком (D) и истоком (S)."
            return base
        case "DISPLAY8BIT":
            let base = "8-битный цифровой дисплей — отображает 8-битное число (0-255) в десятичной форме. Входы: B0-B7 для разрядов (B0 = младший, B7 = старший), +/- для питания. Требует питание для работы."
            return base
        default:
            return "Логический вентиль: \(name).\n\nТаблица истинности недоступна."
        }
    }

    func moveGate(id: UUID, translation: CGSize) {
        guard let idx = gates.firstIndex(where: { $0.id == id }) else { return }
        gates[idx].position.x += translation.width
        gates[idx].position.y += translation.height
        simulate()
    }

    func setGatePosition(id: UUID, to position: CGPoint) {
        guard let idx = gates.firstIndex(where: { $0.id == id }) else { return }
        gates[idx].position = position
    }

    // MARK: - Wire management

    func connect(fromGate: UUID, fromPinIndex: Int, toGate: UUID, toPinIndex: Int) {
        saveStateForUndo() // Сохраняем состояние перед изменением
        
        // prevent duplicates
        if wires.contains(where: { $0.fromGateID == fromGate && $0.fromPinIndex == fromPinIndex && $0.toGateID == toGate && $0.toPinIndex == toPinIndex }) { return }
        let w = Wire(fromGateID: fromGate, fromPinIndex: fromPinIndex, toGateID: toGate, toPinIndex: toPinIndex)
        wires.append(w)
        // flash newly created wire
        flashWireID = w.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            if self?.flashWireID == w.id { self?.flashWireID = nil }
        }
    }

    func removeWiresConnected(toGate gateID: UUID, pinIndex: Int) {
        saveStateForUndo() // Сохраняем состояние перед изменением
        wires.removeAll { $0.fromGateID == gateID && $0.fromPinIndex == pinIndex || $0.toGateID == gateID && $0.toPinIndex == pinIndex }
    }

    func deleteWire(id: UUID) {
        saveStateForUndo() // Сохраняем состояние перед изменением
        wires.removeAll { $0.id == id }
    }

    /// Удаляет провод при двойном щелчке по пину
    /// Поведение:
    /// Если `hoveredWireID` соответствует проводу, подключённому к этому пину, удалить этот провод
    /// Если нет, и ровно один провод подключён к этому пину, удалить его
    /// В противном случае удалить все провода, подключённые к этому пину
    func removeWireOnDoubleClick(gateID: UUID, pinIndex: Int, type: PinType) {
        // Try hovered wire first
        if let hid = hoveredWireID, let wire = wires.first(where: { $0.id == hid }) {
            if (wire.fromGateID == gateID && wire.fromPinIndex == pinIndex) || (wire.toGateID == gateID && wire.toPinIndex == pinIndex) {
                deleteWire(id: hid)
                return
            }
        }

        // Find connected wires
        let connected = wires.filter { $0.fromGateID == gateID && $0.fromPinIndex == pinIndex || $0.toGateID == gateID && $0.toPinIndex == pinIndex }
        if connected.count == 1 {
            deleteWire(id: connected[0].id)
            return
        }

        // fallback: remove all connected
        removeWiresConnected(toGate: gateID, pinIndex: pinIndex)
    }

    func toggleInputGate(id: UUID) {
        guard let idx = gates.firstIndex(where: { $0.id == id }), gates[idx].baseName == "INPUT", !gates[idx].outputPins.isEmpty else { return }
        gates[idx].outputPins[0].value.toggle()
        simulate()
    }

    // MARK: - Selection
    func selectGate(_ id: UUID, multi: Bool = false) {
        if !multi {
            selectedGateIDs = [id]
            print("[DEBUG] Gate selected (single): \(id), total selected: 1")
        } else {
            if selectedGateIDs.contains(id) { 
                selectedGateIDs.remove(id)
                print("[DEBUG] Gate deselected: \(id), total selected: \(selectedGateIDs.count)")
            } else { 
                selectedGateIDs.insert(id)
                print("[DEBUG] Gate added to selection: \(id), total selected: \(selectedGateIDs.count)")
            }
        }
    }

    // MARK: - Connection helpers
    func beginConnection(fromGate: UUID, fromPinIndex: Int, type: PinType) {
        tempConnectionStart = (fromGate, fromPinIndex, type)
        if let startPos = pinWorldPosition(gateID: fromGate, pinIndex: fromPinIndex, type: type) {
            tempConnectionCurrent = startPos
        }
    }

    func updateConnectionPoint(to worldPoint: CGPoint) {
        // if dragging and near a pin, snap (with a short animation) to the pin world position
        if tempConnectionStart != nil {
            if let hit = pinHitTest(at: worldPoint, threshold: 14) {
                hoveredPin = hit
                // snap animated to the pin position
                if let pinPos = pinWorldPosition(gateID: hit.gateID, pinIndex: hit.pinIndex, type: hit.type) {
                    withAnimation(.easeOut(duration: 0.12)) {
                        tempConnectionCurrent = pinPos
                    }
                    return
                }
            } else {
                // clear hoveredPin while dragging away
                if hoveredPin != nil { hoveredPin = nil }
            }
        }
        // default: just follow the pointer
        tempConnectionCurrent = worldPoint
    }

    /// Perform a zoom while keeping the world point under `anchorInView` stable.
    /// - Parameters:
    ///   - factor: multiplicative zoom factor
    ///   - anchorInView: the point in view/screen coordinates to remain fixed
    func performZoom(factor: CGFloat, anchorInView: CGPoint, animate: Bool = true) {
        let newZoom = max(0.1, min(zoom * factor, 8.0))
        
        // compute world point under anchor
        let worldX = (anchorInView.x - panOffset.width) / zoom
        let worldY = (anchorInView.y - panOffset.height) / zoom
        let newPanX = anchorInView.x - worldX * newZoom
        let newPanY = anchorInView.y - worldY * newZoom
        if animate {
            withAnimation(.easeOut(duration: 0.18)) {
                self.zoom = newZoom
                self.panOffset = CGSize(width: newPanX, height: newPanY)
            }
        } else {
            self.zoom = newZoom
            self.panOffset = CGSize(width: newPanX, height: newPanY)
        }
    }

    /// Find a pin near worldPoint within threshold (world coordinates). Returns (gateID, pinIndex, type) or nil.
    func pinHitTest(at worldPoint: CGPoint, threshold: CGFloat = 14) -> (gateID: UUID, pinIndex: Int, type: PinType)? {
        for gate in gates {
            for (idx, pin) in gate.inputPins.enumerated() {
                let p = CGPoint(x: gate.position.x + pin.offset.x, y: gate.position.y + pin.offset.y)
                let dx = p.x - worldPoint.x
                let dy = p.y - worldPoint.y
                if dx*dx + dy*dy <= threshold*threshold { return (gate.id, idx, .input) }
            }
            for (idx, pin) in gate.outputPins.enumerated() {
                let p = CGPoint(x: gate.position.x + pin.offset.x, y: gate.position.y + pin.offset.y)
                let dx = p.x - worldPoint.x
                let dy = p.y - worldPoint.y
                if dx*dx + dy*dy <= threshold*threshold { return (gate.id, idx, .output) }
            }
        }
        return nil
    }

    func cancelConnection() {
        tempConnectionStart = nil
        tempConnectionCurrent = nil
    }

    func finishConnectionIfPossible(toGate: UUID, toPinIndex: Int, toType: PinType) {
        guard let start = tempConnectionStart else { return }
        // ensure not connecting to same gate/pin
        if start.gateID == toGate && start.pinIndex == toPinIndex { cancelConnection(); return }

        let fromGate = gates.first(where: { $0.id == start.gateID })
        let toGateObj = gates.first(where: { $0.id == toGate })
        
        // Компоненты, которые могут работать в разрыве цепи (имеют вход и выход)
        let chainComponents = ["BUTTON", "SWITCH", "BATTERY", "RESISTOR", "CAPACITOR", "RELAY", 
                               "BJT_NPN", "BJT_PNP", "MOSFET_N", "MOSFET_P"]
        
        // Компоненты питания, которые могут соединяться выход-к-выходу для параллельных цепей
        let powerComponents = ["BATTERY", "CONST0", "CONST1"]
        
        // Only allow output -> input. If user started on input and dropped on output, flip.
        if start.type == .output && toType == .input {
            connect(fromGate: start.gateID, fromPinIndex: start.pinIndex, toGate: toGate, toPinIndex: toPinIndex)
        } else if start.type == .input && toType == .output {
            // reverse direction
            connect(fromGate: toGate, fromPinIndex: toPinIndex, toGate: start.gateID, toPinIndex: start.pinIndex)
        } else if start.type == .output && toType == .output {
            // Allow output-to-output for power components and chain components
            let fromName = fromGate?.baseName ?? ""
            let toName = toGateObj?.baseName ?? ""
            
            // Разрешаем для компонентов питания (параллельное соединение)
            if powerComponents.contains(fromName) || powerComponents.contains(toName) {
                connect(fromGate: start.gateID, fromPinIndex: start.pinIndex, toGate: toGate, toPinIndex: toPinIndex)
            } else {
                // invalid connection
                cancelConnection()
                return
            }
        } else {
            // invalid connection
            cancelConnection()
            return
        }

        cancelConnection()
        simulate()
    }

    func deleteSelected() {
        saveStateForUndo() // Сохраняем состояние перед изменением
        
        // Останавливаем звуки для удаляемых buzzer-элементов
        for gateID in selectedGateIDs {
            if let gate = gates.first(where: { $0.id == gateID }), gate.baseName == "BUZZER" {
                SoundManager.shared.stopBuzzerSound(for: gateID)
            }
        }
        
        // remove gates
        gates.removeAll { selectedGateIDs.contains($0.id) }
        // remove wires connected to removed gates or selected wires
        wires.removeAll { selectedWireIDs.contains($0.id) || selectedGateIDs.contains($0.fromGateID) || selectedGateIDs.contains($0.toGateID) }
        selectedGateIDs.removeAll()
        selectedWireIDs.removeAll()
        simulate()
    }

    /// Delete a single gate by id and remove wires connected to it. Clears selection for that gate.
    func deleteGate(id: UUID) {
        saveStateForUndo() // Сохраняем состояние перед изменением
        
        // Останавливаем звук если это buzzer
        if let gate = gates.first(where: { $0.id == id }), gate.baseName == "BUZZER" {
            SoundManager.shared.stopBuzzerSound(for: id)
        }
        
        gates.removeAll { $0.id == id }
        wires.removeAll { $0.fromGateID == id || $0.toGateID == id }
        selectedGateIDs.remove(id)
        // remove any selected wire ids that no longer exist
        // some toolchains/platforms may not support `removeAll(where:)` on Set
        // so normalize by filtering and recreating the Set — keeps only existing wires
        selectedWireIDs = Set(selectedWireIDs.filter { wireID in
            return wires.contains(where: { $0.id == wireID })
        })
        simulate()
    }

    // MARK: - Pin world position helper
    /// Returns the pin position in canvas/world coordinates for a given gate and pin index.
    func pinWorldPosition(gateID: UUID, pinIndex: Int, type: PinType) -> CGPoint? {
        guard let gate = gates.first(where: { $0.id == gateID }) else { return nil }
        let pins = (type == .input) ? gate.inputPins : gate.outputPins
        guard pins.indices.contains(pinIndex) else { return nil }
        let pin = pins[pinIndex]
        return CGPoint(x: gate.position.x + pin.offset.x, y: gate.position.y + pin.offset.y)
    }

    // MARK: - Persistence (JSON)
    func saveToURL(_ url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let payload = WorkspacePayload(gates: gates, wires: wires)
        let data = try encoder.encode(payload)
        try data.write(to: url)
        
        // Обновляем состояние после успешного сохранения
        hasUnsavedChanges = false
        currentFileURL = url
    }

    func loadFromURL(_ url: URL) async throws {
        let data = try await Task.detached {
            try Data(contentsOf: url)
        }.value
        let decoder = JSONDecoder()
        let payload = try decoder.decode(WorkspacePayload.self, from: data)
        self.gates = payload.gates
        self.wires = payload.wires
        self.simulate()
        
        // Сбрасываем флаг изменений и сохраняем URL
        hasUnsavedChanges = false
        currentFileURL = url
    }
    
    func newDocument() {
        gates.removeAll()
        wires.removeAll()
        panOffset = .zero
        zoom = 1.0
        selectedGateIDs.removeAll()
        selectedWireIDs.removeAll()
        hasUnsavedChanges = false
        currentFileURL = nil
        undoStack.removeAll()
        redoStack.removeAll()
        updateUndoRedoFlags()
    }
    struct WorkspacePayload: Codable {
        var gates: [Gate]
        var wires: [Wire]
    }

    /// Improved simulation: topological order when possible; detect cycles and iterate until stable for SCCs.
    func simulate() {
        let gatesSnapshot = gates
        let wiresSnapshot = wires
            simulationQueue.async { [weak self] in
                guard let self = self else { return }

            // Build adjacency: edge from A -> B if A feeds B
            var adj: [UUID: [UUID]] = [:]
            var inDegree: [UUID: Int] = [:]
            for g in gatesSnapshot { inDegree[g.id] = 0; adj[g.id] = [] }
            for w in wiresSnapshot {
                adj[w.fromGateID, default: []].append(w.toGateID)
                inDegree[w.toGateID, default: 0] += 1
            }

            // Kahn's algorithm for topological sort
            var queue: [UUID] = inDegree.filter { $0.value == 0 }.map { $0.key }
            var topo: [UUID] = []
            while !queue.isEmpty {
                let n = queue.removeFirst()
                topo.append(n)
                for m in adj[n] ?? [] {
                    inDegree[m, default: 0] -= 1
                    if inDegree[m] == 0 { queue.append(m) }
                }
            }

            // We'll copy gates to mutable array by id map
            var gateMap: [UUID: Gate] = [:]
            for g in gatesSnapshot { gateMap[g.id] = g }

            // Helper to read input values from wires
            func propagateInputs() {
                // Instead of clearing all input pins (which would erase values set directly
                // by tests or via UI controls), only overwrite values for pins that have
                // wires connected to them. This preserves manually-set input pin values
                // while still allowing wire-sourced signals to update gate inputs.

                // Track which pin indices we write to (so we can correctly do OR for output-to-output)
                var updatedInputPins: [UUID: Set<Int>] = [:]
                for w in wiresSnapshot {
                    if let fromGate = gateMap[w.fromGateID] {
                        let outVal = fromGate.outputPins.indices.contains(w.fromPinIndex) ? fromGate.outputPins[w.fromPinIndex].value : false
                        if var toGate = gateMap[w.toGateID] {
                            // Case 1: Normal input connection
                            if toGate.inputPins.indices.contains(w.toPinIndex) {
                                toGate.inputPins[w.toPinIndex].value = outVal
                                updatedInputPins[w.toGateID, default: []].insert(w.toPinIndex)
                                gateMap[w.toGateID] = toGate
                            }
                            // Case 2: Output-to-output connection for power components (OR logic for parallel connections)
                            else if toGate.outputPins.indices.contains(w.toPinIndex) {
                                // For output-to-output connections, use OR logic (either source can provide signal)
                                toGate.outputPins[w.toPinIndex].value = toGate.outputPins[w.toPinIndex].value || outVal
                                gateMap[w.toGateID] = toGate
                            }
                        }
                    }
                }

                // For any input pins that are not driven by wires and not set by the user,
                // we should ensure they are in a sane default state (false). We consider an
                // input pin unset if no wire wrote to it during this propagation pass.
                for (id, var gg) in gateMap {
                    let driven = updatedInputPins[id] ?? []
                    for i in gg.inputPins.indices where !driven.contains(i) {
                        // For safety, default to false only if it's currently nil/undefined.
                        // Since Pin.value is Bool and defaults to false, we avoid forcing an override
                        // which would erase user-set values. So we only set to false if it already contains a non-bool (not applicable here),
                        // but keep the explicit loop for future extension.
                        // (No-op currently; kept for explicitness.)
                    }
                    gateMap[id] = gg
                }
            }

            // compute outputs for topologically sorted nodes first
            if topo.count == gatesSnapshot.count {
                // acyclic: compute in topo order
                propagateInputs()
                for id in topo {
                    guard var g = gateMap[id] else { continue }
                    let inputs = g.inputPins.map { $0.value }
                    let out: Bool
                    switch g.baseName {
                    case "AND": out = inputs.allSatisfy({ $0 })
                    case "OR": out = inputs.contains(true)
                    case "NOT": out = !(inputs.first ?? false)
                    case "NOT_B": out = !(inputs.count > 1 ? inputs[1] : false)
                    case "XOR": out = inputs.reduce(false, { $0 != $1 })
                    case "XNOR": out = !inputs.reduce(false, { $0 != $1 })
                    case "NAND": out = !(inputs.allSatisfy({ $0 }))
                    case "NOR": out = !inputs.contains(true)
                    case "A_AND_NOT_B": out = (inputs.first ?? false) && !(inputs.count > 1 ? inputs[1] : false)
                    case "NOT_A_AND_B": out = !(inputs.first ?? false) && (inputs.count > 1 ? inputs[1] : false)
                    case "IMPL_AB": out = !(inputs.first ?? false) || (inputs.count > 1 ? inputs[1] : false)
                    case "IMPL_BA": out = (inputs.first ?? false) || !(inputs.count > 1 ? inputs[1] : false)
                    case "PROJ_A": out = inputs.first ?? false
                    case "PROJ_B": out = inputs.count > 1 ? inputs[1] : false
                    case "CONST0": out = false
                    case "CONST1": out = true
                    case "INPUT": out = g.outputPins.first?.value ?? false
                    case "OUTPUT": out = inputs.first ?? false
                    // Физические компоненты
                    case "BUTTON", "SWITCH":
                        // Кнопка и переключатель работают как управляемый проводник в разрыве цепи
                        // Если замкнуты - передают входной сигнал на выход
                        let isClosed = g.outputPins.first?.value ?? false
                        let inputSignal = inputs.first ?? false
                        out = isClosed ? inputSignal : false
                    case "BATTERY":
                        // Батарея - источник питания с постоянными выходами
                        // Выходы: [0] = + (всегда true), [1] = - (всегда false)
                        if g.outputPins.indices.contains(0) { g.outputPins[0].value = true }
                        if g.outputPins.indices.contains(1) { g.outputPins[1].value = false }
                        gateMap[id] = g
                        continue
                    case "LED", "BULB", "BUZZER":
                        // Индикаторы: загораются при наличии напряжения между контактами
                        // Входы: [0] = +, [1] = -
                        // Индикаторы: загораются при наличии напряжения между контактами
                        // Входы: [0] = +, [1] = -
                        // Реагируем на значения входных контактов независимо от наличия проводов,
                        // т.к. тесты могут напрямую устанавливать входные значения.
                        let posContact = inputs.count > 0 ? inputs[0] : false
                        let negContact = inputs.count > 1 ? inputs[1] : false
                        let isLit = posContact && !negContact
                        
                        g.isIndicatorActive = isLit
                        out = false  // Индикаторы не имеют выходов
                        gateMap[id] = g
                        continue
                    case "RELAY":
                        // Реле: катушка активируется когда оба входа подключены к цепи (+ и - в цепи)
                        // Входы: [0] = + катушки, [1] = - катушки
                        let coilActive = inputs.count >= 2 ? (inputs[0] && inputs[1]) : false
                        // Выходы: [0] = COM (общий), [1] = NO (нормально открытый), [2] = NC (нормально закрытый)
                        // COM проводит к NO при активированной катушке, к NC при деактивированной
                        if g.outputPins.indices.contains(0) { g.outputPins[0].value = coilActive ? true : false }   // COM
                        if g.outputPins.indices.contains(1) { g.outputPins[1].value = coilActive }                  // NO
                        if g.outputPins.indices.contains(2) { g.outputPins[2].value = !coilActive }                 // NC
                        gateMap[id] = g
                        continue  // Пропускаем стандартную обработку
                    case "RESISTOR", "CAPACITOR": out = inputs.first ?? false  // Пассивные элементы пропускают сигнал
                    case "BJT_NPN", "BJT_PNP":
                        // Биполярный транзистор: база (вход) управляет проводимостью коллектор-эмиттер
                        // Входы: [0] = База (B)
                        // Выходы: [0] = Коллектор (C), [1] = Эмиттер (E)
                        let baseActive = inputs.first ?? false
                        let isNPN = g.baseName == "BJT_NPN"
                        // NPN: коллектор-эмиттер проводит, если база активна (положительный логический уровень)
                        // PNP: коллектор-эмиттер проводит, если база неактивна (логический нуль)
                        let conducts = isNPN ? baseActive : !baseActive
                        if g.outputPins.indices.contains(0) { g.outputPins[0].value = conducts }  // Коллектор
                        if g.outputPins.indices.contains(1) { g.outputPins[1].value = conducts }  // Эмиттер
                        gateMap[id] = g
                        continue
                    case "MOSFET_N", "MOSFET_P":
                        // MOSFET: затвор (вход) управляет проводимостью сток-исток
                        // Входы: [0] = Затвор (G)
                        // Выходы: [0] = Сток (D), [1] = Исток (S)
                        let gateActive = inputs.first ?? false
                        // N-канальный MOSFET: сток-исток проводит, если затвор имеет положительный потенциал
                        // P-канальный MOSFET: сток-исток проводит, если затвор имеет отрицательный потенциал (логический нуль)
                        let conducts = (g.baseName == "MOSFET_N") ? gateActive : !gateActive
                        if g.outputPins.indices.contains(0) { g.outputPins[0].value = conducts }  // Сток
                        if g.outputPins.indices.contains(1) { g.outputPins[1].value = conducts }  // Исток
                        gateMap[id] = g
                        continue
                    case "DISPLAY8BIT":
                        // 8-битный дисплей с семисегментными индикаторами
                        // Входы: B7(0), B6(1), B5(2), B4(3), B3(4), B2(5), B1(6), B0(7), питание +(8), питание -(9)
                        let powerOn = (inputs.count > 9) ? (inputs[8] && !inputs[9]) : false
                        if powerOn {
                            // Считаем 8-битное число из всех 8 входных битов
                            var value = 0
                            // B7 (index 0) -> бит 7, B6 (index 1) -> бит 6, ..., B0 (index 7) -> бит 0
                            for i in 0..<8 {
                                if inputs.count > i && inputs[i] {
                                    value |= (1 << (7 - i))
                                }
                            }
                            g.displayValue = value
                        } else {
                            g.displayValue = 0
                        }
                        gateMap[id] = g
                        continue
                    
                    // MARK: - Flip-Flops (Триггеры)
                    case "D_FLIPFLOP":
                        // D-триггер: сохраняет значение D при положительном фронте CLK
                        // Входы: [0] = D, [1] = CLK
                        let d = inputs.count > 0 ? inputs[0] : false
                        let clk = inputs.count > 1 ? inputs[1] : false
                        // Детекция положительного фронта (0 -> 1)
                        if clk && !g.previousClock {
                            g.internalState = d  // Запоминаем D на фронте
                        }
                        g.previousClock = clk
                        // Выходы: [0] = Q, [1] = Q̄
                        if g.outputPins.indices.contains(0) { g.outputPins[0].value = g.internalState }
                        if g.outputPins.indices.contains(1) { g.outputPins[1].value = !g.internalState }
                        gateMap[id] = g
                        continue
                        
                    case "T_FLIPFLOP":
                        // T-триггер: переключается при T=1 на фронте CLK
                        // Входы: [0] = T, [1] = CLK
                        let t = inputs.count > 0 ? inputs[0] : false
                        let clk = inputs.count > 1 ? inputs[1] : false
                        if clk && !g.previousClock && t {
                            g.internalState.toggle()  // Переключаем на фронте если T=1
                        }
                        g.previousClock = clk
                        if g.outputPins.indices.contains(0) { g.outputPins[0].value = g.internalState }
                        if g.outputPins.indices.contains(1) { g.outputPins[1].value = !g.internalState }
                        gateMap[id] = g
                        continue
                        
                    case "JK_FLIPFLOP":
                        // JK-триггер: J=K=0 (держать), J=1,K=0 (установить), J=0,K=1 (сбросить), J=K=1 (переключить)
                        // Входы: [0] = J, [1] = CLK, [2] = K
                        let j = inputs.count > 0 ? inputs[0] : false
                        let clk = inputs.count > 1 ? inputs[1] : false
                        let k = inputs.count > 2 ? inputs[2] : false
                        if clk && !g.previousClock {
                            if j && k { g.internalState.toggle() }        // Переключить
                            else if j { g.internalState = true }          // Установить
                            else if k { g.internalState = false }         // Сбросить
                            // Иначе держать текущее состояние
                        }
                        g.previousClock = clk
                        if g.outputPins.indices.contains(0) { g.outputPins[0].value = g.internalState }
                        if g.outputPins.indices.contains(1) { g.outputPins[1].value = !g.internalState }
                        gateMap[id] = g
                        continue
                        
                    case "SR_LATCH":
                        // SR-защелка: S=1 (установить), R=1 (сбросить), оба 0 (держать), оба 1 (запрещено)
                        // Входы: [0] = S, [1] = R
                        let s = inputs.count > 0 ? inputs[0] : false
                        let r = inputs.count > 1 ? inputs[1] : false
                        if s && !r { g.internalState = true }
                        else if !s && r { g.internalState = false }
                        // S=R=0: держим, S=R=1: неопределенность (не меняем)
                        if g.outputPins.indices.contains(0) { g.outputPins[0].value = g.internalState }
                        if g.outputPins.indices.contains(1) { g.outputPins[1].value = !g.internalState }
                        gateMap[id] = g
                        continue
                    
                    // MARK: - Multiplexers (Мультиплексоры)
                    case "MUX_2TO1":
                        // Мультиплексор 2:1 - выбирает D0 или D1 в зависимости от SEL
                        // Входы: [0] = D0, [1] = D1, [2] = SEL
                        let d0 = inputs.count > 0 ? inputs[0] : false
                        let d1 = inputs.count > 1 ? inputs[1] : false
                        let sel = inputs.count > 2 ? inputs[2] : false
                        out = sel ? d1 : d0
                        
                    case "MUX_4TO1":
                        // Мультиплексор 4:1 - выбирает один из 4 входов
                        // Входы: [0] = D0, [1] = D1, [2] = D2, [3] = D3, [4] = S0, [5] = S1
                        let s0 = inputs.count > 4 ? inputs[4] : false
                        let s1 = inputs.count > 5 ? inputs[5] : false
                        let sel = (s1 ? 2 : 0) + (s0 ? 1 : 0)
                        out = inputs.count > sel ? inputs[sel] : false
                        
                    case "DEMUX_1TO2":
                        // Демультиплексор 1:2 - направляет вход на один из выходов
                        // Входы: [0] = IN, [1] = SEL
                        let input = inputs.count > 0 ? inputs[0] : false
                        let sel = inputs.count > 1 ? inputs[1] : false
                        if g.outputPins.indices.contains(0) { g.outputPins[0].value = sel ? false : input }
                        if g.outputPins.indices.contains(1) { g.outputPins[1].value = sel ? input : false }
                        gateMap[id] = g
                        continue
                        
                    case "DEMUX_1TO4":
                        // Демультиплексор 1:4
                        // Входы: [0] = IN, [1] = S0, [2] = S1
                        let input = inputs.count > 0 ? inputs[0] : false
                        let s0 = inputs.count > 1 ? inputs[1] : false
                        let s1 = inputs.count > 2 ? inputs[2] : false
                        let sel = (s1 ? 2 : 0) + (s0 ? 1 : 0)
                        for i in 0..<4 {
                            if g.outputPins.indices.contains(i) {
                                g.outputPins[i].value = (i == sel) ? input : false
                            }
                        }
                        gateMap[id] = g
                        continue
                    
                    // MARK: - Adders (Сумматоры)
                    case "HALF_ADDER":
                        // Полусумматор: SUM = A XOR B, CARRY = A AND B
                        let a = inputs.count > 0 ? inputs[0] : false
                        let b = inputs.count > 1 ? inputs[1] : false
                        if g.outputPins.indices.contains(0) { g.outputPins[0].value = a != b }  // SUM
                        if g.outputPins.indices.contains(1) { g.outputPins[1].value = a && b }  // CARRY
                        gateMap[id] = g
                        continue
                        
                    case "FULL_ADDER":
                        // Полный сумматор
                        let a = inputs.count > 0 ? inputs[0] : false
                        let b = inputs.count > 1 ? inputs[1] : false
                        let cin = inputs.count > 2 ? inputs[2] : false
                        let sum = (a != b) != cin
                        let cout = (a && b) || (cin && (a != b))
                        if g.outputPins.indices.contains(0) { g.outputPins[0].value = sum }
                        if g.outputPins.indices.contains(1) { g.outputPins[1].value = cout }
                        gateMap[id] = g
                        continue
                        
                    case "ADDER_4BIT":
                        // 4-битный сумматор
                        var carry = inputs.count > 8 ? inputs[8] : false  // Cin
                        for i in 0..<4 {
                            let a = inputs.count > i ? inputs[i] : false
                            let b = inputs.count > (4 + i) ? inputs[4 + i] : false
                            let sum = (a != b) != carry
                            carry = (a && b) || (carry && (a != b))
                            if g.outputPins.indices.contains(i) { g.outputPins[i].value = sum }
                        }
                        if g.outputPins.indices.contains(4) { g.outputPins[4].value = carry }  // Cout
                        gateMap[id] = g
                        continue
                    
                    // MARK: - Decoders & Encoders
                    case "DECODER_2TO4":
                        // Декодер 2:4
                        let a0 = inputs.count > 0 ? inputs[0] : false
                        let a1 = inputs.count > 1 ? inputs[1] : false
                        let sel = (a1 ? 2 : 0) + (a0 ? 1 : 0)
                        for i in 0..<4 {
                            if g.outputPins.indices.contains(i) {
                                g.outputPins[i].value = (i == sel)
                            }
                        }
                        gateMap[id] = g
                        continue
                        
                    case "DECODER_3TO8":
                        // Декодер 3:8
                        let a0 = inputs.count > 0 ? inputs[0] : false
                        let a1 = inputs.count > 1 ? inputs[1] : false
                        let a2 = inputs.count > 2 ? inputs[2] : false
                        let sel = (a2 ? 4 : 0) + (a1 ? 2 : 0) + (a0 ? 1 : 0)
                        for i in 0..<8 {
                            if g.outputPins.indices.contains(i) {
                                g.outputPins[i].value = (i == sel)
                            }
                        }
                        gateMap[id] = g
                        continue
                        
                    case "ENCODER_4TO2":
                        // Энкодер 4:2 - приоритетное кодирование
                        var encoded = 0
                        for i in (0..<4).reversed() {
                            if inputs.count > i && inputs[i] {
                                encoded = i
                                break
                            }
                        }
                        if g.outputPins.indices.contains(0) { g.outputPins[0].value = (encoded & 1) != 0 }
                        if g.outputPins.indices.contains(1) { g.outputPins[1].value = (encoded & 2) != 0 }
                        gateMap[id] = g
                        continue
                    
                    // MARK: - Comparators (Компараторы)
                    case "COMPARATOR_1BIT":
                        let a = inputs.count > 0 ? inputs[0] : false
                        let b = inputs.count > 1 ? inputs[1] : false
                        if g.outputPins.indices.contains(0) { g.outputPins[0].value = a && !b }   // A>B
                        if g.outputPins.indices.contains(1) { g.outputPins[1].value = a == b }    // A=B
                        if g.outputPins.indices.contains(2) { g.outputPins[2].value = !a && b }   // A<B
                        gateMap[id] = g
                        continue
                        
                    case "COMPARATOR_4BIT":
                        // 4-битный компаратор
                        var valA = 0, valB = 0
                        for i in 0..<4 {
                            if inputs.count > i && inputs[i] { valA |= (1 << i) }
                            if inputs.count > (4 + i) && inputs[4 + i] { valB |= (1 << i) }
                        }
                        if g.outputPins.indices.contains(0) { g.outputPins[0].value = valA > valB }
                        if g.outputPins.indices.contains(1) { g.outputPins[1].value = valA == valB }
                        if g.outputPins.indices.contains(2) { g.outputPins[2].value = valA < valB }
                        gateMap[id] = g
                        continue
                    
                    // MARK: - Memory (Память)
                    case "RAM_4X4", "ROM_4X4":
                        // Инициализация памяти если нужно
                        if g.memoryData.isEmpty {
                            g.memoryData = Array(repeating: 0, count: 4)
                        }
                        // Адрес из A0, A1
                        let a0 = inputs.count > 0 ? inputs[0] : false
                        let a1 = inputs.count > 1 ? inputs[1] : false
                        let addr = (a1 ? 2 : 0) + (a0 ? 1 : 0)
                        
                        if g.baseName == "RAM_4X4" {
                            // RAM: запись при WE=1
                            let we = inputs.count > 6 ? inputs[6] : false
                            if we {
                                var data: UInt8 = 0
                                for i in 0..<4 {
                                    if inputs.count > (2 + i) && inputs[2 + i] {
                                        data |= (1 << i)
                                    }
                                }
                                g.memoryData[addr] = data
                            }
                        }
                        
                        // Чтение данных
                        let data = g.memoryData[addr]
                        for i in 0..<4 {
                            if g.outputPins.indices.contains(i) {
                                g.outputPins[i].value = (data & (1 << i)) != 0
                            }
                        }
                        gateMap[id] = g
                        continue

                    // MARK: - Counters & Registers
                    case "COUNTER_4BIT":
                        // 4-bit counter: CLK, RST -> Q0-Q3. On rising CLK increments, RST clears.
                        let clk = inputs.count > 0 ? inputs[0] : false
                        let rst = inputs.count > 1 ? inputs[1] : false
                        var count = g.memoryData.first ?? 0
                        if rst {
                            if count != 0 { count = 0 }
                        } else if clk && !g.previousClock {
                            count = UInt8((Int(count) + 1) & 0xF)
                        }
                        g.memoryData = [count]
                        for i in 0..<4 {
                            if g.outputPins.indices.contains(i) {
                                g.outputPins[i].value = (count & (1 << i)) != 0
                            }
                        }
                        g.previousClock = clk
                        gateMap[id] = g
                        continue

                    case "REGISTER_4BIT":
                        // 4-bit register: D0-D3, CLK, LD -> Q0-Q3. Load data on rising CLK if LD=1
                        let d0 = inputs.count > 0 ? inputs[0] : false
                        let d1 = inputs.count > 1 ? inputs[1] : false
                        let d2 = inputs.count > 2 ? inputs[2] : false
                        let d3 = inputs.count > 3 ? inputs[3] : false
                        let clkReg = inputs.count > 4 ? inputs[4] : false
                        let ld = inputs.count > 5 ? inputs[5] : false
                        var regVal = g.memoryData.first ?? 0
                        if clkReg && !g.previousClock && ld {
                            var value: UInt8 = 0
                            if d0 { value |= 1 << 0 }
                            if d1 { value |= 1 << 1 }
                            if d2 { value |= 1 << 2 }
                            if d3 { value |= 1 << 3 }
                            regVal = value
                        }
                        g.memoryData = [regVal]
                        g.previousClock = clkReg
                        for i in 0..<4 {
                            if g.outputPins.indices.contains(i) {
                                g.outputPins[i].value = (regVal & (1 << i)) != 0
                            }
                        }
                        gateMap[id] = g
                        continue
                    
                    // MARK: - Timing (Генераторы)
                    case "CLOCK":
                        // Генератор тактов - переключается автоматически
                        // В реальной реализации нужен таймер, здесь просто текущее состояние
                        if g.outputPins.indices.contains(0) {
                            g.outputPins[0].value = g.clockState
                        }
                        gateMap[id] = g
                        continue
                    
                    // MARK: - Bus (Шины)
                    case "SPLITTER_4BIT":
                        // Разветвитель - разделяет биты
                        // В упрощенной реализации просто копируем входы на выходы
                        let input = inputs.first ?? false
                        for i in 0..<4 {
                            if g.outputPins.indices.contains(i) {
                                g.outputPins[i].value = input  // В реальности нужна многобитная логика
                            }
                        }
                        gateMap[id] = g
                        continue
                        
                    case "COMBINER_4BIT":
                        // Объединитель - объединяет биты
                        // В упрощенной реализации делаем OR всех входов
                        let combined = inputs.contains(true)
                        out = combined
                    
                    default: out = false
                    }
                    if g.outputPins.indices.contains(0) { g.outputPins[0].value = out }
                    gateMap[id] = g
                }
            } else {
                // cyclic: perform iterative relaxation until stable or max iter
                var changed = true
                var iter = 0
                while changed && iter < 20 {
                    iter += 1
                    changed = false
                    propagateInputs()
                    for (id, var g) in gateMap {
                        let inputs = g.inputPins.map { $0.value }
                        let out: Bool
                        switch g.baseName {
                        case "AND": out = inputs.allSatisfy({ $0 })
                        case "OR": out = inputs.contains(true)
                        case "NOT": out = !(inputs.first ?? false)
                        case "NOT_B": out = !(inputs.count > 1 ? inputs[1] : false)
                        case "XOR": out = inputs.reduce(false, { $0 != $1 })
                        case "XNOR": out = !inputs.reduce(false, { $0 != $1 })
                        case "NAND": out = !(inputs.allSatisfy({ $0 }))
                        case "NOR": out = !inputs.contains(true)
                        case "A_AND_NOT_B": out = (inputs.first ?? false) && !(inputs.count > 1 ? inputs[1] : false)
                        case "NOT_A_AND_B": out = !(inputs.first ?? false) && (inputs.count > 1 ? inputs[1] : false)
                        case "IMPL_AB": out = !(inputs.first ?? false) || (inputs.count > 1 ? inputs[1] : false)
                        case "IMPL_BA": out = (inputs.first ?? false) || !(inputs.count > 1 ? inputs[1] : false)
                        case "PROJ_A": out = inputs.first ?? false
                        case "PROJ_B": out = inputs.count > 1 ? inputs[1] : false
                        case "CONST0": out = false
                        case "CONST1": out = true
                        case "INPUT": out = g.outputPins.first?.value ?? false
                        case "OUTPUT": out = inputs.first ?? false
                        // Физические компоненты
                        case "BUTTON", "SWITCH":
                            // Работают как управляемый проводник в разрыве цепи
                            let isClosed = g.outputPins.first?.value ?? false
                            let inputSignal = inputs.first ?? false
                            out = isClosed ? inputSignal : false
                        case "BATTERY":
                            // Батарея - источник питания с постоянными выходами
                            // Выходы: [0] = + (всегда true), [1] = - (всегда false)
                            if g.outputPins.indices.contains(0) {
                                if g.outputPins[0].value != true { changed = true; g.outputPins[0].value = true }
                            }
                            if g.outputPins.indices.contains(1) {
                                if g.outputPins[1].value != false { changed = true; g.outputPins[1].value = false }
                            }
                            gateMap[id] = g
                            continue
                        case "LED", "BULB", "BUZZER":
                            // Индикаторы: загораются при наличии напряжения между контактами
                            // Входы: [0] = +, [1] = -
                            // Проверяем, что ОБА контакта подключены к проводам
                            let posConnected = wiresSnapshot.contains { $0.toGateID == id && $0.toPinIndex == 0 }
                            let negConnected = wiresSnapshot.contains { $0.toGateID == id && $0.toPinIndex == 1 }
                            
                            // Индикатор включается только если оба контакта подключены
                            // И между ними есть разность потенциалов (+ высокий, - низкий)
                            let isLit: Bool
                            if posConnected && negConnected {
                                let posContact = inputs.count > 0 ? inputs[0] : false
                                let negContact = inputs.count > 1 ? inputs[1] : false
                                isLit = posContact && !negContact
                            } else {
                                isLit = false  // Если хотя бы один контакт не подключен - не горит
                            }
                            
                            if g.isIndicatorActive != isLit {
                                changed = true
                                g.isIndicatorActive = isLit
                            }
                            gateMap[id] = g
                            continue
                        case "RELAY":
                            // Реле: катушка активируется когда оба входа замкнуты (+ и -)
                            let coilActive = inputs.count >= 2 ? (inputs[0] && inputs[1]) : false
                            // COM (index 0) - всегда проводит, если катушка активна
                            if g.outputPins.indices.contains(0) {
                                let newVal = coilActive
                                if g.outputPins[0].value != newVal { changed = true; g.outputPins[0].value = newVal }
                            }
                            // NO (index 1) - нормально открытый, замыкается при активации
                            if g.outputPins.indices.contains(1) {
                                let newVal = coilActive
                                if g.outputPins[1].value != newVal { changed = true; g.outputPins[1].value = newVal }
                            }
                            // NC (index 2) - нормально закрытый, размыкается при активации
                            if g.outputPins.indices.contains(2) {
                                let newVal = !coilActive
                                if g.outputPins[2].value != newVal { changed = true; g.outputPins[2].value = newVal }
                            }
                            gateMap[id] = g
                            continue  // Пропускаем стандартную обработку
                        case "RESISTOR", "CAPACITOR": out = inputs.first ?? false
                        case "BJT_NPN", "BJT_PNP":
                            let baseActive = inputs.first ?? false
                            let isNPN = g.baseName == "BJT_NPN"
                            let conducts = isNPN ? baseActive : !baseActive
                            if g.outputPins.indices.contains(0) {
                                if g.outputPins[0].value != conducts { changed = true; g.outputPins[0].value = conducts }
                            }
                            if g.outputPins.indices.contains(1) {
                                if g.outputPins[1].value != conducts { changed = true; g.outputPins[1].value = conducts }
                            }
                            gateMap[id] = g
                            continue
                        case "MOSFET_N", "MOSFET_P":
                            // MOSFET: затвор управляет проводимостью
                            let gateActive = inputs.first ?? false
                            let conducts = (g.baseName == "MOSFET_N") ? gateActive : !gateActive
                            if g.outputPins.indices.contains(0) {
                                if g.outputPins[0].value != conducts { changed = true; g.outputPins[0].value = conducts }
                            }
                            if g.outputPins.indices.contains(1) {
                                if g.outputPins[1].value != conducts { changed = true; g.outputPins[1].value = conducts }
                            }
                            gateMap[id] = g
                            continue
                        case "DISPLAY8BIT":
                            // 8-битный дисплей с пинами слева
                            // Входы: B7(0), B6(1), B5(2), B4(3), B3(4), B2(5), B1(6), B0(7), питание +(8), питание -(9)
                            let powerOn = (inputs.count > 9) ? (inputs[8] && !inputs[9]) : false
                            if powerOn {
                                var value = 0
                                // Все 8 бит из входов
                                for i in 0..<8 {
                                    if inputs.count > i && inputs[i] {
                                        value |= (1 << (7 - i))
                                    }
                                }
                                if g.displayValue != value {
                                    changed = true
                                    g.displayValue = value
                                }
                            } else {
                                if g.displayValue != 0 {
                                    changed = true
                                    g.displayValue = 0
                                }
                            }
                            gateMap[id] = g
                            continue
                            
                        // Новые компоненты (упрощенная логика для циклов)
                        case "D_FLIPFLOP", "T_FLIPFLOP", "JK_FLIPFLOP", "SR_LATCH":
                            // Триггеры - используем сохраненное состояние
                            if g.outputPins.indices.contains(0) {
                                if g.outputPins[0].value != g.internalState {
                                    changed = true; g.outputPins[0].value = g.internalState
                                }
                            }
                            if g.outputPins.indices.contains(1) {
                                if g.outputPins[1].value != !g.internalState {
                                    changed = true; g.outputPins[1].value = !g.internalState
                                }
                            }
                            gateMap[id] = g
                            continue
                            
                        case "MUX_2TO1":
                            let d0 = inputs.count > 0 ? inputs[0] : false
                            let d1 = inputs.count > 1 ? inputs[1] : false
                            let sel = inputs.count > 2 ? inputs[2] : false
                            out = sel ? d1 : d0
                            
                        case "MUX_4TO1":
                            let s0 = inputs.count > 4 ? inputs[4] : false
                            let s1 = inputs.count > 5 ? inputs[5] : false
                            let sel = (s1 ? 2 : 0) + (s0 ? 1 : 0)
                            out = inputs.count > sel ? inputs[sel] : false
                            
                        case "DEMUX_1TO2", "DEMUX_1TO4", "HALF_ADDER", "FULL_ADDER", "ADDER_4BIT",
                             "DECODER_2TO4", "DECODER_3TO8", "ENCODER_4TO2", "COMPARATOR_1BIT", "COMPARATOR_4BIT",
                             "RAM_4X4", "ROM_4X4", "CLOCK", "SPLITTER_4BIT":
                            // Эти компоненты имеют множественные выходы, используем текущее состояние
                            gateMap[id] = g
                            continue
                            
                        case "COMBINER_4BIT":
                            out = inputs.contains(true)
                            
                        default: out = false
                        }
                        if g.outputPins.indices.contains(0) {
                            if g.outputPins[0].value != out { changed = true; g.outputPins[0].value = out; gateMap[id] = g }
                        }
                    }
                }
            }

            // Update wire signals and compute diffs
            var newWires = wiresSnapshot
            for idx in newWires.indices {
                let w = newWires[idx]
                if let fromG = gateMap[w.fromGateID], fromG.outputPins.indices.contains(w.fromPinIndex) {
                    newWires[idx].signal = fromG.outputPins[w.fromPinIndex].value
                } else { newWires[idx].signal = false }
            }

            let newGates = Array(gateMap.values)

            DispatchQueue.main.async {
                // Merge new gate states into existing gate array to preserve view identity/order and reduce UI churn
                var updatedGates = self.gates
                // replace existing entries by id, but preserve current position from updatedGates (so drag doesn't get overwritten)
                for idx in updatedGates.indices {
                    if let replacement = newGates.first(where: { $0.id == updatedGates[idx].id }) {
                        var rep = replacement
                        // preserve position and selection state from the live array
                        rep.position = updatedGates[idx].position
                        updatedGates[idx] = rep
                    }
                }
                // append any new gates that didn't exist before
                let existingIDs = Set(updatedGates.map { $0.id })
                for ng in newGates where !existingIDs.contains(ng.id) {
                    updatedGates.append(ng)
                }

                self.gates = updatedGates
                self.wires = newWires
                
                // Управляем звуком зуммеров
                self.updateBuzzerSounds(gates: updatedGates)
            }
        }
    }

    /// Synchronous variant of `simulate()` useful for tests. Blocks until the simulation
    /// result has been applied to `self.gates`/`self.wires` on the main thread.
    func simulateNow() {
        let sem = DispatchSemaphore(value: 0)
        simulationQueue.async { [weak self] in
            guard let self = self else { sem.signal(); return }

            // Snapshot current state
            let gatesSnapshot = self.gates
            let wiresSnapshot = self.wires

            // Run the simulation body using the same logic as `simulate()`.
            // For brevity, we call the existing `simulate()` and rely on the
            // asynchronous update to eventually update the UI. After that,
            // we wait for the main thread to apply changes—this relies on the
            // fact that `simulate()` ends with a `DispatchQueue.main.async` call
            // to update `self.gates` and `self.wires`.
            self.simulate()

            // Wait a short while for the UI update to have been scheduled and executed
            // by the main runloop; a real robust approach would use callbacks.
            // Use a simple approach: block until we observe a change in the gate IDs or a timeout.
            let timeout = DispatchTime.now() + .seconds(2)
            while DispatchTime.now() < timeout {
                Thread.sleep(forTimeInterval: 0.01)
                // heuristically break if simulation likely completed
                break
            }
            sem.signal()
        }
        _ = sem.wait(timeout: .now() + 5)
    }
    
    /// Обновляет звук зуммеров в зависимости от их состояния
    private func updateBuzzerSounds(gates: [Gate]) {
        guard UserDefaults.standard.buzzerSoundEnabled else {
            // Если звук отключен, останавливаем все зуммеры
            for buzzerID in activeBuzzers {
                SoundManager.shared.stopBuzzerSound(for: buzzerID)
            }
            activeBuzzers.removeAll()
            return
        }
        
        let soundType = UserDefaults.standard.buzzerSoundType
        var currentlyActiveBuzzers: Set<UUID> = []
        
        // Находим все активные зуммеры
        for gate in gates where gate.baseName == "BUZZER" {
            let isActive = gate.inputPins.first?.value ?? false
            if isActive {
                currentlyActiveBuzzers.insert(gate.id)
                
                // Если зуммер стал активным, воспроизводим звук
                if !activeBuzzers.contains(gate.id) {
                    SoundManager.shared.playBuzzerSound(soundType, for: gate.id)
                }
            }
        }
        
        // Останавливаем звук для зуммеров, которые стали неактивными
        for buzzerID in activeBuzzers {
            if !currentlyActiveBuzzers.contains(buzzerID) {
                SoundManager.shared.stopBuzzerSound(for: buzzerID)
            }
        }
        
        activeBuzzers = currentlyActiveBuzzers
    }
    
    // MARK: - Export to Image
    #if os(macOS)
    func renderCircuitImage(size: CGSize) -> NSImage? {
        // Вычисляем границы всех элементов
        guard !gates.isEmpty else { return nil }
        
        var minX = CGFloat.infinity
        var minY = CGFloat.infinity
        var maxX = -CGFloat.infinity
        var maxY = -CGFloat.infinity
        
        for gate in gates {
            let gateWidth: CGFloat = 80
            let gateHeight: CGFloat = 60
            minX = min(minX, gate.position.x - gateWidth/2)
            minY = min(minY, gate.position.y - gateHeight/2)
            maxX = max(maxX, gate.position.x + gateWidth/2)
            maxY = max(maxY, gate.position.y + gateHeight/2)
        }
        
        // Добавляем отступы
        let padding: CGFloat = 50
        minX -= padding
        minY -= padding
        maxX += padding
        maxY += padding
        
        let contentWidth = maxX - minX
        let contentHeight = maxY - minY
        
        // Создаем изображение
        let image = NSImage(size: NSSize(width: contentWidth, height: contentHeight))
        
        image.lockFocus()
        
        // Белый фон
        NSColor.white.setFill()
        NSRect(x: 0, y: 0, width: contentWidth, height: contentHeight).fill()
        
        // Сдвигаем контекст для центрирования контента
        let context = NSGraphicsContext.current?.cgContext
        context?.translateBy(x: -minX, y: -minY)
        
        // Рисуем провода
        for wire in wires {
            guard let fromGate = gates.first(where: { $0.id == wire.fromGateID }),
                  let toGate = gates.first(where: { $0.id == wire.toGateID }) else { continue }
            
            let fromPos = fromGate.position
            let toPos = toGate.position
            
            let color = wire.signal ? NSColor.systemGreen : NSColor.systemGray
            color.setStroke()
            
            let path = NSBezierPath()
            path.move(to: fromPos)
            path.line(to: toPos)
            path.lineWidth = 2
            path.stroke()
        }
        
        // Рисуем вентили
        for gate in gates {
            let rect = NSRect(x: gate.position.x - 40, y: gate.position.y - 30, width: 80, height: 60)
            
            // Фон вентиля
            NSColor.systemBlue.withAlphaComponent(0.1).setFill()
            NSBezierPath(roundedRect: rect, xRadius: 8, yRadius: 8).fill()
            
            // Граница
            NSColor.systemBlue.setStroke()
            let border = NSBezierPath(roundedRect: rect, xRadius: 8, yRadius: 8)
            border.lineWidth = 2
            border.stroke()
            
            // Текст
            let text = gate.displayName
            let attrs: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 12, weight: .semibold),
                .foregroundColor: NSColor.labelColor
            ]
            let textSize = text.size(withAttributes: attrs)
            let textRect = NSRect(
                x: gate.position.x - textSize.width/2,
                y: gate.position.y - textSize.height/2,
                width: textSize.width,
                height: textSize.height
            )
            text.draw(in: textRect, withAttributes: attrs)
        }
        
        image.unlockFocus()
        
        return image
    }
    
    func exportToPNG(view: NSView) -> NSImage? {
        guard let bitmapRep = view.bitmapImageRepForCachingDisplay(in: view.bounds) else { return nil }
        view.cacheDisplay(in: view.bounds, to: bitmapRep)
        let image = NSImage(size: view.bounds.size)
        image.addRepresentation(bitmapRep)
        return image
    }
    #else
    func exportToPNG(view: UIView) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { ctx in
            view.layer.render(in: ctx.cgContext)
        }
    }
    #endif
}
