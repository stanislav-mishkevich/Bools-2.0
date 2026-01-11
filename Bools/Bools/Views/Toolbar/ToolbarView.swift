import SwiftUI
#if canImport(AppKit)
import AppKit
#endif
import UniformTypeIdentifiers

struct ToolbarView: View {
    @ObservedObject var vm: WorkspaceViewModel
    @Binding var showingSidebar: Bool
    @Binding var showingInspector: Bool
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var showingExamplesMenu = false
    @State private var toolbarWidth: CGFloat = 1000
    
    // Определяем, компактный ли интерфейс (для iOS или маленьких экранов)
    private var isCompact: Bool {
        #if os(iOS)
        return horizontalSizeClass == .compact
        #else
        // На macOS считаем компактным при ширине тулбара меньше 800 пикселей
        return toolbarWidth < 800
        #endif
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                // Кнопки управления панелями
                HStack(spacing: 4) {
                    Button(action: { showingSidebar.toggle() }) {
                        Image(systemName: showingSidebar ? "sidebar.left" : "sidebar.left")
                            .font(.system(size: 14))
                    }
                    .buttonStyle(.borderless)
                    #if os(macOS)
                    .help(showingSidebar ? NSLocalizedString("toolbar.help.hideSidebar", comment: "") : NSLocalizedString("toolbar.help.showSidebar", comment: ""))
                    #endif
                    
                    Button(action: { showingInspector.toggle() }) {
                        Image(systemName: showingInspector ? "sidebar.right" : "sidebar.right")
                            .font(.system(size: 14))
                    }
                    .buttonStyle(.borderless)
                    #if os(macOS)
                    .help(showingInspector ? NSLocalizedString("toolbar.help.hideInspector", comment: "") : NSLocalizedString("toolbar.help.showInspector", comment: ""))
                    #endif
                }
                .padding(.horizontal, 8)
                
                Divider()
                    .frame(height: 24)
            
                // Левая секция - файловые операции
                HStack(spacing: 8) {
                    Button(action: { vm.gates.removeAll(); vm.wires.removeAll(); vm.simulate() }) {
                        Label(NSLocalizedString("toolbar.new", comment: ""), systemImage: "doc.badge.plus")
                            .adaptiveLabelStyle(compact: isCompact)
                            .font(.system(size: 13))
                    }
                    .buttonStyle(.borderless)
                    #if os(macOS)
                    .help(NSLocalizedString("toolbar.help.new", comment: ""))
                    #endif

                    Divider()
                        .frame(height: 20)
                        .padding(.horizontal, 4)

                    Button(action: saveAction) {
                        Label(NSLocalizedString("toolbar.save", comment: ""), systemImage: "square.and.arrow.down")
                            .adaptiveLabelStyle(compact: isCompact)
                            .font(.system(size: 13))
                    }
                    .buttonStyle(.borderless)
                    #if os(macOS)
                    .help(NSLocalizedString("toolbar.help.save", comment: ""))
                    #endif

                    Button(action: quickSaveToDocuments) {
                        Label(NSLocalizedString("toolbar.quickSave", comment: ""), systemImage: "tray.and.arrow.down.fill")
                            .adaptiveLabelStyle(compact: isCompact)
                            .font(.system(size: 13))
                    }
                    .buttonStyle(.borderless)
                    #if os(macOS)
                    .help(NSLocalizedString("toolbar.help.quickSave", comment: ""))
                    #endif

                    Button(action: { Task { await loadAction() } }) {
                        Label(NSLocalizedString("toolbar.load", comment: ""), systemImage: "folder")
                            .adaptiveLabelStyle(compact: isCompact)
                            .font(.system(size: 13))
                    }
                    .buttonStyle(.borderless)
                    #if os(macOS)
                    .help(NSLocalizedString("toolbar.help.load", comment: ""))
                    #endif
                }
                .padding(.horizontal, 12)

            Divider()
                .frame(height: 24)
            
            // Undo/Redo секция
            HStack(spacing: 6) {
                Button(action: { vm.undo() }) {
                    Label(NSLocalizedString("toolbar.undo", comment: ""), systemImage: "arrow.uturn.backward")
                        .adaptiveLabelStyle(compact: isCompact)
                        .font(.system(size: 13))
                }
                .buttonStyle(.borderless)
                .disabled(!vm.canUndo)
                #if os(macOS)
                .help(NSLocalizedString("toolbar.help.undo", comment: ""))
                .keyboardShortcut("z", modifiers: .command)
                #endif
                
                Button(action: { vm.redo() }) {
                    Label(NSLocalizedString("toolbar.redo", comment: ""), systemImage: "arrow.uturn.forward")
                        .adaptiveLabelStyle(compact: isCompact)
                        .font(.system(size: 13))
                }
                .buttonStyle(.borderless)
                .disabled(!vm.canRedo)
                #if os(macOS)
                .help(NSLocalizedString("toolbar.help.redo", comment: ""))
                .keyboardShortcut("z", modifiers: [.command, .shift])
                #endif
            }
            .padding(.horizontal, 12)

            Divider()
                .frame(height: 24)

            // Центральная секция - zoom controls
            HStack(spacing: 6) {
                Button(action: { vm.performZoom(factor: 1.2, anchorInView: vm.lastMouseLocation) }) {
                    Label(NSLocalizedString("toolbar.zoomIn", comment: ""), systemImage: "plus.magnifyingglass")
                        .adaptiveLabelStyle(compact: isCompact)
                        .font(.system(size: 13, weight: .medium))
                }
                .buttonStyle(.borderless)
                #if os(macOS)
                .help(NSLocalizedString("toolbar.help.zoomIn", comment: ""))
                #endif

                Button(action: { vm.performZoom(factor: 1.0/1.2, anchorInView: vm.lastMouseLocation) }) {
                    Label(NSLocalizedString("toolbar.zoomOut", comment: ""), systemImage: "minus.magnifyingglass")
                        .adaptiveLabelStyle(compact: isCompact)
                        .font(.system(size: 13, weight: .medium))
                }
                .buttonStyle(.borderless)
                #if os(macOS)
                .help(NSLocalizedString("toolbar.help.zoomOut", comment: ""))
                #endif

                Button(action: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        vm.zoom = 1.0
                        vm.panOffset = .zero
                    }
                }) {
                    Label(NSLocalizedString("toolbar.reset", comment: ""), systemImage: "arrow.up.left.and.down.right.magnifyingglass")
                        .adaptiveLabelStyle(compact: isCompact)
                        .font(.system(size: 13, weight: .medium))
                }
                .buttonStyle(.borderless)
                #if os(macOS)
                .help(NSLocalizedString("toolbar.help.reset", comment: ""))
                #endif
            }
            .padding(.horizontal, 12)
            
            Divider()
                .frame(height: 24)

            if !isCompact {
                Spacer()
            }
            
            // Examples menu
            Menu {
                ForEach(ExampleSchemes.all, id: \.name) { scheme in
                    Button(action: { loadExample(scheme) }) {
                        VStack(alignment: .leading) {
                            Text(scheme.name)
                                .font(.headline)
                            Text(scheme.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } label: {
                Label(NSLocalizedString("toolbar.examples", comment: ""), systemImage: "book.fill")
                    .adaptiveLabelStyle(compact: isCompact)
                    .font(.system(size: 13))
            }
            .buttonStyle(.borderless)
            #if os(macOS)
            .help(NSLocalizedString("toolbar.help.examples", comment: ""))
            #endif
            .padding(.horizontal, 8)
            
            // Export menu
            Menu {
                Button(action: exportToJSON) {
                    Label(NSLocalizedString("export.json", comment: ""), systemImage: "doc.text")
                }
                
                Button(action: exportToPNG) {
                    Label(NSLocalizedString("export.image", comment: ""), systemImage: "photo")
                }
            } label: {
                Label(NSLocalizedString("toolbar.export", comment: ""), systemImage: "square.and.arrow.up")
                    .adaptiveLabelStyle(compact: isCompact)
                    .font(.system(size: 13))
            }
            .buttonStyle(.borderless)
            #if os(macOS)
            .help(NSLocalizedString("toolbar.help.export", comment: ""))
            #endif
            .padding(.horizontal, 12)

            // Индикатор сохранения
            if let msg = vm.saveMessage {
                HStack(spacing: 8) {
                    Circle()
                        .fill(vm.saveMessageIsError ? 
                              LinearGradient(colors: [Color.red.opacity(0.8), Color.red], startPoint: .topLeading, endPoint: .bottomTrailing) :
                              LinearGradient(colors: [Color.green.opacity(0.8), Color.green], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 8, height: 8)
                        .shadow(color: vm.saveMessageIsError ? .red.opacity(0.5) : .green.opacity(0.5), radius: 3, x: 0, y: 1)
                    Text(msg)
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.medium)
                        .lineLimit(1)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                )
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: vm.saveMessage)
                .padding(.trailing, 12)
            }
        }
        .padding(.horizontal, 4)
        }
        .frame(height: 44)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                #if os(macOS)
                LinearGradient(
                    colors: [
                        Color(NSColor.windowBackgroundColor).opacity(0.95),
                        Color(NSColor.windowBackgroundColor).opacity(0.85)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .background(.ultraThinMaterial)
                #else
                LinearGradient(
                    colors: [
                        Color(.systemBackground).opacity(0.95),
                        Color(.systemBackground).opacity(0.85)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .background(.ultraThinMaterial)
                #endif
                
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(Color.primary.opacity(0.08))
                        .frame(height: 1)
                }
            }
        )
        .background(
            GeometryReader { geometry in
                Color.clear.preference(key: ToolbarWidthKey.self, value: geometry.size.width)
            }
        )
        .onPreferenceChange(ToolbarWidthKey.self) { width in
            toolbarWidth = width
        }
    }
    
    private func saveAction() {
        #if os(macOS)
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "bools_workspace.json"
        panel.canCreateDirectories = true
        panel.begin { response in
            if response == .OK, let url = panel.url {
                // perform save on background queue
                DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        try vm.saveToURL(url)
                        DispatchQueue.main.async {
                            vm.saveMessageIsError = false
                            vm.saveMessage = String(format: NSLocalizedString("save.saved", comment: ""), url.lastPathComponent)
                            vm.saveLog.insert("Saved: \(url.path)", at: 0)
                            // clear message after 2.5s
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { vm.saveMessage = nil }
                        }
                    } catch {
                        DispatchQueue.main.async {
                            vm.saveMessageIsError = true
                            vm.saveMessage = NSLocalizedString("save.failed", comment: "")
                            vm.saveLog.insert("Failed to save: \(url.path) - \(error.localizedDescription)", at: 0)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { vm.saveMessage = nil }
                        }
                    }
                }
            }
        }
        #else
        // iOS: Quick save to Documents
        quickSaveToDocuments()
        #endif
    }

    private func loadAction() async {
        #if os(macOS)
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.begin { response in
            if response == .OK, let url = panel.url {
                Task {
                    do {
                        try await vm.loadFromURL(url)
                    } catch {
                        let alert = NSAlert(error: error)
                        alert.runModal()
                    }
                }
            }
        }
        #else
        // iOS: Show document picker
        // Для полной реализации нужен UIDocumentPickerViewController через UIViewControllerRepresentable
        vm.saveMessageIsError = false
        vm.saveMessage = NSLocalizedString("save.filePickerNotImplemented", comment: "")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { vm.saveMessage = nil }
        #endif
    }

    private func quickSaveToDocuments() {
        let fm = FileManager.default
        if let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = docs.appendingPathComponent("bools_workspace.json")
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try vm.saveToURL(fileURL)
                    DispatchQueue.main.async {
                        vm.saveMessageIsError = false
                        vm.saveMessage = String(format: NSLocalizedString("save.saved", comment: ""), fileURL.lastPathComponent)
                        vm.saveLog.insert("Saved: \(fileURL.path)", at: 0)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { vm.saveMessage = nil }
                    }
                } catch {
                    DispatchQueue.main.async {
                        vm.saveMessageIsError = true
                        vm.saveMessage = NSLocalizedString("save.quickFailed", comment: "")
                        vm.saveLog.insert("Quick save failed: \(error.localizedDescription)", at: 0)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { vm.saveMessage = nil }
                    }
                }
            }
        } else {
            vm.saveMessageIsError = true
            vm.saveMessage = NSLocalizedString("save.cannotFindDocuments", comment: "")
            vm.saveLog.insert("Quick save failed: no Documents folder", at: 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { vm.saveMessage = nil }
        }
    }
    
    private func exportToJSON() {
        #if os(macOS)
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "circuit_export.json"
        panel.canCreateDirectories = true
        panel.title = NSLocalizedString("panel.export.title", comment: "")
        panel.message = NSLocalizedString("panel.export.message", comment: "")
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        try vm.saveToURL(url)
                        DispatchQueue.main.async {
                            vm.saveMessageIsError = false
                            vm.saveMessage = String(format: NSLocalizedString("save.exported", comment: ""), url.lastPathComponent)
                            vm.saveLog.insert("Exported to JSON: \(url.path)", at: 0)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { vm.saveMessage = nil }
                        }
                    } catch {
                        DispatchQueue.main.async {
                            vm.saveMessageIsError = true
                            vm.saveMessage = NSLocalizedString("save.exportFailed", comment: "")
                            vm.saveLog.insert("Failed to export: \(error.localizedDescription)", at: 0)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { vm.saveMessage = nil }
                        }
                    }
                }
            }
        }
        #else
        // iOS: Save to Documents
        let fm = FileManager.default
        if let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
            let timestamp = dateFormatter.string(from: Date())
            let fileURL = docs.appendingPathComponent("circuit_\(timestamp).json")
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try vm.saveToURL(fileURL)
                    DispatchQueue.main.async {
                        vm.saveMessageIsError = false
                        vm.saveMessage = String(format: NSLocalizedString("save.exported", comment: ""), fileURL.lastPathComponent)
                        vm.saveLog.insert("Exported to: \(fileURL.path)", at: 0)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { vm.saveMessage = nil }
                    }
                } catch {
                    DispatchQueue.main.async {
                        vm.saveMessageIsError = true
                        vm.saveMessage = NSLocalizedString("save.exportFailed", comment: "")
                        vm.saveLog.insert("Export failed: \(error.localizedDescription)", at: 0)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { vm.saveMessage = nil }
                    }
                }
            }
        } else {
            vm.saveMessageIsError = true
            vm.saveMessage = NSLocalizedString("save.cannotFindDocuments", comment: "")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { vm.saveMessage = nil }
        }
        #endif
    }
    
    private func exportToPNG() {
        #if os(macOS)
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.nameFieldStringValue = "circuit.png"
        panel.canCreateDirectories = true
        panel.title = NSLocalizedString("panel.exportPNG.title", comment: "")
        panel.message = NSLocalizedString("panel.exportPNG.message", comment: "")
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                // Создаем рендер схемы
                if let image = vm.renderCircuitImage(size: CGSize(width: 2000, height: 2000)) {
                    if let tiffData = image.tiffRepresentation,
                       let bitmapImage = NSBitmapImageRep(data: tiffData),
                       let pngData = bitmapImage.representation(using: .png, properties: [:]) {
                        do {
                            try pngData.write(to: url)
                            DispatchQueue.main.async {
                                vm.saveMessageIsError = false
                                vm.saveMessage = String(format: NSLocalizedString("save.exported", comment: ""), url.lastPathComponent)
                                vm.saveLog.insert("Exported PNG: \(url.path)", at: 0)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { vm.saveMessage = nil }
                            }
                        } catch {
                            DispatchQueue.main.async {
                                vm.saveMessageIsError = true
                                vm.saveMessage = NSLocalizedString("save.exportFailed", comment: "")
                                vm.saveLog.insert("PNG export failed: \(error.localizedDescription)", at: 0)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { vm.saveMessage = nil }
                            }
                        }
                    }
                } else {
                    vm.saveMessageIsError = true
                    vm.saveMessage = NSLocalizedString("save.exportFailed", comment: "")
                    vm.saveLog.insert("Failed to create circuit image", at: 0)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { vm.saveMessage = nil }
                }
            }
        }
        #else
        vm.saveMessageIsError = false
        vm.saveMessage = NSLocalizedString("save.pngNotAvailable", comment: "")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { vm.saveMessage = nil }
        #endif
    }
    
    private func loadExample(_ scheme: ExampleScheme) {
        vm.saveStateForUndo() // Сохраняем текущее состояние
        
        let result = ExampleSchemes.loadScheme(scheme)
        vm.gates = result.gates
        vm.wires = result.wires
        vm.simulate()
        
        vm.saveMessageIsError = false
        vm.saveMessage = String(format: NSLocalizedString("save.loaded", comment: ""), scheme.name)
        vm.saveLog.insert("Loaded example: \(scheme.name)", at: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { vm.saveMessage = nil }
    }
}

struct ToolbarWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 1000
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        ToolbarView(vm: WorkspaceViewModel(), showingSidebar: .constant(true), showingInspector: .constant(true))
    }
}

// Helper для адаптивных Label-стилей
extension View {
    @ViewBuilder
    func adaptiveLabelStyle(compact: Bool) -> some View {
        if compact {
            self.labelStyle(.iconOnly)
        } else {
            self.labelStyle(.titleAndIcon)
        }
    }
}
