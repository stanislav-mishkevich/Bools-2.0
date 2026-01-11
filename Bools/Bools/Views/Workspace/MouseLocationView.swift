import SwiftUI
#if os(macOS)
import AppKit

/// Небольшой NSViewRepresentable, отслеживающий движение мыши внутри своих границ и сообщающий
/// местоположение мыши в локальных координатах представления через Binding
struct MouseLocationView: NSViewRepresentable {
    @Binding var location: CGPoint
    /// Необязательный колбэк прокрутки, передаёт исходное NSEvent и локальную точку события
    var onScroll: ((NSEvent, CGPoint) -> Void)? = nil

    func makeNSView(context: Context) -> NSView {
        let v = TrackingNSView()
        v.wantsLayer = true
        v.layer?.backgroundColor = NSColor.clear.cgColor
        v.onMove = { point in
            DispatchQueue.main.async {
                self.location = point
            }
        }
        v.onScroll = { event, point in
            DispatchQueue.main.async {
                self.onScroll?(event, point)
            }
        }
        return v
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    class TrackingNSView: NSView {
        var onMove: ((CGPoint) -> Void)?
        var onScroll: ((NSEvent, CGPoint) -> Void)?
        private var scrollMonitor: Any?

        override var acceptsFirstResponder: Bool { true }

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            
            if window != nil {
                    // Установить локальный монитор событий прокрутки
                scrollMonitor = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { [weak self] event in
                    guard let self = self, let _ = self.window else { return event }
                    
                    // Проверить, находится ли событие прокрутки в пределах view
                    let locInWindow = event.locationInWindow
                    let local = self.convert(locInWindow, from: nil)
                    
                    if self.bounds.contains(local) {
                        // Преобразовать в координаты SwiftUI, начало в верхнем левом углу
                        let flipped = CGPoint(x: local.x, y: self.bounds.height - local.y)
                        self.onScroll?(event, flipped)
                    }
                    
                    return event
                }
            } else {
                // Удалить монитор при удалении view из окна
                if let monitor = scrollMonitor {
                    NSEvent.removeMonitor(monitor)
                    scrollMonitor = nil
                }
            }
        }
        
        deinit {
            if let monitor = scrollMonitor {
                NSEvent.removeMonitor(monitor)
            }
        }

        override func updateTrackingAreas() {
            super.updateTrackingAreas()
            trackingAreas.forEach { removeTrackingArea($0) }
            let options: NSTrackingArea.Options = [.mouseMoved, .activeAlways, .inVisibleRect]
            let ta = NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil)
            addTrackingArea(ta)
            window?.acceptsMouseMovedEvents = true
        }

        override func mouseMoved(with event: NSEvent) {
            guard window != nil else { return }
            let locInWindow = event.locationInWindow
            let local = convert(locInWindow, from: nil)
            // Преобразовать в координаты с началом в верхнем левом углу, инвертировав y
            let flipped = CGPoint(x: local.x, y: bounds.height - local.y)
            onMove?(flipped)
        }
    }
}
#endif
