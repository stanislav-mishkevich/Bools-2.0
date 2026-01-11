import Foundation
import CoreGraphics

struct Gate: Identifiable, Codable {
    var id: UUID  // Изменено с let на var для возможности копирования с новым ID
    /// каноническое базовое имя, например "AND", "INPUT", "OUTPUT", не должно редактироваться пользователем
    var baseName: String
    /// необязательный суффикс, заданный пользователем, только для отображения
    var userSuffix: String?
    /// необязательное текстовое описание, отображаемое в инспекторе
    var description: String?
    /// значение компонента (для резисторов, конденсаторов и т.д.) - например "10k", "100u"
    var componentValue: String?
    /// позиция на холсте, в пунктах
    var position: CGPoint
    /// входные и выходные пины
    var inputPins: [Pin]
    var outputPins: [Pin]
    /// состояние индикаторов (LED, BULB, BUZZER) - горит ли лампочка
    var isIndicatorActive: Bool = false
    /// значение для 8-битного дисплея (0-255)
    var displayValue: Int = 0
    /// внутреннее состояние триггера/регистра (для D, T, JK, SR триггеров)
    var internalState: Bool = false
    /// предыдущее значение тактового сигнала (для детекции фронта)
    var previousClock: Bool = false
    /// данные памяти (для RAM/ROM компонентов) - массив 8-битных значений
    var memoryData: [UInt8] = []
    /// текущий адрес для памяти
    var memoryAddress: Int = 0
    /// частота генератора тактов (в Гц)
    var clockFrequency: Double = 1.0
    /// текущее состояние генератора тактов
    var clockState: Bool = false

    var displayName: String {
        if let s = userSuffix, !s.isEmpty { 
            if let value = componentValue, !value.isEmpty {
                return "\(baseName) \(s) (\(value))"
            }
            return "\(baseName) \(s)" 
        }
        if let value = componentValue, !value.isEmpty {
            return "\(baseName) (\(value))"
        }
        return baseName
    }

    init(id: UUID = UUID(), name: String, position: CGPoint = .zero, inputCount: Int = 1, outputCount: Int = 1, description: String? = nil) {
        self.id = id
        self.baseName = name
        self.userSuffix = nil
        self.description = description
        self.position = position
        
        // Настраиваем позиции пинов в зависимости от типа компонента
        switch name.uppercased() {
        case "BUTTON", "SWITCH":
            // Кнопка и переключатель: вход слева, выход справа для подключения в разрыв цепи
            self.inputPins = [Pin(type: .input, offset: CGPoint(x: -50, y: 0), label: "IN")]
            self.outputPins = [Pin(type: .output, offset: CGPoint(x: 50, y: 0), label: "OUT")]
            
        case "LED":
            // LED: входы слева с полярностью (анод +, катод -)
            self.inputPins = [
                Pin(type: .input, offset: CGPoint(x: -50, y: -6), label: "+"),
                Pin(type: .input, offset: CGPoint(x: -50, y: 6), label: "-")
            ]
            self.outputPins = []
            
        case "BULB":
            // Лампа: входы слева с полярностью
            self.inputPins = [
                Pin(type: .input, offset: CGPoint(x: -50, y: -8), label: "+"),
                Pin(type: .input, offset: CGPoint(x: -50, y: 8), label: "-")
            ]
            self.outputPins = []
            
        case "RELAY":
            // Реле: катушка слева (2 входа), переключающие контакты справа (COM, NO, NC)
            self.inputPins = [
                Pin(type: .input, offset: CGPoint(x: -50, y: -12), label: "+"),  // Катушка +
                Pin(type: .input, offset: CGPoint(x: -50, y: 12), label: "-")    // Катушка -
            ]
            self.outputPins = [
                Pin(type: .output, offset: CGPoint(x: 50, y: -16), label: "COM"),  // Общий
                Pin(type: .output, offset: CGPoint(x: 50, y: 0), label: "NO"),     // Нормально открытый
                Pin(type: .output, offset: CGPoint(x: 50, y: 16), label: "NC")     // Нормально закрытый
            ]
            
        case "BUZZER":
            // Динамик: входы слева с полярностью
            self.inputPins = [
                Pin(type: .input, offset: CGPoint(x: -50, y: -8), label: "+"),
                Pin(type: .input, offset: CGPoint(x: -50, y: 8), label: "-")
            ]
            self.outputPins = []
            
        case "RESISTOR":
            // Резистор: вход слева, выход справа (без полярности)
            self.inputPins = [Pin(type: .input, offset: CGPoint(x: -50, y: 0))]
            self.outputPins = [Pin(type: .output, offset: CGPoint(x: 50, y: 0))]
            
        case "CAPACITOR":
            // Конденсатор: входы слева с полярностью
            self.inputPins = [
                Pin(type: .input, offset: CGPoint(x: -50, y: -8), label: "+"),
                Pin(type: .input, offset: CGPoint(x: -50, y: 8), label: "-")
            ]
            self.outputPins = []
            
        case "BATTERY":
            // Батарея: два выхода (+ и -)
            self.inputPins = []
            self.outputPins = [
                Pin(type: .output, value: true, offset: CGPoint(x: 50, y: -12), label: "+"),   // положительный полюс (всегда true)
                Pin(type: .output, value: false, offset: CGPoint(x: 50, y: 12), label: "-")    // отрицательный полюс (всегда false)
            ]
            
        case "BJT_NPN", "BJT_PNP":
            // Биполярный транзистор: база (входная), коллектор/эмиттер (выходные)
            self.inputPins = [Pin(type: .input, offset: CGPoint(x: -50, y: 0), label: "B")]
            self.outputPins = [
                Pin(type: .output, offset: CGPoint(x: 50, y: -12), label: "C"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 12), label: "E")
            ]
            
        case "MOSFET_N", "MOSFET_P":
            // MOSFET: затвор (входной), сток/исток (выходные)
            self.inputPins = [Pin(type: .input, offset: CGPoint(x: -50, y: 0), label: "G")]
            self.outputPins = [
                Pin(type: .output, offset: CGPoint(x: 50, y: -12), label: "D"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 12), label: "S")
            ]
            
        case "DISPLAY8BIT":
            // 8-битный цифровой дисплей с семисегментными индикаторами
            // Все 8 бит слева (B7-B0) + питание
            self.inputPins = [
                // Левая сторона: все биты (B7-B0)
                Pin(type: .input, offset: CGPoint(x: -80, y: -56), label: "B7"),  // старший бит
                Pin(type: .input, offset: CGPoint(x: -80, y: -40), label: "B6"),
                Pin(type: .input, offset: CGPoint(x: -80, y: -24), label: "B5"),
                Pin(type: .input, offset: CGPoint(x: -80, y: -8), label: "B4"),
                Pin(type: .input, offset: CGPoint(x: -80, y: 8), label: "B3"),
                Pin(type: .input, offset: CGPoint(x: -80, y: 24), label: "B2"),
                Pin(type: .input, offset: CGPoint(x: -80, y: 40), label: "B1"),
                Pin(type: .input, offset: CGPoint(x: -80, y: 56), label: "B0"),  // младший бит
                // Питание справа внизу
                Pin(type: .input, offset: CGPoint(x: 80, y: 40), label: "+"),   // питание +
                Pin(type: .input, offset: CGPoint(x: 80, y: 56), label: "-")    // питание -
            ]
            self.outputPins = []  // Нет выходов - только индикатор
            
        // MARK: - Триггеры (Flip-Flops)
        case "D_FLIPFLOP":
            // D-триггер: D (данные), CLK (такт), Q (выход), Q̄ (инверсный выход)
            self.inputPins = [
                Pin(type: .input, offset: CGPoint(x: -50, y: -12), label: "D"),
                Pin(type: .input, offset: CGPoint(x: -50, y: 12), label: "CLK")
            ]
            self.outputPins = [
                Pin(type: .output, offset: CGPoint(x: 50, y: -12), label: "Q"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 12), label: "Q̄")
            ]
            
        case "T_FLIPFLOP":
            // T-триггер: T (toggle), CLK (такт), Q, Q̄
            self.inputPins = [
                Pin(type: .input, offset: CGPoint(x: -50, y: -12), label: "T"),
                Pin(type: .input, offset: CGPoint(x: -50, y: 12), label: "CLK")
            ]
            self.outputPins = [
                Pin(type: .output, offset: CGPoint(x: 50, y: -12), label: "Q"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 12), label: "Q̄")
            ]
            
        case "JK_FLIPFLOP":
            // JK-триггер: J, K, CLK, Q, Q̄
            self.inputPins = [
                Pin(type: .input, offset: CGPoint(x: -50, y: -18), label: "J"),
                Pin(type: .input, offset: CGPoint(x: -50, y: 0), label: "CLK"),
                Pin(type: .input, offset: CGPoint(x: -50, y: 18), label: "K")
            ]
            self.outputPins = [
                Pin(type: .output, offset: CGPoint(x: 50, y: -12), label: "Q"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 12), label: "Q̄")
            ]
            
        case "SR_LATCH":
            // SR-защелка: S (set), R (reset), Q, Q̄
            self.inputPins = [
                Pin(type: .input, offset: CGPoint(x: -50, y: -12), label: "S"),
                Pin(type: .input, offset: CGPoint(x: -50, y: 12), label: "R")
            ]
            self.outputPins = [
                Pin(type: .output, offset: CGPoint(x: 50, y: -12), label: "Q"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 12), label: "Q̄")
            ]
            
        // MARK: - Мультиплексоры и демультиплексоры
        case "MUX_2TO1":
            // Мультиплексор 2:1 - 2 входа данных, 1 селектор, 1 выход
            self.inputPins = [
                Pin(type: .input, offset: CGPoint(x: -50, y: -18), label: "D0"),
                Pin(type: .input, offset: CGPoint(x: -50, y: -6), label: "D1"),
                Pin(type: .input, offset: CGPoint(x: 0, y: 32), label: "SEL")  // снизу
            ]
            self.outputPins = [Pin(type: .output, offset: CGPoint(x: 50, y: 0), label: "OUT")]
            
        case "MUX_4TO1":
            // Мультиплексор 4:1 - 4 входа данных, 2 селектора, 1 выход
            self.inputPins = [
                Pin(type: .input, offset: CGPoint(x: -50, y: -24), label: "D0"),
                Pin(type: .input, offset: CGPoint(x: -50, y: -8), label: "D1"),
                Pin(type: .input, offset: CGPoint(x: -50, y: 8), label: "D2"),
                Pin(type: .input, offset: CGPoint(x: -50, y: 24), label: "D3"),
                Pin(type: .input, offset: CGPoint(x: -12, y: 32), label: "S0"),  // снизу
                Pin(type: .input, offset: CGPoint(x: 12, y: 32), label: "S1")    // снизу
            ]
            self.outputPins = [Pin(type: .output, offset: CGPoint(x: 50, y: 0), label: "OUT")]
            
        case "DEMUX_1TO2":
            // Демультиплексор 1:2 - 1 вход, 1 селектор, 2 выхода
            self.inputPins = [
                Pin(type: .input, offset: CGPoint(x: -50, y: 0), label: "IN"),
                Pin(type: .input, offset: CGPoint(x: 0, y: 32), label: "SEL")
            ]
            self.outputPins = [
                Pin(type: .output, offset: CGPoint(x: 50, y: -12), label: "OUT0"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 12), label: "OUT1")
            ]
            
        case "DEMUX_1TO4":
            // Демультиплексор 1:4 - 1 вход, 2 селектора, 4 выхода
            self.inputPins = [
                Pin(type: .input, offset: CGPoint(x: -50, y: 0), label: "IN"),
                Pin(type: .input, offset: CGPoint(x: -12, y: 32), label: "S0"),
                Pin(type: .input, offset: CGPoint(x: 12, y: 32), label: "S1")
            ]
            self.outputPins = [
                Pin(type: .output, offset: CGPoint(x: 50, y: -24), label: "OUT0"),
                Pin(type: .output, offset: CGPoint(x: 50, y: -8), label: "OUT1"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 8), label: "OUT2"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 24), label: "OUT3")
            ]
            
        // MARK: - Счетчики и регистры
        case "COUNTER_4BIT":
            // 4-битный счетчик: CLK, RESET, 4 выхода (Q0-Q3)
            self.inputPins = [
                Pin(type: .input, offset: CGPoint(x: -50, y: -12), label: "CLK"),
                Pin(type: .input, offset: CGPoint(x: -50, y: 12), label: "RST")
            ]
            self.outputPins = [
                Pin(type: .output, offset: CGPoint(x: 50, y: -24), label: "Q0"),
                Pin(type: .output, offset: CGPoint(x: 50, y: -8), label: "Q1"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 8), label: "Q2"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 24), label: "Q3")
            ]
            
        case "REGISTER_4BIT":
            // 4-битный регистр: 4 входа данных, CLK, LOAD, 4 выхода
            self.inputPins = [
                Pin(type: .input, offset: CGPoint(x: -50, y: -30), label: "D0"),
                Pin(type: .input, offset: CGPoint(x: -50, y: -10), label: "D1"),
                Pin(type: .input, offset: CGPoint(x: -50, y: 10), label: "D2"),
                Pin(type: .input, offset: CGPoint(x: -50, y: 30), label: "D3"),
                Pin(type: .input, offset: CGPoint(x: -12, y: 42), label: "CLK"),
                Pin(type: .input, offset: CGPoint(x: 12, y: 42), label: "LD")
            ]
            self.outputPins = [
                Pin(type: .output, offset: CGPoint(x: 50, y: -24), label: "Q0"),
                Pin(type: .output, offset: CGPoint(x: 50, y: -8), label: "Q1"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 8), label: "Q2"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 24), label: "Q3")
            ]
            
        // MARK: - Сумматоры
        case "HALF_ADDER":
            // Полусумматор: A, B -> SUM, CARRY
            self.inputPins = [
                Pin(type: .input, offset: CGPoint(x: -50, y: -12), label: "A"),
                Pin(type: .input, offset: CGPoint(x: -50, y: 12), label: "B")
            ]
            self.outputPins = [
                Pin(type: .output, offset: CGPoint(x: 50, y: -12), label: "SUM"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 12), label: "C")
            ]
            
        case "FULL_ADDER":
            // Полный сумматор: A, B, Cin -> SUM, Cout
            self.inputPins = [
                Pin(type: .input, offset: CGPoint(x: -50, y: -18), label: "A"),
                Pin(type: .input, offset: CGPoint(x: -50, y: 0), label: "B"),
                Pin(type: .input, offset: CGPoint(x: -50, y: 18), label: "Cin")
            ]
            self.outputPins = [
                Pin(type: .output, offset: CGPoint(x: 50, y: -12), label: "SUM"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 12), label: "Cout")
            ]
            
        case "ADDER_4BIT":
            // 4-битный сумматор: A0-A3, B0-B3, Cin -> S0-S3, Cout
            self.inputPins = [
                Pin(type: .input, offset: CGPoint(x: -70, y: -40), label: "A0"),
                Pin(type: .input, offset: CGPoint(x: -70, y: -24), label: "A1"),
                Pin(type: .input, offset: CGPoint(x: -70, y: -8), label: "A2"),
                Pin(type: .input, offset: CGPoint(x: -70, y: 8), label: "A3"),
                Pin(type: .input, offset: CGPoint(x: -40, y: -40), label: "B0"),
                Pin(type: .input, offset: CGPoint(x: -40, y: -24), label: "B1"),
                Pin(type: .input, offset: CGPoint(x: -40, y: -8), label: "B2"),
                Pin(type: .input, offset: CGPoint(x: -40, y: 8), label: "B3"),
                Pin(type: .input, offset: CGPoint(x: 0, y: 42), label: "Cin")
            ]
            self.outputPins = [
                Pin(type: .output, offset: CGPoint(x: 50, y: -30), label: "S0"),
                Pin(type: .output, offset: CGPoint(x: 50, y: -10), label: "S1"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 10), label: "S2"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 30), label: "S3"),
                Pin(type: .output, offset: CGPoint(x: 70, y: -40), label: "Cout")
            ]
            
        // MARK: - Декодеры и энкодеры
        case "DECODER_2TO4":
            // Декодер 2:4 - 2 входа, 4 выхода
            self.inputPins = [
                Pin(type: .input, offset: CGPoint(x: -50, y: -12), label: "A0"),
                Pin(type: .input, offset: CGPoint(x: -50, y: 12), label: "A1")
            ]
            self.outputPins = [
                Pin(type: .output, offset: CGPoint(x: 50, y: -24), label: "Y0"),
                Pin(type: .output, offset: CGPoint(x: 50, y: -8), label: "Y1"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 8), label: "Y2"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 24), label: "Y3")
            ]
            
        case "DECODER_3TO8":
            // Декодер 3:8 - 3 входа, 8 выходов
            self.inputPins = [
                Pin(type: .input, offset: CGPoint(x: -50, y: -18), label: "A0"),
                Pin(type: .input, offset: CGPoint(x: -50, y: 0), label: "A1"),
                Pin(type: .input, offset: CGPoint(x: -50, y: 18), label: "A2")
            ]
            self.outputPins = [
                Pin(type: .output, offset: CGPoint(x: 50, y: -42), label: "Y0"),
                Pin(type: .output, offset: CGPoint(x: 50, y: -30), label: "Y1"),
                Pin(type: .output, offset: CGPoint(x: 50, y: -18), label: "Y2"),
                Pin(type: .output, offset: CGPoint(x: 50, y: -6), label: "Y3"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 6), label: "Y4"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 18), label: "Y5"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 30), label: "Y6"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 42), label: "Y7")
            ]
            
        case "ENCODER_4TO2":
            // Энкодер 4:2 - 4 входа, 2 выхода
            self.inputPins = [
                Pin(type: .input, offset: CGPoint(x: -50, y: -24), label: "D0"),
                Pin(type: .input, offset: CGPoint(x: -50, y: -8), label: "D1"),
                Pin(type: .input, offset: CGPoint(x: -50, y: 8), label: "D2"),
                Pin(type: .input, offset: CGPoint(x: -50, y: 24), label: "D3")
            ]
            self.outputPins = [
                Pin(type: .output, offset: CGPoint(x: 50, y: -12), label: "Y0"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 12), label: "Y1")
            ]
            
        // MARK: - Компараторы
        case "COMPARATOR_1BIT":
            // 1-битный компаратор: A, B -> A>B, A=B, A<B
            self.inputPins = [
                Pin(type: .input, offset: CGPoint(x: -50, y: -12), label: "A"),
                Pin(type: .input, offset: CGPoint(x: -50, y: 12), label: "B")
            ]
            self.outputPins = [
                Pin(type: .output, offset: CGPoint(x: 50, y: -18), label: "A>B"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 0), label: "A=B"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 18), label: "A<B")
            ]
            
        case "COMPARATOR_4BIT":
            // 4-битный компаратор: A0-A3, B0-B3 -> A>B, A=B, A<B
            self.inputPins = [
                Pin(type: .input, offset: CGPoint(x: -70, y: -30), label: "A0"),
                Pin(type: .input, offset: CGPoint(x: -70, y: -10), label: "A1"),
                Pin(type: .input, offset: CGPoint(x: -70, y: 10), label: "A2"),
                Pin(type: .input, offset: CGPoint(x: -70, y: 30), label: "A3"),
                Pin(type: .input, offset: CGPoint(x: -40, y: -30), label: "B0"),
                Pin(type: .input, offset: CGPoint(x: -40, y: -10), label: "B1"),
                Pin(type: .input, offset: CGPoint(x: -40, y: 10), label: "B2"),
                Pin(type: .input, offset: CGPoint(x: -40, y: 30), label: "B3")
            ]
            self.outputPins = [
                Pin(type: .output, offset: CGPoint(x: 50, y: -18), label: "A>B"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 0), label: "A=B"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 18), label: "A<B")
            ]
            
        // MARK: - Память
        case "RAM_4X4":
            // 4x4-битная RAM: 2 адресных входа, 4 входа данных, WE, 4 выхода данных
            self.inputPins = [
                Pin(type: .input, offset: CGPoint(x: -60, y: -36), label: "A0"),
                Pin(type: .input, offset: CGPoint(x: -60, y: -24), label: "A1"),
                Pin(type: .input, offset: CGPoint(x: -60, y: -6), label: "D0"),
                Pin(type: .input, offset: CGPoint(x: -60, y: 6), label: "D1"),
                Pin(type: .input, offset: CGPoint(x: -60, y: 18), label: "D2"),
                Pin(type: .input, offset: CGPoint(x: -60, y: 30), label: "D3"),
                Pin(type: .input, offset: CGPoint(x: 0, y: 42), label: "WE")
            ]
            self.outputPins = [
                Pin(type: .output, offset: CGPoint(x: 60, y: -12), label: "Q0"),
                Pin(type: .output, offset: CGPoint(x: 60, y: 0), label: "Q1"),
                Pin(type: .output, offset: CGPoint(x: 60, y: 12), label: "Q2"),
                Pin(type: .output, offset: CGPoint(x: 60, y: 24), label: "Q3")
            ]
            
        case "ROM_4X4":
            // 4x4-битная ROM: 2 адресных входа, 4 выхода данных
            self.inputPins = [
                Pin(type: .input, offset: CGPoint(x: -50, y: -12), label: "A0"),
                Pin(type: .input, offset: CGPoint(x: -50, y: 12), label: "A1")
            ]
            self.outputPins = [
                Pin(type: .output, offset: CGPoint(x: 50, y: -24), label: "D0"),
                Pin(type: .output, offset: CGPoint(x: 50, y: -8), label: "D1"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 8), label: "D2"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 24), label: "D3")
            ]
            
        // MARK: - Генератор тактов
        case "CLOCK":
            // Генератор тактовых импульсов
            self.inputPins = []
            self.outputPins = [Pin(type: .output, offset: CGPoint(x: 50, y: 0), label: "CLK")]
            
        // MARK: - Шины
        case "SPLITTER_4BIT":
            // Разветвитель 4-битной шины: 1 вход (4 бита) -> 4 выхода (по 1 биту)
            self.inputPins = [Pin(type: .input, offset: CGPoint(x: -50, y: 0), label: "IN")]
            self.outputPins = [
                Pin(type: .output, offset: CGPoint(x: 50, y: -24), label: "B0"),
                Pin(type: .output, offset: CGPoint(x: 50, y: -8), label: "B1"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 8), label: "B2"),
                Pin(type: .output, offset: CGPoint(x: 50, y: 24), label: "B3")
            ]
            
        case "COMBINER_4BIT":
            // Объединитель в 4-битную шину: 4 входа (по 1 биту) -> 1 выход (4 бита)
            self.inputPins = [
                Pin(type: .input, offset: CGPoint(x: -50, y: -24), label: "B0"),
                Pin(type: .input, offset: CGPoint(x: -50, y: -8), label: "B1"),
                Pin(type: .input, offset: CGPoint(x: -50, y: 8), label: "B2"),
                Pin(type: .input, offset: CGPoint(x: -50, y: 24), label: "B3")
            ]
            self.outputPins = [Pin(type: .output, offset: CGPoint(x: 50, y: 0), label: "OUT")]
            
        default:
            // Для логических элементов - стандартное расположение
            self.inputPins = (0..<inputCount).map { i in Pin(type: .input, offset: CGPoint(x: -50, y: CGFloat(i * 24 - (inputCount-1)*12))) }
            self.outputPins = (0..<outputCount).map { i in Pin(type: .output, offset: CGPoint(x: 50, y: CGFloat(i * 24 - (outputCount-1)*12))) }
        }
    }

    // Custom Codable so older payloads with `name` still decode sensibly.
    enum CodingKeys: String, CodingKey {
        case id, baseName, userSuffix, position, inputPins, outputPins, name, description, isIndicatorActive, displayValue, componentValue
        case internalState, previousClock, memoryData, memoryAddress, clockFrequency, clockState
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        if let base = try? container.decode(String.self, forKey: .baseName) {
            baseName = base
        } else if let old = try? container.decode(String.self, forKey: .name) {
            baseName = old
        } else {
            baseName = "GATE"
        }
    userSuffix = try? container.decode(String?.self, forKey: .userSuffix) ?? nil
    description = try container.decodeIfPresent(String?.self, forKey: .description) ?? nil
    componentValue = try container.decodeIfPresent(String?.self, forKey: .componentValue) ?? nil
    position = try container.decodeIfPresent(CGPoint.self, forKey: .position) ?? .zero
        inputPins = try container.decodeIfPresent([Pin].self, forKey: .inputPins) ?? []
        outputPins = try container.decodeIfPresent([Pin].self, forKey: .outputPins) ?? []
        isIndicatorActive = try container.decodeIfPresent(Bool.self, forKey: .isIndicatorActive) ?? false
        displayValue = try container.decodeIfPresent(Int.self, forKey: .displayValue) ?? 0
        internalState = try container.decodeIfPresent(Bool.self, forKey: .internalState) ?? false
        previousClock = try container.decodeIfPresent(Bool.self, forKey: .previousClock) ?? false
        memoryData = try container.decodeIfPresent([UInt8].self, forKey: .memoryData) ?? []
        memoryAddress = try container.decodeIfPresent(Int.self, forKey: .memoryAddress) ?? 0
        clockFrequency = try container.decodeIfPresent(Double.self, forKey: .clockFrequency) ?? 1.0
        clockState = try container.decodeIfPresent(Bool.self, forKey: .clockState) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(baseName, forKey: .baseName)
        try container.encodeIfPresent(userSuffix, forKey: .userSuffix)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(componentValue, forKey: .componentValue)
        try container.encode(position, forKey: .position)
        try container.encode(inputPins, forKey: .inputPins)
        try container.encode(outputPins, forKey: .outputPins)
        try container.encode(isIndicatorActive, forKey: .isIndicatorActive)
        try container.encode(displayValue, forKey: .displayValue)
        try container.encode(internalState, forKey: .internalState)
        try container.encode(previousClock, forKey: .previousClock)
        try container.encode(memoryData, forKey: .memoryData)
        try container.encode(memoryAddress, forKey: .memoryAddress)
        try container.encode(clockFrequency, forKey: .clockFrequency)
        try container.encode(clockState, forKey: .clockState)
    }
}
