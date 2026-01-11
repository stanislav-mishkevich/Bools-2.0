import SwiftUI

struct InspectorView: View {
    @ObservedObject var vm: WorkspaceViewModel
    var isCompact: Bool = false

    var body: some View {
        let iconGradient = LinearGradient(
            colors: [.blue, .cyan],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        VStack(alignment: .leading, spacing: 0) {
            // Красивый заголовок
            HStack {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: isCompact ? 14 : 16, weight: .semibold))
                    .foregroundStyle(iconGradient)
                if !isCompact {
                    Text(NSLocalizedString("inspector.title", comment: ""))
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.semibold)
                }
                Spacer()
            }
            .padding(.horizontal, isCompact ? 8 : 16)
            .padding(.vertical, isCompact ? 8 : 12)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        VStack {
                            Spacer()
                            Rectangle()
                                .fill(Color.primary.opacity(0.08))
                                .frame(height: 1)
                        }
                    )
            )

            ScrollView {
                VStack(alignment: .leading, spacing: isCompact ? 8 : 16) {
                    // если выбран хотя бы один вентель — показываем его свойства
                    if let firstSelected = vm.selectedGateIDs.first,
                       let gate = vm.gates.first(where: { $0.id == firstSelected }) {

                        GateDetailView(gate: gate, vm: vm, isCompact: isCompact)

                    } else if let hover = vm.hoverPreviewName {
                        // show preview description and truth table for hovered sidebar element
                        if isCompact {
                            // Компактная версия - только иконка и название
                            VStack(spacing: 8) {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 24))
                                Text(hover)
                                    .font(.system(size: 10, weight: .semibold))
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(8)
                        } else {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(.orange)
                                        .imageScale(.large)
                                    Text(hover)
                                        .font(.system(.title3, design: .rounded))
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                                
                                Text(vm.shortDescriptionFor(name: hover))
                                    .font(.system(.callout, design: .default))
                                    .foregroundColor(.primary)
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .fill(Color.orange.opacity(0.05))
                                    )

                                VStack(alignment: .leading, spacing: 8) {
                                    Text(NSLocalizedString("inspector.truthTable", comment: ""))
                                        .font(.system(.caption, design: .rounded))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                        .textCase(.uppercase)
                                    let table = vm.truthTableFor(name: hover)
                                    TruthTableView(columns: table.columns, rows: table.rows)
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(.regularMaterial)
                                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                            )
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        }
                    } else {
                        VStack(spacing: isCompact ? 8 : 12) {
                            Image(systemName: "hand.point.up.left.fill")
                                .font(.system(size: isCompact ? 32 : 48))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.gray.opacity(0.5), .gray.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            if !isCompact {
                                Text(NSLocalizedString("inspector.noSelection", comment: ""))
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                Text(NSLocalizedString("inspector.noSelectionHint", comment: ""))
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, isCompact ? 20 : 40)
                    }
                }
                .padding(.bottom, isCompact ? 8 : 16)
            }
        }
        .frame(minWidth: isCompact ? 80 : 200, idealWidth: isCompact ? 80 : 280, maxWidth: .infinity)
        #if os(macOS)
        .background(
            Color(NSColor.windowBackgroundColor).opacity(0.5)
                .background(.regularMaterial)
        )
        #else
        .background(
            Color(.systemBackground).opacity(0.5)
                .background(.regularMaterial)
        )
        #endif
    }
}

struct InspectorView_Previews: PreviewProvider {
    static var previews: some View {
        InspectorView(vm: WorkspaceViewModel())
    }
}

// Detailed inspector content for a single selected gate.
struct GateDetailView: View {
    let gate: Gate
    @ObservedObject var vm: WorkspaceViewModel
    var isCompact: Bool = false

    var body: some View {
        if isCompact {
            // Компактная версия - только иконка, тип и значения
            VStack(spacing: 8) {
                Image(systemName: "cpu")
                    .foregroundColor(.blue)
                    .font(.system(size: 24))
                
                Text(gate.baseName)
                    .font(.system(size: 9, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                // Значения входов/выходов
                if !gate.inputPins.isEmpty {
                    VStack(spacing: 2) {
                        ForEach(gate.inputPins.indices, id: \.self) { idx in
                            Circle()
                                .fill(gate.inputPins[idx].value ? Color.green : Color.gray)
                                .frame(width: 8, height: 8)
                        }
                    }
                }
            }
            .padding(8)
        } else {
            VStack(alignment: .leading, spacing: 12) {
                // базовое имя (не редактируется)
                VStack(alignment: .leading, spacing: 6) {
                    Text(NSLocalizedString("inspector.gateType", comment: ""))
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    HStack {
                        Image(systemName: "cpu")
                            .foregroundColor(.blue)
                        Text(gate.baseName)
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.blue.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .strokeBorder(Color.blue.opacity(0.2), lineWidth: 1)
                            )
                    )
                }

                // суффикс метки — редактируемое поле
                VStack(alignment: .leading, spacing: 6) {
                    Text(NSLocalizedString("inspector.labelSuffix", comment: ""))
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)

                    // extracted Binding to keep expression simple
                    let suffixBinding = Binding<String>(
                        get: { gate.userSuffix ?? "" },
                        set: { newVal in
                            if let idx = vm.gates.firstIndex(where: { $0.id == gate.id }) {
                                vm.gates[idx].userSuffix = newVal
                                vm.simulate()
                            }
                        }
                    )

                    TextField(NSLocalizedString("inspector.labelSuffix.placeholder", comment: ""), text: suffixBinding)
                        .textFieldStyle(.plain)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color.primary.opacity(0.05))
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        )
                }
                
                // значение компонента (для резисторов, конденсаторов, батареи и транзисторов)
                if shouldShowComponentValue(gate: gate) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(NSLocalizedString("inspector.componentValue", comment: ""))
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)

                        let valueBinding = Binding<String>(
                            get: { gate.componentValue ?? "" },
                            set: { newVal in
                                if let idx = vm.gates.firstIndex(where: { $0.id == gate.id }) {
                                    vm.gates[idx].componentValue = newVal
                                    vm.simulate()
                                }
                            }
                        )

                        TextField(componentValuePlaceholder(gate: gate), text: valueBinding)
                            .textFieldStyle(.plain)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color.green.opacity(0.05))
                                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            )
                    }
                }

                // позиция вентиля
                VStack(alignment: .leading, spacing: 6) {
                    Text(NSLocalizedString("inspector.position", comment: ""))
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    HStack {
                        Label("\(Int(gate.position.x))", systemImage: "arrow.left.and.right")
                            .font(.system(.subheadline, design: .monospaced))
                        Spacer()
                        Label("\(Int(gate.position.y))", systemImage: "arrow.up.and.down")
                            .font(.system(.subheadline, design: .monospaced))
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.primary.opacity(0.03))
                    )
                }

                // описание — отображаемое (не редактируемое)
                if let desc = gate.description, !desc.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(NSLocalizedString("inspector.description", comment: ""))
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)

                        Text(desc)
                            .font(.system(.callout, design: .default))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color.primary.opacity(0.03))
                        )
                    }
                }

                // Truth table for the selected gate
                VStack(alignment: .leading, spacing: 8) {
                    Text(NSLocalizedString("inspector.truthTable", comment: ""))
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    let table = vm.truthTableFor(name: gate.baseName)
                    TruthTableView(columns: table.columns, rows: table.rows)
                }

                // для входных вентелей — переключатель значения
                if gate.baseName == "INPUT" {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(NSLocalizedString("inspector.inputValue", comment: ""))
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        HStack {
                            Image(systemName: gate.outputPins.first?.value ?? false ? "circle.fill" : "circle")
                                .foregroundColor(gate.outputPins.first?.value ?? false ? .green : .gray)
                                .imageScale(.large)
                            Text(gate.outputPins.first?.value ?? false ? NSLocalizedString("inspector.valueTrue", comment: "") : NSLocalizedString("inspector.valueFalse", comment: ""))
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.medium)
                            Spacer()

                            let inputToggleBinding = Binding<Bool>(
                                get: { gate.outputPins.first?.value ?? false },
                                set: { v in
                                    if let idx = vm.gates.firstIndex(where: { $0.id == gate.id }) {
                                        vm.gates[idx].outputPins[0].value = v
                                        vm.simulate()
                                    }
                                }
                            )

                            Toggle(isOn: inputToggleBinding) { EmptyView() }
                                .toggleStyle(.switch)
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color.green.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .strokeBorder(Color.green.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                }

                // кнопка удаления вентиля
                Button(role: .destructive) {
                    vm.deleteGate(id: gate.id)
                } label: {
                    HStack {
                        Image(systemName: "trash.fill")
                        Text(NSLocalizedString("inspector.deleteGate", comment: ""))
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .controlSize(.large)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.regularMaterial)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }
    
    // Проверяет, нужно ли показывать поле значения компонента
    private func shouldShowComponentValue(gate: Gate) -> Bool {
        let componentsWithValue = ["RESISTOR", "CAPACITOR", "BATTERY", "BJT_NPN", "BJT_PNP", "MOSFET_N", "MOSFET_P"]
        return componentsWithValue.contains(gate.baseName)
    }
    
    // Возвращает плейсхолдер в зависимости от типа компонента
    private func componentValuePlaceholder(gate: Gate) -> String {
        switch gate.baseName {
        case "RESISTOR":
            return "10k, 100Ω, 1M..."
        case "CAPACITOR":
            return "100u, 10n, 1p..."
        case "BATTERY":
            return "5V, 12V, 3.3V..."
        case "BJT_NPN", "BJT_PNP", "MOSFET_N", "MOSFET_P":
            return "2N2222, IRF540..."
        default:
            return ""
        }
    }
}

// A small reusable truth table renderer used in the inspector
struct TruthTableView: View {
    let columns: [String]
    let rows: [[String]]

    var body: some View {
        let headerGradient = LinearGradient(
            colors: [Color.blue.opacity(0.8), Color.blue],
            startPoint: .top,
            endPoint: .bottom
        )
        
        #if os(macOS)
        let containerFillColor = Color(NSColor.windowBackgroundColor)
        #else
        let containerFillColor = Color(.systemBackground)
        #endif

        return VStack(spacing: 4) {
            // header
            HStack(spacing: 8) {
                ForEach(columns, id: \.self) { c in
                    Text(c)
                        .font(.system(.caption, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding(.vertical, 8)
            .background(headerGradient)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

            // rows
            VStack(spacing: 0) {
                ForEach(rows.indices, id: \.self) { rIdx in
                    HStack(spacing: 8) {
                        ForEach(rows[rIdx].indices, id: \.self) { cIdx in
                            Text(rows[rIdx][cIdx])
                                .font(.system(.callout, design: .monospaced))
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .padding(.vertical, 8)
                    .background(rIdx % 2 == 0 ? Color.clear : Color.primary.opacity(0.03))
                    
                    if rIdx < rows.count - 1 {
                        Divider()
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.primary.opacity(0.03))
            )
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(containerFillColor)
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        )
    }
}
