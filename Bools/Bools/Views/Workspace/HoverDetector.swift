import SwiftUI

/// Определяет, находится ли последнее положение мыши в пределах `threshold` точек от кривой Безье любого провода
/// Обновляет `vm.hoveredWireID` соответствующим образом
struct HoverDetector: View {
    var wires: [Wire]
    var gates: [Gate]
    /// последнее положение мыши в координатах представления, `CanvasView` передаёт `vm.lastMouseLocation`
    var lastMouseLocation: CGPoint
    var threshold: CGFloat = 10.0 // в пикселях
    /// колбэк вызывается с id наведённого провода, или с nil
    var onHoverChanged: ((UUID?) -> Void)? = nil

    var body: some View {
        Color.clear
            .onChange(of: lastMouseLocation) {
                detectHover()
            }
            .onAppear { detectHover() }
    }

    private func detectHover() {
        // Преобразовать точку из координат представления в мировые координаты
        let viewPt = lastMouseLocation
        // Требуются преобразования вида, здесь предполагается, что вызывающий код передаёт значения в пространстве представления
        // В `CanvasView` мы передаём сырое `lastMouseLocation`, координаты гейтов и проводов в мировых координатах, поэтому здесь используем идентичное преобразование
        let worldPt = viewPt

        var found: UUID? = nil
        for w in wires {
            guard let fromGate = gates.first(where: { $0.id == w.fromGateID }), let toGate = gates.first(where: { $0.id == w.toGateID }) else { continue }
            let fromPins = fromGate.outputPins
            let toPins = toGate.inputPins
            guard fromPins.indices.contains(w.fromPinIndex), toPins.indices.contains(w.toPinIndex) else { continue }
            let fromPin = fromPins[w.fromPinIndex]
            let toPin = toPins[w.toPinIndex]
            let from = CGPoint(x: fromGate.position.x + fromPin.offset.x, y: fromGate.position.y + fromPin.offset.y)
            let to = CGPoint(x: toGate.position.x + toPin.offset.x, y: toGate.position.y + toPin.offset.y)

            let midX = (from.x + to.x) / 2
            let ctrl1 = CGPoint(x: midX, y: from.y)
            let ctrl2 = CGPoint(x: midX, y: to.y)

            // взять точки вдоль кубической кривой Безье, вычислить минимальное расстояние
            let steps = 40
            var minDist2: CGFloat = .greatestFiniteMagnitude
            for i in 0...steps {
                let t = CGFloat(i) / CGFloat(steps)
                let p = cubicBezierPoint(t: t, p0: from, p1: ctrl1, p2: ctrl2, p3: to)
                let dx = p.x - worldPt.x
                let dy = p.y - worldPt.y
                let d2 = dx*dx + dy*dy
                if d2 < minDist2 { minDist2 = d2 }
            }

            if minDist2 <= threshold * threshold {
                found = w.id
                break
            }
        }

        DispatchQueue.main.async {
            onHoverChanged?(found)
        }
    }

    private func cubicBezierPoint(t: CGFloat, p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint) -> CGPoint {
        let u = 1 - t
        let tt = t * t
        let uu = u * u
        let uuu = uu * u
        let ttt = tt * t

        var p = CGPoint.zero
        p.x = uuu * p0.x
        p.x += 3 * uu * t * p1.x
        p.x += 3 * u * tt * p2.x
        p.x += ttt * p3.x

        p.y = uuu * p0.y
        p.y += 3 * uu * t * p1.y
        p.y += 3 * u * tt * p2.y
        p.y += ttt * p3.y

        return p
    }
}
