import SwiftUI
#if os(macOS)
import AppKit

/// NSViewRepresentable, который получает события масштабирования (пинч) из AppKit и передаёт
/// приращение масштаба вместе с локальной точкой в представлении, с началом координат в верхнем левом углу,
/// чтобы SwiftUI Canvas мог масштабироваться вокруг центра жеста
struct PinchTrackerView: NSViewRepresentable {
    var onMagnify: ((CGFloat, CGPoint) -> Void)? = nil

    func makeNSView(context: Context) -> NSView {
        let v = MagnifyHostView()
        v.wantsLayer = true
        v.layer?.backgroundColor = NSColor.clear.cgColor
        v.onMagnify = { mag, point in
            DispatchQueue.main.async { self.onMagnify?(mag, point) }
        }
        return v
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    class MagnifyHostView: NSView {
        var onMagnify: ((CGFloat, CGPoint) -> Void)?

        override var acceptsFirstResponder: Bool { true }

        override func magnify(with event: NSEvent) {
                // event.magnification это приращение масштаба, например 0.02
            let mag = event.magnification
            guard window != nil else { return }
            let locInWindow = event.locationInWindow
            let local = convert(locInWindow, from: nil)
            let flipped = CGPoint(x: local.x, y: bounds.height - local.y)
            onMagnify?(mag, flipped)
        }
    }
}
#endif
