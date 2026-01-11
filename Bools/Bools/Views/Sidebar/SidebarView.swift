import SwiftUI

struct SidebarView: View {
    @ObservedObject var vm: WorkspaceViewModel
    @State private var hoveredName: String? = nil
    @State private var searchText: String = ""
    var isCompact: Bool = false

    let ioGates: [String] = ["INPUT", "OUTPUT"]
    let basicGates: [String] = ["AND", "OR", "NOT", "NOT_B"]
    let advancedGates: [String] = ["XOR", "XNOR", "NAND", "NOR"]
    let specialGates: [String] = ["A_AND_NOT_B", "NOT_A_AND_B", "IMPL_AB", "IMPL_BA"]
    let projectionGates: [String] = ["PROJ_A", "PROJ_B"]
    let constantGates: [String] = ["CONST0", "CONST1"]
    let flipFlops: [String] = ["D_FLIPFLOP", "T_FLIPFLOP", "JK_FLIPFLOP", "SR_LATCH"]
    let multiplexers: [String] = ["MUX_2TO1", "MUX_4TO1", "DEMUX_1TO2", "DEMUX_1TO4"]
    let countersRegisters: [String] = ["COUNTER_4BIT", "REGISTER_4BIT"]
    let adders: [String] = ["HALF_ADDER", "FULL_ADDER", "ADDER_4BIT"]
    let decodersEncoders: [String] = ["DECODER_2TO4", "DECODER_3TO8", "ENCODER_4TO2"]
    let comparators: [String] = ["COMPARATOR_1BIT", "COMPARATOR_4BIT"]
    let memory: [String] = ["RAM_4X4", "ROM_4X4"]
    let timing: [String] = ["CLOCK"]
    let busComponents: [String] = ["SPLITTER_4BIT", "COMBINER_4BIT"]
    let physicalComponents: [String] = ["BUTTON", "SWITCH", "LED", "BULB", "RELAY", "BUZZER", "RESISTOR", "CAPACITOR", "BATTERY", "DISPLAY8BIT"]
    let transistors: [String] = ["BJT_NPN", "BJT_PNP", "MOSFET_N", "MOSFET_P"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: isCompact ? 12 : 16) {
                // Header
                if !isCompact {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(NSLocalizedString("sidebar.title", comment: ""))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(NSLocalizedString("sidebar.subtitle", comment: ""))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                } else {
                    Text(NSLocalizedString("sidebar.title", comment: ""))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.top, 8)
                }
                
                // Search field
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                    
                    TextField(NSLocalizedString("sidebar.search", comment: ""), text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13))
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.primary.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                )
                
                // I/O Section
                if !ioGates.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }).isEmpty {
                    GateSection(
                        title: NSLocalizedString("sidebar.section.io", comment: ""),
                        icon: "arrow.left.arrow.right.circle.fill",
                        gates: ioGates.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }),
                        hoveredName: $hoveredName,
                        vm: vm,
                        isCompact: isCompact
                    )
                }
                
                // Basic Gates Section
                if !basicGates.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }).isEmpty {
                    GateSection(
                        title: NSLocalizedString("sidebar.section.basic", comment: ""),
                        icon: "square.grid.2x2.fill",
                        gates: basicGates.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }),
                        hoveredName: $hoveredName,
                        vm: vm,
                        isCompact: isCompact
                    )
                }
                
                // Advanced Gates Section
                if !advancedGates.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }).isEmpty {
                    GateSection(
                        title: NSLocalizedString("sidebar.section.advanced", comment: ""),
                        icon: "cube.fill",
                        gates: advancedGates.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }),
                        hoveredName: $hoveredName,
                        vm: vm,
                        isCompact: isCompact
                    )
                }
                
                // Special Gates Section
                if !specialGates.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }).isEmpty {
                    GateSection(
                        title: NSLocalizedString("sidebar.section.special", comment: ""),
                        icon: "function",
                        gates: specialGates.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }),
                        hoveredName: $hoveredName,
                        vm: vm,
                        isCompact: isCompact
                    )
                }
                
                // Projection Gates Section
                if !projectionGates.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }).isEmpty {
                    GateSection(
                        title: NSLocalizedString("sidebar.section.projection", comment: ""),
                        icon: "arrow.turn.down.right",
                        gates: projectionGates.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }),
                        hoveredName: $hoveredName,
                        vm: vm,
                        isCompact: isCompact
                    )
                }
                
                // Constant Gates Section
                if !constantGates.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }).isEmpty {
                    GateSection(
                        title: NSLocalizedString("sidebar.section.constant", comment: ""),
                        icon: "number.circle.fill",
                        gates: constantGates.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }),
                        hoveredName: $hoveredName,
                        vm: vm,
                        isCompact: isCompact
                    )
                }
                
                // Flip-Flops Section
                if !flipFlops.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }).isEmpty {
                    GateSection(
                        title: NSLocalizedString("sidebar.section.flipflops", comment: ""),
                        icon: "memorychip.fill",
                        gates: flipFlops.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }),
                        hoveredName: $hoveredName,
                        vm: vm,
                        isCompact: isCompact
                    )
                }
                
                // Multiplexers Section
                if !multiplexers.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }).isEmpty {
                    GateSection(
                        title: NSLocalizedString("sidebar.section.multiplexers", comment: ""),
                        icon: "arrow.triangle.branch",
                        gates: multiplexers.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }),
                        hoveredName: $hoveredName,
                        vm: vm,
                        isCompact: isCompact
                    )
                }
                
                // Counters & Registers Section
                if !countersRegisters.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }).isEmpty {
                    GateSection(
                        title: NSLocalizedString("sidebar.section.counters", comment: ""),
                        icon: "gauge.with.dots.needle.bottom.50percent",
                        gates: countersRegisters.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }),
                        hoveredName: $hoveredName,
                        vm: vm,
                        isCompact: isCompact
                    )
                }
                
                // Adders Section
                if !adders.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }).isEmpty {
                    GateSection(
                        title: NSLocalizedString("sidebar.section.adders", comment: ""),
                        icon: "plusminus.circle.fill",
                        gates: adders.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }),
                        hoveredName: $hoveredName,
                        vm: vm,
                        isCompact: isCompact
                    )
                }
                
                // Decoders & Encoders Section
                if !decodersEncoders.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }).isEmpty {
                    GateSection(
                        title: NSLocalizedString("sidebar.section.decoders", comment: ""),
                        icon: "arrow.left.arrow.right.square.fill",
                        gates: decodersEncoders.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }),
                        hoveredName: $hoveredName,
                        vm: vm,
                        isCompact: isCompact
                    )
                }
                
                // Comparators Section
                if !comparators.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }).isEmpty {
                    GateSection(
                        title: NSLocalizedString("sidebar.section.comparators", comment: ""),
                        icon: "equal.square.fill",
                        gates: comparators.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }),
                        hoveredName: $hoveredName,
                        vm: vm,
                        isCompact: isCompact
                    )
                }
                
                // Memory Section
                if !memory.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }).isEmpty {
                    GateSection(
                        title: NSLocalizedString("sidebar.section.memory", comment: ""),
                        icon: "square.stack.3d.up.fill",
                        gates: memory.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }),
                        hoveredName: $hoveredName,
                        vm: vm,
                        isCompact: isCompact
                    )
                }
                
                // Timing Section
                if !timing.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }).isEmpty {
                    GateSection(
                        title: NSLocalizedString("sidebar.section.timing", comment: ""),
                        icon: "clock.fill",
                        gates: timing.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }),
                        hoveredName: $hoveredName,
                        vm: vm,
                        isCompact: isCompact
                    )
                }
                
                // Bus Components Section
                if !busComponents.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }).isEmpty {
                    GateSection(
                        title: NSLocalizedString("sidebar.section.bus", comment: ""),
                        icon: "square.split.2x1.fill",
                        gates: busComponents.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }),
                        hoveredName: $hoveredName,
                        vm: vm,
                        isCompact: isCompact
                    )
                }
                
                // Physical Components Section
                if !physicalComponents.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }).isEmpty {
                    GateSection(
                        title: NSLocalizedString("sidebar.section.physical", comment: ""),
                        icon: "powerplug.fill",
                        gates: physicalComponents.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }),
                        hoveredName: $hoveredName,
                        vm: vm,
                        isCompact: isCompact
                    )
                }
                
                // Transistors Section
                if !transistors.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }).isEmpty {
                    GateSection(
                        title: NSLocalizedString("sidebar.section.transistors", comment: ""),
                        icon: "hexagon.fill",
                        gates: transistors.filter({ searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }),
                        hoveredName: $hoveredName,
                        vm: vm,
                        isCompact: isCompact
                    )
                }

                Spacer(minLength: 20)
            }
            .padding(isCompact ? 8 : 16)
        }
        .frame(minWidth: isCompact ? 100 : 180, idealWidth: isCompact ? 140 : 220, maxWidth: isCompact ? 160 : 260)
        .background(.regularMaterial)
    }
}

// MARK: - Gate Section Component
struct GateSection: View {
    let title: String
    let icon: String
    let gates: [String]
    @Binding var hoveredName: String?
    @ObservedObject var vm: WorkspaceViewModel
    var isCompact: Bool = false
    @State private var isExpanded: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Section Header
            Button(action: { isExpanded.toggle() }) {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    Text(title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 0 : -90))
                }
            }
            .buttonStyle(.plain)
            .padding(.vertical, 4)
            
            if isExpanded {
                ForEach(gates, id: \.self) { name in
                    GateCard(name: name, hoveredName: $hoveredName, vm: vm, isCompact: isCompact)
                }
            }
        }
    }
}

// MARK: - Gate Card Component
struct GateCard: View {
    let name: String
    @Binding var hoveredName: String?
    @ObservedObject var vm: WorkspaceViewModel
    var isCompact: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            if isCompact {
                // Компактный режим - только иконка и название
                VStack(spacing: 4) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        colorFor(gate: name).opacity(0.2),
                                        colorFor(gate: name).opacity(0.35)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 36, height: 36)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                colorFor(gate: name).opacity(0.4),
                                                colorFor(gate: name).opacity(0.6)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                        
                        Image(systemName: iconFor(gate: name))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        colorFor(gate: name),
                                        colorFor(gate: name).opacity(0.8)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    .shadow(color: colorFor(gate: name).opacity(0.2), radius: hoveredName == name ? 3 : 1, x: 0, y: 1)
                    
                    Text(nameFor(gate: name))
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity)
                .padding(6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(hoveredName == name ? Color.primary.opacity(0.08) : Color.clear)
                )
            } else {
                // Полный режим
                HStack(spacing: 10) {
                    // Icon representation
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        colorFor(gate: name).opacity(0.2),
                                        colorFor(gate: name).opacity(0.35)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            colorFor(gate: name).opacity(0.4),
                                            colorFor(gate: name).opacity(0.6)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                    
                    Image(systemName: iconFor(gate: name))
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    colorFor(gate: name),
                                    colorFor(gate: name).opacity(0.8)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .shadow(color: colorFor(gate: name).opacity(0.2), radius: hoveredName == name ? 4 : 2, x: 0, y: 2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(nameFor(gate: name))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(subtitleFor(gate: name))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }

                    Spacer()
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(hoveredName == name ? Color.primary.opacity(0.08) : Color.primary.opacity(0.03))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(hoveredName == name ? Color.primary.opacity(0.2) : Color.primary.opacity(0.1), lineWidth: 1)
                )
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: 10))
        .onHover { inside in
            hoveredName = inside ? name : (hoveredName == name ? nil : hoveredName)
            vm.hoverPreviewName = inside ? name : nil
        }
        .onDrag {
            // Create NSItemProvider with the gate name
            let provider = NSItemProvider(object: NSString(string: name))
            provider.suggestedName = name
            return provider
        } preview: {
            // Custom drag preview showing the gate
            GateDragPreview(gateName: name)
        }
    }
    
    // Helper functions
    private func iconFor(gate: String) -> String {
        switch gate {
        case "INPUT": return "arrow.right.circle.fill"
        case "OUTPUT": return "arrow.left.circle.fill"
        case "AND": return "multiply.circle.fill"
        case "OR": return "plus.circle.fill"
        case "NOT": return "exclamationmark.circle.fill"
        case "NOT_B": return "exclamationmark.circle"
        case "XOR": return "xmark.circle.fill"
        case "XNOR": return "equal.circle.fill"
        case "NAND": return "multiply.circle"
        case "NOR": return "plus.circle"
        case "A_AND_NOT_B": return "chevron.right.circle.fill"
        case "NOT_A_AND_B": return "chevron.left.circle.fill"
        case "IMPL_AB": return "arrow.right.circle"
        case "IMPL_BA": return "arrow.left.circle"
        case "PROJ_A": return "a.circle.fill"
        case "PROJ_B": return "b.circle.fill"
        case "CONST0": return "0.circle.fill"
        case "CONST1": return "1.circle.fill"
        case "DISPLAY8BIT": return "textformat.123.fill"
        // Flip-Flops
        case "D_FLIPFLOP": return "d.circle.fill"
        case "T_FLIPFLOP": return "t.circle.fill"
        case "JK_FLIPFLOP": return "j.circle.fill"
        case "SR_LATCH": return "s.circle.fill"
        // Multiplexers
        case "MUX_2TO1", "MUX_4TO1": return "arrow.triangle.merge"
        case "DEMUX_1TO2", "DEMUX_1TO4": return "arrow.triangle.branch"
        // Counters & Registers
        case "COUNTER_4BIT": return "gauge.with.dots.needle.bottom.50percent"
        case "REGISTER_4BIT": return "externaldrive.fill"
        // Adders
        case "HALF_ADDER", "FULL_ADDER", "ADDER_4BIT": return "plus.forwardslash.minus"
        // Decoders & Encoders
        case "DECODER_2TO4", "DECODER_3TO8": return "arrow.down.right.and.arrow.up.left.circle.fill"
        case "ENCODER_4TO2": return "arrow.up.left.and.arrow.down.right.circle.fill"
        // Comparators
        case "COMPARATOR_1BIT", "COMPARATOR_4BIT": return "greaterthan.circle.fill"
        // Memory
        case "RAM_4X4": return "memorychip"
        case "ROM_4X4": return "opticaldisc"
        // Timing
        case "CLOCK": return "clock.fill"
        // Bus
        case "SPLITTER_4BIT": return "square.split.2x1"
        case "COMBINER_4BIT": return "square.grid.2x2"
        default: return "circle.fill"
        }
    }
    
    private func colorFor(gate: String) -> Color {
        switch gate {
        case "INPUT": return .green
        case "OUTPUT": return .blue
        case "AND": return .purple
        case "OR": return .orange
        case "NOT": return .red
        case "NOT_B": return .pink
        case "XOR": return .pink
        case "XNOR": return .mint
        case "NAND": return .indigo
        case "NOR": return .teal
        case "A_AND_NOT_B": return .cyan
        case "NOT_A_AND_B": return .brown
        case "IMPL_AB": return .yellow
        case "IMPL_BA": return .gray
        case "PROJ_A": return .purple.opacity(0.6)
        case "PROJ_B": return .blue.opacity(0.6)
        case "CONST0": return .black
        case "CONST1": return .white
        case "DISPLAY8BIT": return .cyan
        // Flip-Flops
        case "D_FLIPFLOP": return .blue
        case "T_FLIPFLOP": return .green
        case "JK_FLIPFLOP": return .purple
        case "SR_LATCH": return .orange
        // Multiplexers
        case "MUX_2TO1", "MUX_4TO1": return .indigo
        case "DEMUX_1TO2", "DEMUX_1TO4": return .teal
        // Counters & Registers
        case "COUNTER_4BIT": return .cyan
        case "REGISTER_4BIT": return .mint
        // Adders
        case "HALF_ADDER", "FULL_ADDER", "ADDER_4BIT": return .green
        // Decoders & Encoders
        case "DECODER_2TO4", "DECODER_3TO8": return .pink
        case "ENCODER_4TO2": return .purple
        // Comparators
        case "COMPARATOR_1BIT", "COMPARATOR_4BIT": return .orange
        // Memory
        case "RAM_4X4": return .blue
        case "ROM_4X4": return .gray
        // Timing
        case "CLOCK": return .red
        // Bus
        case "SPLITTER_4BIT", "COMBINER_4BIT": return .yellow
        default: return .gray
        }
    }
    
    private func nameFor(gate: String) -> String {
        let key = "gate.\(gate.lowercased())"
        return NSLocalizedString(key, comment: "")
    }
    
    private func subtitleFor(gate: String) -> String {
        let key = "gate.desc.\(gate.lowercased())"
        return NSLocalizedString(key, comment: "")
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView(vm: WorkspaceViewModel())
    }
}
