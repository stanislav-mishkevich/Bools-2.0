import SwiftUI

struct GateView: View {
    @ObservedObject var vm: WorkspaceViewModel
    var gate: Gate
    @Environment(\.colorScheme) var colorScheme

    @State private var dragOffset: CGSize = .zero
    @State private var initialPosition: CGPoint? = nil
    @State private var initialZoom: CGFloat? = nil
    @State private var wireStartZoom: CGFloat? = nil

    static let size = CGSize(width: 120, height: 64)
    
    // Динамический размер в зависимости от типа компонента
    private var componentSize: CGSize {
        if gate.baseName == "DISPLAY8BIT" {
            return CGSize(width: 160, height: 160)
        }
        return Self.size
    }
    
    private var isSelected: Bool {
        vm.selectedGateIDs.contains(gate.id)
    }

    var body: some View {
        ZStack(alignment: .center) {
            // Используем разный вид для физических компонентов
            if isPhysicalComponent(gate.baseName) {
                physicalComponentView
            } else {
                logicGateView
            }
        }
        .frame(width: componentSize.width, height: componentSize.height)
        .position(gate.position)
        .gesture(dragGesture)
        .contextMenu { contextMenuContent }
        .onTapGesture { onTapAction() }
    }
    
    // MARK: - Логический элемент (стандартный вид)
    private var logicGateView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(colorScheme == .dark ? Color(white: 0.2) : Color(white: 0.95))
            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
            .frame(width: Self.size.width, height: Self.size.height)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Color.blue : Color.clear, lineWidth: 3)
            )
            .overlay(
                VStack(spacing: 4) {
                    Text(gate.displayName)
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    HStack(spacing: 8) {
                            // display output for normal gates, but for OUTPUT gate show its input value
                            let displayed = gate.baseName == "OUTPUT" ? (gate.inputPins.first?.value ?? false) : (gate.outputPins.first?.value ?? false)
                            Text(displayed ? "1" : "0")
                                .font(.caption)
                                .foregroundStyle(displayed ? .green : .secondary)
                                .frame(minWidth: 12)
                        if gate.baseName == "INPUT" {
                            if let idx = vm.gates.firstIndex(where: { $0.id == gate.id }) {
                                Toggle(isOn: Binding(get: {
                                    vm.gates[idx].outputPins.first?.value ?? false
                                }, set: { newVal in
                                    vm.gates[idx].outputPins[0].value = newVal
                                    vm.simulate()
                                })) {
                                    EmptyView()
                                }
                                .labelsHidden()
                                .toggleStyle(.switch)
                                .frame(width: 44)
                                .help("Toggle input value")
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            )
            .overlay(pinsOverlay)
    }
    
    // MARK: - Физический компонент (реалистичный вид)
    private var physicalComponentView: some View {
        ZStack {
            // Современный фон с легкой тенью
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(white: 0.18) : Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                .frame(width: Self.size.width, height: Self.size.height)
            
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(isSelected ? Color.blue : Color.clear, lineWidth: 2.5)
                .frame(width: Self.size.width, height: Self.size.height)
            
            physicalComponentContent
        }
        .overlay(pinsOverlay)
    }
    
    @ViewBuilder
    private var physicalComponentContent: some View {
        let outputValue = gate.outputPins.first?.value ?? false
        let isIndicatorActive = gate.isIndicatorActive
        
        switch gate.baseName {
        case "BUTTON":
            buttonView(pressed: outputValue)
        case "SWITCH":
            switchView(isOn: outputValue)
        case "BATTERY":
            batteryView
        case "LED":
            ledView(isOn: isIndicatorActive)
        case "BULB":
            bulbView(isOn: isIndicatorActive)
        case "RELAY":
            relayView(isOn: outputValue)
        case "BUZZER":
            buzzerView(isOn: isIndicatorActive)
        case "DISPLAY8BIT":
            display8BitView
        default:
            EmptyView()
        }
    }
    
    // MARK: - Компоненты визуализации
    private func buttonView(pressed: Bool) -> some View {
        VStack(spacing: 4) {
            Text(gate.displayName)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.secondary)
            
            Button(action: {
                if let idx = vm.gates.firstIndex(where: { $0.id == gate.id }) {
                    // При нажатии передаём входное значение на выход
                    let inputValue = vm.gates[idx].inputPins.first?.value ?? false
                    vm.gates[idx].outputPins[0].value = inputValue
                    vm.simulate()
                }
            }) {
                ZStack {
                    // Современная кнопка с металлическим эффектом
                    Circle()
                        .fill(pressed ? 
                            LinearGradient(
                                colors: [Color.red.opacity(0.95), Color.red.opacity(0.75), Color.red.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.gray.opacity(0.35), Color.gray.opacity(0.25), Color.gray.opacity(0.18)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.2), Color.clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: Color.black.opacity(pressed ? 0.2 : 0.15), radius: pressed ? 2 : 4, y: pressed ? 1 : 2)
                        .scaleEffect(pressed ? 0.94 : 1.0)
                    
                    // Иконка с неоновым эффектом
                    Image(systemName: pressed ? "bolt.fill" : "bolt.slash.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(pressed ? 
                            LinearGradient(colors: [Color.white, Color.yellow.opacity(0.9)], startPoint: .top, endPoint: .bottom) :
                            LinearGradient(colors: [Color.gray.opacity(0.6), Color.gray.opacity(0.4)], startPoint: .top, endPoint: .bottom)
                        )
                        .shadow(color: pressed ? Color.yellow.opacity(0.8) : Color.clear, radius: 6)
                    
                    // Индикатор состояния
                    if pressed {
                        Circle()
                            .stroke(Color.yellow.opacity(0.5), lineWidth: 2)
                            .frame(width: 48, height: 48)
                            .blur(radius: 2)
                    }
                }
            }
            .buttonStyle(.plain)
            
            // Метка состояния
            Text(pressed ? "CLOSED" : "OPEN")
                .font(.system(size: 7, weight: .bold, design: .rounded))
                .foregroundStyle(pressed ? Color.green : Color.red.opacity(0.7))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.black.opacity(0.2))
                )
        }
    }
    
    private func switchView(isOn: Bool) -> some View {
        VStack(spacing: 6) {
            Text(gate.displayName)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.secondary)
            
            ZStack {
                // Корпус переключателя
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color(white: 0.25), Color(white: 0.18)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 52, height: 28)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black.opacity(0.3), lineWidth: 1.5)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 3, y: 2)
                
                // Индикатор фона
                RoundedRectangle(cornerRadius: 14)
                    .fill(isOn ? 
                        LinearGradient(colors: [Color.green.opacity(0.7), Color.green.opacity(0.5)], startPoint: .leading, endPoint: .trailing) :
                        LinearGradient(colors: [Color.black.opacity(0.3)], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: 48, height: 24)
                
                // Переключатель
                if let idx = vm.gates.firstIndex(where: { $0.id == gate.id }) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white, Color.gray.opacity(0.9)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 22, height: 22)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.3), radius: 2, y: 1)
                        .offset(x: isOn ? 12 : -12)
                        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isOn)
                        .onTapGesture {
                            vm.gates[idx].outputPins[0].value.toggle()
                            vm.simulate()
                        }
                }
            }
            
            // Метка состояния
            Text(isOn ? "CLOSED" : "OPEN")
                .font(.system(size: 7, weight: .bold, design: .rounded))
                .foregroundStyle(isOn ? Color.green : Color.red.opacity(0.7))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.black.opacity(0.2))
                )
        }
    }
    
//    private func ledView(isOn: Bool) -> some View {
//        VStack(spacing: 6) {
//            Text(gate.displayName)
//                .font(.system(size: 10, weight: .semibold))
//                .foregroundStyle(.secondary)
//            
//            ZStack {
//                // Современный светодиод
//                Circle()
//                    .fill(isOn ? 
//                        RadialGradient(colors: [Color.green.opacity(0.9), Color.green.opacity(0.6)], center: .center, startRadius: 5, endRadius: 18) :
//                        RadialGradient(colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.2)], center: .center, startRadius: 5, endRadius: 18)
//                    )
//                    .frame(width: 32, height: 32)
//                    .overlay(
//                        Circle()
//                            .stroke(Color.black.opacity(0.1), lineWidth: 1)
//                    )
//                
//                // Свечение
//                if isOn {
//                    Circle()
//                        .fill(
//                            RadialGradient(
//                                colors: [Color.green.opacity(0.4), Color.green.opacity(0.1), Color.clear],
//                                center: .center,
//                                startRadius: 10,
//                                endRadius: 25
//                            )
//                        )
//                        .frame(width: 48, height: 48)
//                        .blur(radius: 4)
//                }
//            }
//        }
//    }
    
    //    
    private func ledView(isOn: Bool) -> some View {
        VStack(spacing: 6) {
            Text(gate.displayName)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)
            
            ZStack {
                // Современный светодиод
                Circle()
                    .fill(isOn ? 
                        RadialGradient(colors: [Color.green.opacity(0.9), Color.green.opacity(0.6)], center: .center, startRadius: 5, endRadius: 18) :
                        RadialGradient(colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.2)], center: .center, startRadius: 5, endRadius: 18)
                    )
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.1), lineWidth: 1)
                    )
                
                // Свечение
                if isOn {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.green.opacity(0.4), Color.green.opacity(0.1), Color.clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: 25
                            )
                        )
                        .frame(width: 48, height: 48)
                        .blur(radius: 4)
                }
            }
        }
    }
    
    private func bulbView(isOn: Bool) -> some View {
        VStack(spacing: 6) {
            Text(gate.displayName)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)
            
            ZStack {
                // Современная лампа
                Circle()
                    .fill(isOn ?
                        RadialGradient(colors: [Color.yellow.opacity(0.95), Color.orange.opacity(0.8)], center: .center, startRadius: 8, endRadius: 18) :
                        RadialGradient(colors: [Color.gray.opacity(0.15), Color.gray.opacity(0.15)], center: .center, startRadius: 8, endRadius: 18)
                    )
                    .frame(width: 34, height: 34)
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
                
                // Свечение
                if isOn {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.yellow.opacity(0.5), Color.orange.opacity(0.2), Color.clear],
                                center: .center,
                                startRadius: 12,
                                endRadius: 30
                            )
                        )
                        .frame(width: 54, height: 54)
                        .blur(radius: 6)
                }
            }
        }
    }
    
    private func relayView(isOn: Bool) -> some View {
        VStack(spacing: 4) {
            Text(gate.displayName)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)
            
            ZStack {
                // Корпус реле
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [Color(white: 0.28), Color(white: 0.22)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 50, height: 36)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.08), radius: 3, y: 2)
                
                HStack(spacing: 8) {
                    // Катушка (слева)
                    VStack(spacing: 2) {
                        // Символ катушки
                        ZStack {
                            Rectangle()
                                .fill(isOn ? Color.red : Color.gray.opacity(0.5))
                                .frame(width: 8, height: 16)
                                .cornerRadius(2)
                            
                            // Обмотка
                            VStack(spacing: 0.5) {
                                ForEach(0..<4) { _ in
                                    Rectangle()
                                        .fill(Color.black.opacity(0.3))
                                        .frame(width: 6, height: 1)
                                }
                            }
                        }
                    }
                    
                    // Контакты (справа) - схематичное отображение переключения
                    VStack(spacing: 3) {
                        // NC контакт (вверху) - замкнут когда реле неактивно
                        HStack(spacing: 1) {
                            Circle()
                                .fill(!isOn ? Color.green : Color.gray.opacity(0.3))
                                .frame(width: 3, height: 3)
                            Rectangle()
                                .fill(!isOn ? Color.green : Color.gray.opacity(0.3))
                                .frame(width: 4, height: 1)
                        }
                        
                        // COM контакт (середина) - общий
                        Circle()
                            .fill(isOn ? Color.orange : Color.blue.opacity(0.5))
                            .frame(width: 4, height: 4)
                        
                        // NO контакт (внизу) - замкнут когда реле активно
                        HStack(spacing: 1) {
                            Circle()
                                .fill(isOn ? Color.green : Color.gray.opacity(0.3))
                                .frame(width: 3, height: 3)
                            Rectangle()
                                .fill(isOn ? Color.green : Color.gray.opacity(0.3))
                                .frame(width: 4, height: 1)
                        }
                    }
                }
                
                // Индикатор состояния катушки
                Circle()
                    .fill(isOn ? Color.red : Color.gray.opacity(0.3))
                    .frame(width: 5, height: 5)
                    .offset(x: -18, y: -12)
            }
        }
    }
    
    private var display8BitView: some View {
        VStack(spacing: 4) {
            Text(gate.displayName)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.secondary)
            
            ZStack {
                // Корпус дисплея
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.12, green: 0.12, blue: 0.14))
                    .frame(width: 160, height: 140)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 8, y: 3)
                
                VStack(spacing: 8) {
                    // Шапка с индикатором
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "cpu.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(.cyan.opacity(0.7))
                            Text("8-BIT DISPLAY")
                                .font(.system(size: 8, weight: .semibold, design: .rounded))
                                .foregroundStyle(.cyan.opacity(0.6))
                        }
                        
                        Spacer()
                        
                        Circle()
                            .fill(isPowerOn ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 6, height: 6)
                            .shadow(color: isPowerOn ? .green : .clear, radius: 3)
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 10)
                    
                    // Экран дисплея
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.9))
                            .frame(height: 100)
                        
                        VStack(spacing: 10) {
                            // Десятичное значение
                            HStack {
                                Text("DEC")
                                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                                    .foregroundStyle(.orange.opacity(0.6))
                                
                                Spacer()
                                
                                Text(isPowerOn ? "\(gate.displayValue)" : "---")
                                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                                    .foregroundStyle(isPowerOn ? .orange : .orange.opacity(0.2))
                                    .shadow(color: isPowerOn ? .orange.opacity(0.5) : .clear, radius: 4)
                                    .frame(minWidth: 60, alignment: .trailing)
                            }
                            .padding(.horizontal, 12)
                            .padding(.top, 8)
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.horizontal, 8)
                            
                            // Двоичное представление
                            VStack(spacing: 6) {
                                // Метки битов
                                HStack(spacing: 2) {
                                    ForEach(0..<8) { i in
                                        Text("B\(7-i)")
                                            .font(.system(size: 7, weight: .medium, design: .monospaced))
                                            .foregroundStyle(.cyan.opacity(isPowerOn ? 0.5 : 0.2))
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                
                                // Биты
                                HStack(spacing: 2) {
                                    ForEach(0..<8) { i in
                                        let bitIndex = 7 - i
                                        let bitValue = (gate.displayValue >> bitIndex) & 1
                                        let isOn = bitValue == 1 && isPowerOn
                                        
                                        Text("\(bitValue)")
                                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                                            .foregroundStyle(isOn ? .cyan : .cyan.opacity(0.2))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 4)
                                            .background(
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(isOn ? Color.cyan.opacity(0.15) : Color.clear)
                                            )
                                            .shadow(color: isOn ? .cyan.opacity(0.4) : .clear, radius: 3)
                                    }
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.bottom, 8)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                }
            }
        }
        .frame(width: 160, height: 155)
    }
    
    // Вычисляемое свойство для проверки питания дисплея
    private var isPowerOn: Bool {
        // Пины: B7(0), B6(1), B5(2), B4(3), B3(4), B2(5), B1(6), B0(7), +(8), -(9)
        guard gate.inputPins.count >= 10 else { return false }
        return gate.inputPins[8].value && !gate.inputPins[9].value
    }
    
    // MARK: - Seven Segment Display Digit
    struct SevenSegmentDigit: View {
        let digit: Int
        let isActive: Bool
        
        var body: some View {
            ZStack {
                // Фон для цифры
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.black.opacity(0.3))
                    .frame(width: 32, height: 42)
                
                // Сегменты
                SevenSegmentView(number: digit, isOn: isActive)
                    .frame(width: 28, height: 38)
            }
        }
    }
    
    struct SevenSegmentView: View {
        let number: Int
        let isOn: Bool
        
        // Определяем какие сегменты горят для каждой цифры
        // Порядок: top, topRight, bottomRight, bottom, bottomLeft, topLeft, middle
        private let segmentPatterns: [[Bool]] = [
            [true, true, true, true, true, true, false],     // 0
            [false, true, true, false, false, false, false], // 1
            [true, true, false, true, true, false, true],    // 2
            [true, true, true, true, false, false, true],    // 3
            [false, true, true, false, false, true, true],   // 4
            [true, false, true, true, false, true, true],    // 5
            [true, false, true, true, true, true, true],     // 6
            [true, true, true, false, false, false, false],  // 7
            [true, true, true, true, true, true, true],      // 8
            [true, true, true, true, false, true, true]      // 9
        ]
        
        var body: some View {
            let pattern = number >= 0 && number <= 9 ? segmentPatterns[number] : [false, false, false, false, false, false, false]
            
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let segW = w * 0.8
                let segH = h * 0.08
                let vertSegH = h * 0.38
                
                ZStack {
                    // Top segment
                    Segment(isOn: pattern[0] && isOn)
                        .frame(width: segW, height: segH)
                        .position(x: w/2, y: segH/2 + 2)
                    
                    // Top-right segment
                    Segment(isOn: pattern[1] && isOn)
                        .frame(width: segH, height: vertSegH)
                        .position(x: w - segH/2 - 2, y: h * 0.27)
                    
                    // Bottom-right segment
                    Segment(isOn: pattern[2] && isOn)
                        .frame(width: segH, height: vertSegH)
                        .position(x: w - segH/2 - 2, y: h * 0.73)
                    
                    // Bottom segment
                    Segment(isOn: pattern[3] && isOn)
                        .frame(width: segW, height: segH)
                        .position(x: w/2, y: h - segH/2 - 2)
                    
                    // Bottom-left segment
                    Segment(isOn: pattern[4] && isOn)
                        .frame(width: segH, height: vertSegH)
                        .position(x: segH/2 + 2, y: h * 0.73)
                    
                    // Top-left segment
                    Segment(isOn: pattern[5] && isOn)
                        .frame(width: segH, height: vertSegH)
                        .position(x: segH/2 + 2, y: h * 0.27)
                    
                    // Middle segment
                    Segment(isOn: pattern[6] && isOn)
                        .frame(width: segW, height: segH)
                        .position(x: w/2, y: h/2)
                }
            }
        }
    }
    
    struct Segment: View {
        let isOn: Bool
        
        var body: some View {
            RoundedRectangle(cornerRadius: 1.5)
                .fill(isOn ? 
                    Color(red: 0.0, green: 0.95, blue: 0.2) :
                    Color(red: 0.0, green: 0.12, blue: 0.03)
                )
                .shadow(
                    color: isOn ? Color.green.opacity(0.8) : Color.clear,
                    radius: isOn ? 4 : 0
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(
                            LinearGradient(
                                colors: isOn ? 
                                    [Color.white.opacity(0.3), Color.clear] :
                                    [Color.clear, Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
        }
    }
    
    private func buzzerView(isOn: Bool) -> some View {
        VStack(spacing: 6) {
            Text(gate.displayName)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)
            
            ZStack {
                // Корпус динамика
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(white: 0.25), Color(white: 0.18)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 36, height: 36)
                
                // Мембрана
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(white: 0.15), Color(white: 0.22)],
                            center: .center,
                            startRadius: 5,
                            endRadius: 14
                        )
                    )
                    .frame(width: 28, height: 28)
                
                // Концентрические круги
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(Color.black.opacity(0.25), lineWidth: 0.5)
                        .frame(width: CGFloat(10 + i * 6), height: CGFloat(10 + i * 6))
                }
                
                // Визуализация звука
                if isOn {
                    ForEach(0..<2) { i in
                        Circle()
                            .stroke(Color.orange.opacity(0.5 - Double(i) * 0.2), lineWidth: 2)
                            .frame(width: CGFloat(36 + i * 8), height: CGFloat(36 + i * 8))
                    }
                }
            }
            .shadow(color: Color.black.opacity(0.08), radius: 3, y: 2)
        }
    }
    
    private var batteryView: some View {
        VStack(spacing: 6) {
            Text(gate.displayName)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)
            
            ZStack {
                // Корпус батареи (AA батарея)
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.2, green: 0.22, blue: 0.25),
                                Color(red: 0.15, green: 0.17, blue: 0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 18, height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.black.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 3, y: 2)
                
                // Положительный контакт (верх)
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.8, green: 0.7, blue: 0.5), Color(red: 0.6, green: 0.5, blue: 0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 8, height: 4)
                    .cornerRadius(1)
                    .offset(y: -22)
                
                // Этикетка на батарее
                VStack(spacing: 1) {
                    // Полоса маркировки
                    Rectangle()
                        .fill(Color.red.opacity(0.8))
                        .frame(width: 14, height: 6)
                        .cornerRadius(1)
                    
                    // Символ +
                    Text("+")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Вольтаж
                    Text("5V")
                        .font(.system(size: 6, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.8))
                }
                .offset(y: -2)
                
                // Отрицательный контакт (низ) - плоский
                Rectangle()
                    .fill(Color(white: 0.3))
                    .frame(width: 18, height: 2)
                    .offset(y: 20)
                
                // Индикаторы выходов + и -
                VStack(spacing: 18) {
                    // Индикатор + (верхний выход, всегда активен)
                    Circle()
                        .fill(Color.green)
                        .frame(width: 4, height: 4)
                        .shadow(color: Color.green, radius: 3)
                    
                    // Индикатор - (нижний выход, всегда неактивен)
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 4, height: 4)
                }
                .offset(x: 12, y: 0)
            }
        }
    }

    private func resistorView() -> some View {
        VStack(spacing: 6) {
            Text(gate.displayName)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)
            
            ZStack {
                // Корпус резистора
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.85, green: 0.75, blue: 0.6), Color(red: 0.75, green: 0.65, blue: 0.5)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 38, height: 12)
                    .shadow(color: Color.black.opacity(0.08), radius: 2, y: 1)
                
                // Цветовые полосы (example: коричневый-чёрный-красный = 1kΩ)
                HStack(spacing: 4) {
                    Rectangle()
                        .fill(Color(red: 0.55, green: 0.27, blue: 0.07))
                        .frame(width: 2.5, height: 12)
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: 2.5, height: 12)
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 2.5, height: 12)
                }
                .offset(x: -8)
            }
        }
    }
    
    private func capacitorView() -> some View {
        VStack(spacing: 6) {
            Text(gate.displayName)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)
            
            ZStack {
                // Электролитический конденсатор (цилиндр)
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.2, green: 0.3, blue: 0.5), Color(red: 0.15, green: 0.25, blue: 0.4)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 18, height: 32)
                    .shadow(color: Color.black.opacity(0.08), radius: 2, y: 1)
                
                // Полоса маркировки
                Rectangle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 8, height: 32)
                    .offset(x: -5)
                
                // Маркировка полярности
                Text("−")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black)
                    .offset(x: -5)
            }
        }
    }
    
    private var electrolyticCapacitorView: some View {
        VStack(spacing: 2) {
            Text(gate.displayName)
                .font(.system(size: 9, weight: .medium))
            
            ZStack {
                // Корпус электролитического конденсатора
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.3, green: 0.4, blue: 0.6), Color(red: 0.25, green: 0.35, blue: 0.55)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 28, height: 38)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color.black.opacity(0.3), lineWidth: 1)
                    )
                
                // Маркировка полярности
                VStack(spacing: 8) {
                    // Знак минус
                    HStack(spacing: 2) {
                        Rectangle()
                            .fill(Color.white.opacity(0.8))
                            .frame(width: 8, height: 1.5)
                    }
                    .offset(y: -8)
                    
                    // Полоска индикатора
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 22, height: 38)
                        .offset(x: -3)
                }
                
                // Надпись емкости
                Text("100μF")
                    .font(.system(size: 6, weight: .bold))
                    .foregroundColor(.white)
                    .offset(y: 6)
                
                // Выводы (анод и катод)
                HStack(spacing: 16) {
                    VStack(spacing: 0) {
                        Text("+")
                            .font(.system(size: 5, weight: .bold))
                            .foregroundColor(.white)
                        Rectangle()
                            .fill(Color(red: 0.8, green: 0.7, blue: 0.4))
                            .frame(width: 2.5, height: 10)
                    }
                    VStack(spacing: 0) {
                        Text("−")
                            .font(.system(size: 5, weight: .bold))
                            .foregroundColor(.white)
                        Rectangle()
                            .fill(Color(red: 0.8, green: 0.7, blue: 0.4))
                            .frame(width: 2.5, height: 10)
                    }
                }
            }
            .offset(y: 24)
         }
     }
    
    // MARK: - Pins Overlay
    private var pinsOverlay: some View {
        ZStack {

            // Пины для входов
            ForEach(Array(gate.inputPins.enumerated()), id: \ .element.id) { idx, pin in
                ZStack {
                    Circle()
                        .fill((vm.hoveredPin?.gateID == gate.id && vm.hoveredPin?.pinIndex == idx && vm.hoveredPin?.type == .input) ? Color.yellow : (pin.value ? Color.green : Color.gray))
                        .frame(width: vm.hoveredPin?.gateID == gate.id && vm.hoveredPin?.pinIndex == idx ? 16 : 12, height: vm.hoveredPin?.gateID == gate.id && vm.hoveredPin?.pinIndex == idx ? 16 : 12)
                    
                    // Метка пина (полярность или тип)
                    if let label = pin.label {
                        Text(label)
                            .font(.system(size: 7, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 0)
                            .offset(x: -15, y: 0)  // Слева от пина
                    }
                }
                .offset(x: pin.offset.x, y: pin.offset.y)
                .alignmentGuide(.leading) { _ in 0 }
                .onHover { inside in
                    if inside { vm.hoveredPin = (gate.id, idx, .input) } else if vm.hoveredPin?.gateID == gate.id && vm.hoveredPin?.pinIndex == idx && vm.hoveredPin?.type == .input { vm.hoveredPin = nil }
                }
                    .simultaneousGesture(DragGesture(minimumDistance: 8)
                        .onChanged { value in
                            // start connection on drag
                            if vm.tempConnectionStart == nil {
                                vm.beginConnection(fromGate: gate.id, fromPinIndex: idx, type: .input)
                                wireStartZoom = vm.zoom
                            }
                            // update connection current point using translation from start, adjust for zoom
                            if let start = vm.pinWorldPosition(gateID: gate.id, pinIndex: idx, type: .input) {
                                let currentZoom = wireStartZoom ?? vm.zoom
                                let dx = value.translation.width / max(currentZoom, 0.0001)
                                let dy = value.translation.height / max(currentZoom, 0.0001)
                                let worldPoint = CGPoint(x: start.x + dx, y: start.y + dy)
                                vm.updateConnectionPoint(to: worldPoint)
                            }
                        }
                        .onEnded { _ in
                            // if hoveredPin is over another pin, attempt to finish
                            if let hovered = vm.hoveredPin {
                                vm.finishConnectionIfPossible(toGate: hovered.gateID, toPinIndex: hovered.pinIndex, toType: hovered.type)
                            } else {
                                vm.cancelConnection()
                            }
                            wireStartZoom = nil
                        }
                    )
                    .onTapGesture(count: 2) {
                        // double click pin: remove wire(s) using prioritized logic
                        vm.removeWireOnDoubleClick(gateID: gate.id, pinIndex: idx, type: .input)
                    }
            }

            // output pins on the right (render using local offsets)
            ForEach(Array(gate.outputPins.enumerated()), id: \ .element.id) { idx, pin in
                ZStack {
                    Circle()
                        .fill((vm.hoveredPin?.gateID == gate.id && vm.hoveredPin?.pinIndex == idx && vm.hoveredPin?.type == .output) ? Color.yellow : (pin.value ? Color.green : Color.gray))
                        .frame(width: vm.hoveredPin?.gateID == gate.id && vm.hoveredPin?.pinIndex == idx ? 16 : 12, height: vm.hoveredPin?.gateID == gate.id && vm.hoveredPin?.pinIndex == idx ? 16 : 12)
                    
                    // Метка пина (полярность или тип)
                    if let label = pin.label {
                        Text(label)
                            .font(.system(size: 7, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 0)
                            .offset(x: 15, y: 0)  // Справа от пина
                    }
                }
                .offset(x: pin.offset.x, y: pin.offset.y)
                .onHover { inside in
                    if inside { vm.hoveredPin = (gate.id, idx, .output) } else if vm.hoveredPin?.gateID == gate.id && vm.hoveredPin?.pinIndex == idx && vm.hoveredPin?.type == .output { vm.hoveredPin = nil }
                }
                    .simultaneousGesture(DragGesture(minimumDistance: 8)
                        .onChanged { value in
                            if vm.tempConnectionStart == nil {
                                vm.beginConnection(fromGate: gate.id, fromPinIndex: idx, type: .output)
                                wireStartZoom = vm.zoom
                            }
                            if let start = vm.pinWorldPosition(gateID: gate.id, pinIndex: idx, type: .output) {
                                let currentZoom = wireStartZoom ?? vm.zoom
                                let dx = value.translation.width / max(currentZoom, 0.0001)
                                let dy = value.translation.height / max(currentZoom, 0.0001)
                                let worldPoint = CGPoint(x: start.x + dx, y: start.y + dy)
                                vm.updateConnectionPoint(to: worldPoint)
                            }
                        }
                        .onEnded { _ in
                            if let hovered = vm.hoveredPin {
                                vm.finishConnectionIfPossible(toGate: hovered.gateID, toPinIndex: hovered.pinIndex, toType: hovered.type)
                            } else {
                                vm.cancelConnection()
                            }
                            wireStartZoom = nil
                        }
                    )
                    .onTapGesture(count: 2) {
                        vm.removeWireOnDoubleClick(gateID: gate.id, pinIndex: idx, type: .output)
                    }
            }
        }
        .gesture(dragGesture)
    }
    
    // MARK: - Helper Methods
    private func isPhysicalComponent(_ name: String) -> Bool {
        ["BUTTON", "SWITCH", "BATTERY", "LED", "BULB", "RELAY", "BUZZER", "RESISTOR", "CAPACITOR", "DISPLAY8BIT"].contains(name)
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                // Убираем фокус при начале перетаскивания
                #if os(macOS)
                if initialPosition == nil {
                        DispatchQueue.main.async {
                            NSApp.keyWindow?.makeFirstResponder(nil)
                        }
                    }
                #endif
                    
                    // Save initial position and zoom at the start of drag
                    if initialPosition == nil { 
                        initialPosition = gate.position 
                        initialZoom = vm.zoom
                    }
                    // Use the initial zoom value for consistent coordinate conversion
                    // This prevents gates from "running away" when zoom changes during drag
                    let currentZoom = initialZoom ?? vm.zoom
                    let worldDelta = CGSize(
                        width: value.translation.width / max(currentZoom, 0.0001),
                        height: value.translation.height / max(currentZoom, 0.0001)
                    )
                    if let base = initialPosition {
                        let newPos = CGPoint(
                            x: base.x + worldDelta.width, 
                            y: base.y + worldDelta.height
                        )
                        vm.setGatePosition(id: gate.id, to: newPos)
                    }
                }
            .onEnded { _ in 
                dragOffset = .zero
                initialPosition = nil
                initialZoom = nil
                vm.simulate() 
            }
}

    @ViewBuilder
    private var contextMenuContent: some View {
        Button("Delete") {
            if let idx = vm.gates.firstIndex(where: { $0.id == gate.id }) { vm.gates.remove(at: idx) }
        }
        if gate.baseName == "INPUT" || gate.baseName == "BUTTON" || gate.baseName == "SWITCH" {
            Button("Toggle") { vm.toggleInputGate(id: gate.id) }
        }
    }
    
    private func onTapAction() {
        // Убираем фокус с текстовых полей при клике на гейт
        #if os(macOS)
        DispatchQueue.main.async {
            NSApp.keyWindow?.makeFirstResponder(nil)
        }
        #endif
        vm.selectGate(gate.id, multi: false)
    }
}

// MARK: - String Extension for Binary Display
extension String {
    func padded(toLength length: Int, withPad character: String, startingAt index: Int) -> String {
        guard self.count < length else { return self }
        let padding = String(repeating: character, count: length - self.count)
        return padding + self
    }
}
