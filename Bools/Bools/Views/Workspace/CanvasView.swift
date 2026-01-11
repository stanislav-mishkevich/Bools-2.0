import SwiftUI
#if os(macOS)
import AppKit
#endif

struct CanvasView: View {
    @ObservedObject var vm: WorkspaceViewModel

    @GestureState private var magnifyBy = CGFloat(1.0)
    @State private var dragOffset: CGSize = .zero
    // debug overlay and crosshair removed in production
    // state to track interactive pinch gesture base values
    @State private var pinchBaseZoom: CGFloat? = nil
    @State private var pinchBasePan: CGSize = .zero
    @State private var pinchBaseAnchor: CGPoint? = nil
    // mouse location now stored in ViewModel so toolbar buttons can use it

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // background material — attach pan gesture here so dragging empty canvas pans
                Rectangle()
                    .fill(.background)
                    .gesture(DragGesture(minimumDistance: 8, coordinateSpace: .local)
                        .onChanged { value in
                            // Pan the canvas when dragging background; account for zoom (translation in view -> world)
                            vm.panOffset.width += value.translation.width - dragOffset.width
                            vm.panOffset.height += value.translation.height - dragOffset.height
                            dragOffset = value.translation
                        }
                        .onEnded { _ in dragOffset = .zero }
                    )

                ZStack {
                    GridView(spacing: 32, panOffset: vm.panOffset, zoom: vm.zoom)

                    // Wires (clickable/selectable)
                    ForEach(vm.wires) { wire in
                        if let fromPos = vm.pinWorldPosition(gateID: wire.fromGateID, pinIndex: wire.fromPinIndex, type: .output), let toPos = vm.pinWorldPosition(gateID: wire.toGateID, pinIndex: wire.toPinIndex, type: .input) {
                            WireView(id: wire.id, from: fromPos, to: toPos, signal: wire.signal, isSelected: vm.selectedWireIDs.contains(wire.id)) {
                                // клик по проводу: переключение выделения
                                // поддерживаем модификаторы для мультивыделения
                                #if os(macOS)
                                let flags = NSEvent.modifierFlags
                                let multi = flags.contains(.command) || flags.contains(.shift) || flags.contains(.control)
                                #else
                                let multi = false
                                #endif

                                if multi {
                                    // добавить/убрать из набора выделенных
                                    if vm.selectedWireIDs.contains(wire.id) {
                                        vm.selectedWireIDs.remove(wire.id)
                                    } else {
                                        vm.selectedWireIDs.insert(wire.id)
                                    }
                                } else {
                                    // одиночное выделение: очистить остальные и выбрать этот
                                    vm.selectedWireIDs.removeAll()
                                    vm.selectedWireIDs.insert(wire.id)
                                }
                            }
                        }
                    }

                    // Central click handler moved to simultaneousGesture on the scaled ZStack below to reliably receive tap locations

                    // определяем позицию мыши в мировых координатах для hover-детектора
                    let worldMouse = CGPoint(
                        x: (vm.lastMouseLocation.x - vm.panOffset.width) / max(vm.zoom, 0.0001),
                        y: (vm.lastMouseLocation.y - vm.panOffset.height) / max(vm.zoom, 0.0001)
                    )

                    // порог в мировых единицах — масштабируем экранный порог на текущий zoom
                    let worldThreshold = 16.0 / max(vm.zoom, 0.0001)

                    HoverDetector(wires: vm.wires, gates: vm.gates, lastMouseLocation: worldMouse, threshold: worldThreshold) { found in
                        vm.hoveredWireID = found
                    }
                    .allowsHitTesting(false)

                    // Show delete button for hovered wire (or when mouse is near midpoint / wire selected)
                    ForEach(vm.wires) { wire in
                        if let fromPos = vm.pinWorldPosition(gateID: wire.fromGateID, pinIndex: wire.fromPinIndex, type: .output), let toPos = vm.pinWorldPosition(gateID: wire.toGateID, pinIndex: wire.toPinIndex, type: .input) {
                            let mid = CGPoint(x: (fromPos.x + toPos.x) / 2, y: (fromPos.y + toPos.y) / 2)
                            let dx = mid.x - worldMouse.x
                            let dy = mid.y - worldMouse.y
                            let nearMid = (dx*dx + dy*dy) <= (24 * 24)

                            if vm.hoveredWireID == wire.id || vm.selectedWireIDs.contains(wire.id) || nearMid {
                                Button(action: { vm.deleteWire(id: wire.id) }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 28, height: 28)
                                            .shadow(color: .black.opacity(0.12), radius: 1, x: 0, y: 1)
                                        Image(systemName: "xmark")
                                            .foregroundColor(.white)
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                }
                                .buttonStyle(.plain)
                                .frame(width: 32, height: 32)
                                .contentShape(Circle())
                                .position(mid)
                            }
                        }
                    }

                    // временное соединение при перетаскивании провода
                    if let start = vm.tempConnectionStart, let current = vm.tempConnectionCurrent {
                        let fromType: PinType = start.type
                        if let fromPos = vm.pinWorldPosition(gateID: start.gateID, pinIndex: start.pinIndex, type: fromType) {
                            WireView(id: UUID(), from: fromPos, to: current, signal: true)
                        }
                    }

                    // Gates
                    ForEach(vm.gates) { gate in
                        GateView(vm: vm, gate: gate)
                    }
                    .onAppear {
                        print("[DEBUG] CanvasView rendering \(vm.gates.count) gates")
                    }
                }
                .scaleEffect(vm.zoom * magnifyBy, anchor: .topLeading)
                .offset(vm.panOffset)
                .clipped()
                .simultaneousGesture(DragGesture(minimumDistance: 8)
                    .onEnded { value in
                        // value.location is in the view/local coordinates (screen space) of this ZStack.
                        // To avoid ambiguity with transformed coordinate spaces, perform hit-testing in screen coordinates:
                        let clickPoint = value.location
                        var best: (id: UUID, dist2: CGFloat)? = nil
                        let steps = 80 // increase sampling for more accurate hit tests
                        let screenThresh: CGFloat = 12.0

                        for w in vm.wires {
                            guard let from = vm.pinWorldPosition(gateID: w.fromGateID, pinIndex: w.fromPinIndex, type: .output), let to = vm.pinWorldPosition(gateID: w.toGateID, pinIndex: w.toPinIndex, type: .input) else { continue }
                            var minDist2: CGFloat = .greatestFiniteMagnitude
                            for i in 0...steps {
                                let t = CGFloat(i) / CGFloat(steps)
                                let p = cubicBezierPoint(t: t, p0: from, p1: CGPoint(x: (from.x+to.x)/2, y: from.y), p2: CGPoint(x: (from.x+to.x)/2, y: to.y), p3: to)
                                // convert world point to screen/view point using current zoom & pan
                                let screenX = p.x * vm.zoom + vm.panOffset.width
                                let screenY = p.y * vm.zoom + vm.panOffset.height
                                let dx = screenX - clickPoint.x
                                let dy = screenY - clickPoint.y
                                let d2 = dx*dx + dy*dy
                                if d2 < minDist2 { minDist2 = d2 }
                            }
                            if minDist2 <= screenThresh*screenThresh {
                                if best == nil || minDist2 < best!.dist2 { best = (w.id, minDist2) }
                            }
                        }

                        if let found = best {
                            #if os(macOS)
                            let flags = NSEvent.modifierFlags
                            let multi = flags.contains(.command) || flags.contains(.shift) || flags.contains(.control)
                            #else
                            let multi = false
                            #endif
                            if multi {
                                if vm.selectedWireIDs.contains(found.id) { vm.selectedWireIDs.remove(found.id) } else { vm.selectedWireIDs.insert(found.id) }
                            } else {
                                vm.selectedWireIDs.removeAll()
                                vm.selectedWireIDs.insert(found.id)
                            }
                        } else {
                            #if os(macOS)
                            let flags = NSEvent.modifierFlags
                            if !flags.contains(.command) && !flags.contains(.shift) && !flags.contains(.control) {
                                vm.selectedWireIDs.removeAll()
                            }
                            #else
                            vm.selectedWireIDs.removeAll()
                            #endif
                        }
                    }
                )
                // Drag to pan the canvas
                .gesture(DragGesture(minimumDistance: 8, coordinateSpace: .local)
                    .onChanged { value in
                        vm.panOffset.width += value.translation.width - dragOffset.width
                        vm.panOffset.height += value.translation.height - dragOffset.height
                        dragOffset = value.translation
                    }
                    .onEnded { _ in dragOffset = .zero }
                )
                .gesture(MagnificationGesture()
                    .updating($magnifyBy) { current, state, _ in state = current }
                    .updating($magnifyBy) { current, state, _ in
                        // update the published gesture state used by scaleEffect
                        state = current

                        // initialize base zoom/pan/anchor at the start of the gesture
                        if pinchBaseZoom == nil {
                            pinchBaseZoom = vm.zoom
                            pinchBasePan = vm.panOffset
                            pinchBaseAnchor = (vm.lastMouseLocation == .zero) ? CGPoint(x: geo.size.width/2, y: geo.size.height/2) : vm.lastMouseLocation
                        }

                        // compute temporary pan so the visual scale (vm.zoom * current)
                        // keeps the pinch anchor stationary in view coordinates
                        if let basePan = Optional(pinchBasePan), let anchor = pinchBaseAnchor {
                            let newPanX = anchor.x - (anchor.x - basePan.width) * current
                            let newPanY = anchor.y - (anchor.y - basePan.height) * current
                            DispatchQueue.main.async {
                                vm.panOffset = CGSize(width: newPanX, height: newPanY)
                            }
                        }
                    }
                    .onEnded { value in
                        // determine anchor: prefer the recorded gesture anchor, fallback to current mouse or center
                        let anchor = pinchBaseAnchor ?? ((vm.lastMouseLocation == .zero) ? CGPoint(x: geo.size.width/2, y: geo.size.height/2) : vm.lastMouseLocation)

                        // base values captured at gesture start (or fallback to current)
                        let baseZoom = pinchBaseZoom ?? vm.zoom
                        let basePan = pinchBasePan

                        // compute final clamped zoom
                        let clamped = max(0.1, min(baseZoom * value, 8.0))

                        // compute world point under anchor using base values
                        let worldX = (anchor.x - basePan.width) / baseZoom
                        let worldY = (anchor.y - basePan.height) / baseZoom
                        let newPanX = anchor.x - worldX * clamped
                        let newPanY = anchor.y - worldY * clamped

                        #if DEBUG
                        print("[Zoom debug] interactive end anchor:\(anchor) baseZoom:\(baseZoom) final:\(clamped) basePan:\(basePan)")
                        #endif

                        withAnimation(.easeOut(duration: 0.18)) {
                            vm.zoom = clamped
                            vm.panOffset = CGSize(width: newPanX, height: newPanY)
                        }

                        // clear gesture base
                        pinchBaseZoom = nil
                        pinchBaseAnchor = nil
                    }
                )
                // allow dropping items from the sidebar
                .onDrop(of: ["public.text"], isTargeted: nil) { providers, dropLocation in
                    print("[DEBUG] onDrop called with \(providers.count) providers at location: \(dropLocation)")
                    if let provider = providers.first {
                        _ = provider.loadObject(ofClass: NSString.self) { (obj, err) in
                            print("[DEBUG] loadObject completed. obj: \(String(describing: obj)), err: \(String(describing: err))")
                            guard let name = obj as? String else { 
                                print("[DEBUG] Failed to cast obj to String")
                                return 
                            }
                            // Convert dropLocation to canvas coordinates: account for current zoom and pan
                            DispatchQueue.main.async {
                                // dropLocation is in the coordinate space of the CanvasView; adjust for transforms
                                let localPoint = CGPoint(x: dropLocation.x, y: dropLocation.y)
                                let worldX = (localPoint.x - vm.panOffset.width) / vm.zoom
                                let worldY = (localPoint.y - vm.panOffset.height) / vm.zoom
                                print("[DEBUG] Adding gate '\(name)' at world coords: (\(worldX), \(worldY))")
                                vm.addGate(named: name, at: CGPoint(x: worldX, y: worldY))
                            }
                        }
                        return true
                    }
                    print("[DEBUG] No provider found")
                    return false
                }
                // mouse tracking overlay to capture last mouse location for cursor-centered zoom
                // Pinch tracker: capture pinch gestures' center and magnification delta via AppKit
                #if os(macOS)
                PinchTrackerView { mag, point in
                    // mag is a delta (e.g. 0.02). Convert to multiplicative factor.
                    let factor = 1.0 + mag
                    // Prefer the precise pinch center provided by AppKit; fallback to canvas center
                    let anchorPoint = (point == .zero) ? CGPoint(x: geo.size.width/2, y: geo.size.height/2) : point
                    // Apply immediately without extra animation for precise feel
                    vm.performZoom(factor: factor, anchorInView: anchorPoint, animate: false)
                }
                // Do not capture hit-testing here otherwise this overlay will block clicks
                // on underlying GateView / WireView elements. The NSView inside will still
                // receive magnify events when part of the view hierarchy.
                .allowsHitTesting(false)

                MouseLocationView(location: $vm.lastMouseLocation, onScroll: { event, localPoint in
                    // Use original NSEvent to pick precise deltas and phases for trackpad
                    // Compute a dy value we can use consistently across devices
                    var dy: CGFloat = 0
                    if event.hasPreciseScrollingDeltas {
                        // trackpad / precision device
                        dy = event.scrollingDeltaY
                    } else {
                        // mouse wheel — deltaY tends to be small integer; amplify it
                        dy = event.scrollingDeltaY != 0 ? event.scrollingDeltaY : (-event.deltaY * 10)
                    }

                    // Choose sensitivity tuned for precise vs coarse devices
                    let sensitivity: CGFloat = event.hasPreciseScrollingDeltas ? 0.004 : 0.02

                    // Clamp per-event zoom factor to avoid huge jumps from noisy scroll events
                    let rawFactor = exp(dy * sensitivity)
                    let perEventFactor = min(max(rawFactor, 0.90), 1.10)

                    // Use vm.lastMouseLocation which is tracked in the GeometryReader's coordinate space
                    // This ensures the anchor is correctly positioned for zoom calculations
                    let anchor: CGPoint = (vm.lastMouseLocation == .zero) ? CGPoint(x: geo.size.width/2, y: geo.size.height/2) : vm.lastMouseLocation

                    // Apply the clamped per-event factor immediately (no animation) so the
                    // visual state stays in sync with the math and doesn't jump.
                    vm.performZoom(factor: perEventFactor, anchorInView: anchor, animate: false)
                })
                .allowsHitTesting(false)
                #endif
            }
            // Debug overlay: shows brief textual info when scrolling in DEBUG builds
            // debug overlay removed
            // visual debug crosshairs (untransformed view coordinates)
            // debug crosshairs removed
            // Zoom percentage HUD (100% == zoom == 1.0, relative to window size)
            HStack {
                Spacer()
                Text({
                    let eff = vm.zoom * magnifyBy
                    return String(format: "%d%%", Int(round(eff * 100)))
                }())
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.66))
                .cornerRadius(6)
                .padding([.top, .trailing], 10)
                .accessibilityLabel(Text("Zoom percentage"))
            }
        }
        .contentShape(Rectangle()) // Делаем весь canvas кликабельным
        .onTapGesture {
            // При клике на canvas убираем фокус с текстовых полей
            #if os(macOS)
            DispatchQueue.main.async {
                NSApp.keyWindow?.makeFirstResponder(nil)
                print("🔑 [CANVAS] Focus cleared from text fields")
            }
            #endif
        }
    }

    private func performZoom(factor: CGFloat, anchorInView: CGPoint, geo: GeometryProxy) {
        let beforeZoom = vm.zoom
        let beforePan = vm.panOffset

        let clamped = max(0.1, min(vm.zoom * factor, 8.0))
        
        // anchor is in view coordinates; compute world point
        let worldX = (anchorInView.x - vm.panOffset.width) / vm.zoom
        let worldY = (anchorInView.y - vm.panOffset.height) / vm.zoom
        let newPanX = anchorInView.x - worldX * clamped
        let newPanY = anchorInView.y - worldY * clamped

        #if DEBUG
        print("[Zoom debug] performZoom anchor:\(anchorInView) world:\(worldX),\(worldY) oldZoom:\(beforeZoom) newZoom:\(clamped)")
        print("[Zoom debug] oldPan:\(beforePan) newPan:\(CGSize(width: newPanX, height: newPanY))")
        #endif

        withAnimation(.easeOut(duration: 0.18)) {
            vm.zoom = clamped
            vm.panOffset = CGSize(width: newPanX, height: newPanY)
        }
    }

    // cubic bezier helper used for hit-testing wires
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

// Simple debug crosshair view used only for temporary diagnostics
// Debug crosshair view removed
