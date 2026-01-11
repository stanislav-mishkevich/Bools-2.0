import SwiftUI

struct WireView: View {
    var id: UUID
    var from: CGPoint
    var to: CGPoint
    var signal: Bool
    var isSelected: Bool = false
    var onTap: (() -> Void)? = nil

    var body: some View {
        // build the bezier path once so we can use it both for stroke and contentShape
        let path = Path { path in
            path.move(to: from)
            let midX = (from.x + to.x) / 2
            let ctrl1 = CGPoint(x: midX, y: from.y)
            let ctrl2 = CGPoint(x: midX, y: to.y)
            path.addCurve(to: to, control1: ctrl1, control2: ctrl2)
        }
        ZStack {
            // видимая линия провода — отдельные переменные для читаемости
            let strokeColor = isSelected ? Color.accentColor : (signal ? Color.green : Color.gray)
            let strokeWidth: CGFloat = isSelected ? 4 : 3

            path
                .stroke(strokeColor, lineWidth: strokeWidth)
                .shadow(color: .black.opacity(0.15), radius: 1, x: 0, y: 1)

            // невидимая широкая линия для улучшенного хит-тестинга
            // она не влияет на отображение, только на область нажатия
            path
                .stroke(Color.clear, lineWidth: 14)
                .contentShape(path)
        }
        .animation(.easeInOut, value: signal)
    }
}
