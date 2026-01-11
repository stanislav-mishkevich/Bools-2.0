import SwiftUI

/// Предпросмотр гейта, показываемый при перетаскивании из боковой панели
/// Точно соответствует внешнему виду GateView
struct GateDragPreview: View {
    let gateName: String
    
    var body: some View {
        ZStack(alignment: .center) {
            // Такой же фон, как у GateView
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .frame(width: 120, height: 64)
                .overlay(
                    VStack(spacing: 4) {
                        Text(gateName)
                            .font(.headline)
                        HStack(spacing: 8) {
                            // Показать значение по умолчанию "0"
                            Text("0")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            // Показать переключатель для гейтов INPUT
                            if gateName == "INPUT" {
                                Toggle(isOn: .constant(false)) {
                                    EmptyView()
                                }
                                .labelsHidden()
                                .toggleStyle(.switch)
                                .frame(width: 44)
                                .disabled(true)
                            }
                        }
                    }
                )
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

            // Входные пины слева, соответствуют позициям пинов в GateView
            ForEach(0..<inputCountFor(gate: gateName), id: \.self) { i in
                Circle()
                    .fill(Color.gray)
                    .frame(width: 12, height: 12)
                    .offset(x: pinOffsetX(isInput: true), y: pinOffsetY(index: i, count: inputCountFor(gate: gateName)))
            }
            
            // Выходные пины справа, соответствуют позициям пинов в GateView
            ForEach(0..<outputCountFor(gate: gateName), id: \.self) { i in
                Circle()
                    .fill(Color.gray)
                    .frame(width: 12, height: 12)
                    .offset(x: pinOffsetX(isInput: false), y: pinOffsetY(index: i, count: outputCountFor(gate: gateName)))
            }
        }
        .frame(width: 120, height: 64)
    }
    
    // Сопоставить позиции пинов с инициализацией модели Gate
    private func pinOffsetX(isInput: Bool) -> CGFloat {
        return isInput ? -50 : 50
    }
    
    private func pinOffsetY(index: Int, count: Int) -> CGFloat {
        return CGFloat(index * 24 - (count - 1) * 12)
    }
    
    private func inputCountFor(gate: String) -> Int {
        switch gate.uppercased() {
        case "INPUT": return 0
        case "OUTPUT": return 1
        case "NOT": return 1
        default: return 2
        }
    }
    
    private func outputCountFor(gate: String) -> Int {
        switch gate.uppercased() {
        case "INPUT": return 1
        case "OUTPUT": return 0
        default: return 1
        }
    }
}
