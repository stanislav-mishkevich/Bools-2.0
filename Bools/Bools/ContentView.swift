//
//  ContentView.swift
//  Bools 2.0
//
//  Created by Mishkevich Stanislav on 11/11/25.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif
import UniformTypeIdentifiers

struct ContentView: View {
    @ObservedObject var vm: WorkspaceViewModel
    @ObservedObject var recentFilesManager: RecentFilesManager
    @Binding var showStartScreen: Bool
    @State private var keyMonitor: Any?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var showingSidebar = true
    @State private var showingInspector = true
    @State private var sidebarWidth: CGFloat = 260
    @State private var inspectorWidth: CGFloat = 280
    @State private var windowWidth: CGFloat = 1200
    @State private var showingAbout = false
    @State private var showingSettings = false
    @State private var showingHelp = false

    var body: some View {
        #if os(macOS)
        // macOS макет
        regularLayout
        #else
        // iOS - временно закомментировано
        EmptyView()
        #endif
        
        /* iOS код временно отключен
        #if os(iOS)
        // iOS адаптивный макет
        if horizontalSizeClass == .compact {
            // Компактный режим (iPhone вертикально)
            compactLayout
        } else {
            // Обычный режим (iPad или iPhone горизонтально)
            regularLayout
        }
        #else
        // macOS макет
        regularLayout
        #endif
        */
    }
    
    // Компактный макет для iOS
    private var compactLayout: some View {
        VStack(spacing: 0) {
            // TODO: Добавить bindings для iOS
            // ToolbarView(vm: vm, showingSidebar: $showingSidebar, showingInspector: $showingInspector)
            
            TabView {
                // Вкладка с холстом
                VStack(spacing: 0) {
                    CanvasView(vm: vm)
                        .background(.thinMaterial)
                }
                .tabItem {
                    Label(NSLocalizedString("contentview.tab.canvas", comment: ""), systemImage: "square.grid.2x2")
                }
                
                // Вкладка с вентилями
                SidebarView(vm: vm)
                    .tabItem {
                        Label(NSLocalizedString("contentview.tab.gates", comment: ""), systemImage: "cpu")
                    }
                
                // Вкладка с инспектором
                InspectorView(vm: vm)
                    .tabItem {
                        Label(NSLocalizedString("contentview.tab.inspector", comment: ""), systemImage: "info.circle")
                    }
            }
        }
        .onAppear {
            #if os(macOS)
            setupMenuCommandObservers()
            #endif
        }
    }
    
    // Обычный макет для macOS/iPad
    private var regularLayout: some View {
        GeometryReader { geometry in
            let isCompactMode = geometry.size.width < 1000
            let shouldShowSidebar = showingSidebar
            let shouldShowInspector = showingInspector
            let compactSidebarWidth: CGFloat = 140
            let compactInspectorWidth: CGFloat = 80
            
            HStack(spacing: 0) {
                if shouldShowSidebar {
                    SidebarView(vm: vm, isCompact: isCompactMode)
                        .frame(width: isCompactMode ? compactSidebarWidth : min(sidebarWidth, max(geometry.size.width * 0.3, 220)))
                        .frame(minWidth: isCompactMode ? compactSidebarWidth : 220)
                        .background(.ultraThinMaterial)

                    // Изменяемый разделитель только в полном режиме
                    #if os(macOS)
                    if !isCompactMode {
                        ResizableDivider(width: $sidebarWidth, minWidth: 220, maxWidth: 400)
                    }
                    #endif
                }

                VStack(spacing: 0) {
                    ToolbarView(vm: vm, showingSidebar: $showingSidebar, showingInspector: $showingInspector)

                    CanvasView(vm: vm)
                        .background(.thinMaterial)
                        .edgesIgnoringSafeArea(.all)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(minWidth: 400)

                if shouldShowInspector {
                    // Изменяемый разделитель только в полном режиме
                    #if os(macOS)
                    if !isCompactMode {
                        ResizableDivider(width: $inspectorWidth, minWidth: 200, maxWidth: 400, isTrailing: true)
                    }
                    #endif

                    InspectorView(vm: vm, isCompact: isCompactMode)
                        .frame(width: isCompactMode ? compactInspectorWidth : min(inspectorWidth, max(geometry.size.width * 0.3, 200)))
                        .frame(minWidth: isCompactMode ? compactInspectorWidth : 200)
                        .background(.ultraThinMaterial)
                }
            }
            .onChange(of: geometry.size.width) { _, newWidth in
                windowWidth = newWidth
            }
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingHelp) {
            HelpView()
        }
        .onAppear {
            #if os(macOS)
            setupKeyboardMonitoring()
            #endif
        }
        .onDisappear {
            #if os(macOS)
            cleanupKeyboardMonitoring()
            #endif
        }
    }
    
    #if os(macOS)
    private func setupKeyboardMonitoring() {
        print("🔑 [SETUP] Setting up keyboard monitoring...")
        
        // Глобальный монитор для перехвата всех горячих клавиш
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            print("🔑 [EVENT] Key pressed: keyCode=\(event.keyCode), chars=\(event.characters ?? "nil")")
            
            // Проверяем, не печатает ли пользователь в РЕАЛЬНО АКТИВНОМ текстовом поле
            let isTyping: Bool = {
                guard let responder = NSApp.keyWindow?.firstResponder else {
                    print("🔑 [EVENT] No first responder")
                    return false
                }
                
                let responderName = String(describing: type(of: responder))
                print("🔑 [EVENT] First responder: \(responderName)")
                
                // Для FieldEditor проверяем, есть ли реальное редактирование
                if responderName.contains("FieldEditor") {
                    print("🔑 [EVENT] Field editor detected, checking if actually editing...")
                    
                    if let textView = responder as? NSTextView {
                        // Получаем родительский NSTextField через delegate
                        let hasText = textView.string.count > 0
                        let isEditing = textView.window?.firstResponder == textView
                        
                        print("🔑 [EVENT] Text: '\(textView.string)', Length: \(textView.string.count), IsEditing: \(isEditing)")
                        
                        // Если есть текст ИЛИ курсор стоит в поле - блокируем hotkeys
                        // Проверяем также, не стоит ли курсор (selectedRange.location >= 0)
                        let hasCursor = textView.selectedRange.location != NSNotFound
                        
                        if hasText || (isEditing && hasCursor) {
                            print("🔑 [EVENT] User IS typing, blocking hotkeys")
                            return true
                        }
                        
                        print("🔑 [EVENT] Field editor inactive, allowing hotkeys")
                        return false
                    }
                    
                    return false
                }
                
                // Проверяем обычные текстовые поля
                if let textView = responder as? NSTextView, textView.isEditable {
                    print("🔑 [EVENT] Editable NSTextView, blocking hotkeys")
                    return true
                }
                
                if let textField = responder as? NSTextField, textField.isEditable {
                    print("🔑 [EVENT] Editable NSTextField, blocking hotkeys")
                    return true
                }
                
                print("🔑 [EVENT] Not editing, allowing hotkeys")
                return false
            }()
            
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            let hasCommand = flags.contains(.command)
            let hasShift = flags.contains(.shift)
            let hasControl = flags.contains(.control)
            
            print("🔑 [EVENT] Modifiers: Cmd=\(hasCommand), Shift=\(hasShift), Ctrl=\(hasControl), isTyping=\(isTyping)")
            
            // Обрабатываем все горячие клавиши здесь
            if !isTyping {
                // Delete/Backspace - удалить
                if event.keyCode == 51 || event.keyCode == 117 {
                    if !hasCommand {
                        print("✅ [HOTKEY] DELETE - selected: \(self.vm.selectedGateIDs.count)")
                        self.vm.deleteSelected()
                        return nil
                    }
                }
                
                // Esc - снять выделение
                if event.keyCode == 53 && !hasCommand {
                    print("✅ [HOTKEY] ESC - deselecting")
                    self.vm.selectedGateIDs.removeAll()
                    self.vm.selectedWireIDs.removeAll()
                    return nil
                }
                
                if hasCommand {
                    switch event.keyCode {
                    // Cmd+Z - Undo
                    case 6 where !hasShift:
                        print("✅ [HOTKEY] Cmd+Z (Undo)")
                        self.vm.undo()
                        return nil
                        
                    // Cmd+Shift+Z - Redo
                    case 6 where hasShift:
                        print("✅ [HOTKEY] Cmd+Shift+Z (Redo)")
                        self.vm.redo()
                        return nil
                        
                    // Cmd+Y - Redo альтернатива
                    case 16 where !hasShift:
                        print("✅ [HOTKEY] Cmd+Y (Redo)")
                        self.vm.redo()
                        return nil
                        
                    // Cmd+X - Cut
                    case 7 where !hasShift:
                        print("✅ [HOTKEY] Cmd+X (Cut)")
                        self.vm.cutSelected()
                        return nil
                        
                    // Cmd+C - Copy
                    case 8 where !hasShift:
                        print("✅ [HOTKEY] Cmd+C (Copy)")
                        self.vm.copySelected()
                        return nil
                        
                    // Cmd+V - Paste
                    case 9 where !hasShift:
                        print("✅ [HOTKEY] Cmd+V (Paste)")
                        self.vm.paste()
                        return nil
                        
                    // Cmd+A - Select All
                    case 0 where !hasShift:
                        print("✅ [HOTKEY] Cmd+A (Select All)")
                        self.vm.selectedGateIDs = Set(self.vm.gates.map { $0.id })
                        return nil
                        
                    // Cmd+D - Deselect All
                    case 2 where !hasShift:
                        print("✅ [HOTKEY] Cmd+D (Deselect)")
                        self.vm.selectedGateIDs.removeAll()
                        return nil
                        
                    // Cmd+N - New
                    case 45 where !hasShift:
                        print("[HOTKEY] Cmd+N (New)")
                        self.vm.newDocument()
                        return nil
                        
                    // Cmd+O - Open
                    case 31 where !hasShift:
                        print("[HOTKEY] Cmd+O (Open)")
                        Task { await self.loadWorkspace() }
                        return nil
                        
                    // Cmd+S - Save
                    case 1 where !hasShift:
                        print("[HOTKEY] Cmd+S (Save)")
                        self.saveWorkspace()
                        return nil
                        
                    // Cmd+Shift+S - Save As
                    case 1 where hasShift:
                        print("[HOTKEY] Cmd+Shift+S (Save As)")
                        self.saveWorkspaceAs()
                        return nil
                        
                    // Cmd+R - Run Simulation
                    case 15 where !hasShift:
                        print("[HOTKEY] Cmd+R (Simulate)")
                        self.vm.simulate()
                        return nil
                        
                    // Cmd++ или Cmd+= - Zoom In
                    case 24, 27 where !hasShift && event.characters == "=":
                        print("[HOTKEY] Cmd++ (Zoom In)")
                        self.vm.zoom = min(self.vm.zoom * 1.2, 3.0)
                        return nil
                        
                    // Cmd+- - Zoom Out
                    case 27 where !hasShift && event.characters == "-":
                        print("[HOTKEY] Cmd+- (Zoom Out)")
                        self.vm.zoom = max(self.vm.zoom / 1.2, 0.3)
                        return nil
                        
                    // Cmd+0 - Reset Zoom
                    case 29 where !hasShift:
                        print("[HOTKEY] Cmd+0 (Reset Zoom)")
                        self.vm.zoom = 1.0
                        self.vm.panOffset = .zero
                        return nil
                        
                    // Cmd+Ctrl+1 - Toggle Sidebar
                    case 18 where hasControl:
                        print("[HOTKEY] Cmd+Ctrl+1 (Toggle Sidebar)")
                        withAnimation { self.showingSidebar.toggle() }
                        return nil
                        
                    // Cmd+Ctrl+2 - Toggle Inspector
                    case 19 where hasControl:
                        print("[HOTKEY] Cmd+Ctrl+2 (Toggle Inspector)")
                        withAnimation { self.showingInspector.toggle() }
                        return nil
                        
                    // Cmd+Shift+E - Export JSON
                    case 14 where hasShift:
                        print("[HOTKEY] Cmd+Shift+E (Export JSON)")
                        self.exportToJSON()
                        return nil
                        
                    // Cmd+Shift+P - Export PNG
                    case 35 where hasShift:
                        print("[HOTKEY] Cmd+Shift+P (Export PNG)")
                        self.exportToPNG()
                        return nil
                        
                    default:
                        break
                    }
                }
            }
            
            // Пропускаем событие дальше, если не обработали
            return event
        }
        
        print("🔑 [SETUP] Keyboard monitor installed: \(keyMonitor != nil)")
        setupMenuCommandObservers()
    }
    
    private func cleanupKeyboardMonitoring() {
        print("🔑 [CLEANUP] Removing keyboard monitor")
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
        }
        keyMonitor = nil
    }
    #endif
    
    #if os(macOS)
    private func setupMenuCommandObservers() {
        // About menu
        NotificationCenter.default.addObserver(forName: .showAbout, object: nil, queue: .main) { _ in
            self.showingAbout = true
        }
        
        // Settings menu
        NotificationCenter.default.addObserver(forName: .showSettings, object: nil, queue: .main) { _ in
            self.showingSettings = true
        }
        
        // File menu
        NotificationCenter.default.addObserver(forName: .newDocument, object: nil, queue: .main) { _ in
            self.vm.newDocument()
        }
        
        NotificationCenter.default.addObserver(forName: .openDocument, object: nil, queue: .main) { _ in
            Task { await self.loadWorkspace() }
        }
        
        NotificationCenter.default.addObserver(forName: .saveDocument, object: nil, queue: .main) { _ in
            self.saveWorkspace()
        }
        
        NotificationCenter.default.addObserver(forName: .saveDocumentAs, object: nil, queue: .main) { _ in
            self.saveWorkspaceAs()
        }
        
        // Edit menu - Undo/Redo
        NotificationCenter.default.addObserver(forName: .undoAction, object: nil, queue: .main) { _ in
            self.vm.undo()
        }
        
        NotificationCenter.default.addObserver(forName: .redoAction, object: nil, queue: .main) { _ in
            self.vm.redo()
        }
        
        // Edit menu - Copy/Cut/Paste
        NotificationCenter.default.addObserver(forName: .cutSelected, object: nil, queue: .main) { _ in
            self.vm.cutSelected()
        }
        
        NotificationCenter.default.addObserver(forName: .copySelected, object: nil, queue: .main) { _ in
            self.vm.copySelected()
        }
        
        NotificationCenter.default.addObserver(forName: .pasteSelected, object: nil, queue: .main) { _ in
            self.vm.paste()
        }
        
        // Edit menu
        NotificationCenter.default.addObserver(forName: .deleteSelected, object: nil, queue: .main) { _ in
            self.vm.deleteSelected()
        }
        
        NotificationCenter.default.addObserver(forName: .selectAllGates, object: nil, queue: .main) { _ in
            self.vm.selectedGateIDs = Set(self.vm.gates.map { $0.id })
        }
        
        NotificationCenter.default.addObserver(forName: .deselectAll, object: nil, queue: .main) { _ in
            self.vm.selectedGateIDs.removeAll()
        }
        
        // View menu
        NotificationCenter.default.addObserver(forName: .zoomIn, object: nil, queue: .main) { _ in
            self.vm.zoom = min(self.vm.zoom * 1.2, 3.0)
        }
        
        NotificationCenter.default.addObserver(forName: .zoomOut, object: nil, queue: .main) { _ in
            self.vm.zoom = max(self.vm.zoom / 1.2, 0.3)
        }
        
        NotificationCenter.default.addObserver(forName: .resetZoom, object: nil, queue: .main) { _ in
            self.vm.zoom = 1.0
            self.vm.panOffset = .zero
        }
        
        NotificationCenter.default.addObserver(forName: .toggleSidebar, object: nil, queue: .main) { _ in
            withAnimation { self.showingSidebar.toggle() }
        }
        
        NotificationCenter.default.addObserver(forName: .toggleInspector, object: nil, queue: .main) { _ in
            withAnimation { self.showingInspector.toggle() }
        }
        
        // Circuit menu
        NotificationCenter.default.addObserver(forName: .runSimulation, object: nil, queue: .main) { _ in
            self.vm.simulate()
        }
        
        NotificationCenter.default.addObserver(forName: .exportJSON, object: nil, queue: .main) { _ in
            self.exportToJSON()
        }
        
        NotificationCenter.default.addObserver(forName: .exportPNG, object: nil, queue: .main) { _ in
            self.exportToPNG()
        }
        
        // Help menu
        NotificationCenter.default.addObserver(forName: .showHelp, object: nil, queue: .main) { _ in
            self.showingHelp = true
        }
    }
    
    private func loadWorkspace() async {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.begin { response in
            if response == .OK, let url = panel.url {
                Task {
                    do {
                        try await self.vm.loadFromURL(url)
                        self.recentFilesManager.addRecentFile(url)
                        print(NSLocalizedString("save.loaded", comment: ""), url.path)
                    } catch {
                        print(NSLocalizedString("save.failed", comment: ""))
                    }
                }
            }
        }
    }
    
    private func saveWorkspace() {
        if let url = vm.currentFileURL {
            // Сохраняем в текущий файл
            do {
                try vm.saveToURL(url)
                recentFilesManager.addRecentFile(url)
                print(String(format: NSLocalizedString("save.saved", comment: ""), url.path))
            } catch {
                print(NSLocalizedString("save.failed", comment: ""))
            }
        } else {
            // Показываем диалог "Сохранить как..."
            let panel = NSSavePanel()
            panel.allowedContentTypes = [.json]
            panel.nameFieldStringValue = "circuit.json"
            panel.begin { response in
                if response == .OK, let url = panel.url {
                    do {
                        try self.vm.saveToURL(url)
                        self.recentFilesManager.addRecentFile(url)
                        print(String(format: NSLocalizedString("save.saved", comment: ""), url.path))
                    } catch {
                        print(NSLocalizedString("save.failed", comment: ""))
                    }
                }
            }
        }
    }
    
    private func saveWorkspaceAs() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = vm.currentFileURL?.lastPathComponent ?? "circuit.json"
        panel.begin { response in
            if response == .OK, let url = panel.url {
                do {
                    try self.vm.saveToURL(url)
                    self.recentFilesManager.addRecentFile(url)
                    print(String(format: NSLocalizedString("save.saved", comment: ""), url.path))
                } catch {
                    print(NSLocalizedString("save.failed", comment: ""))
                }
            }
        }
    }
    
    private func exportToJSON() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "circuit-export.json"
        panel.begin { response in
            if response == .OK, let url = panel.url {
                do {
                    let workspace = WorkspaceData(gates: vm.gates, wires: vm.wires)
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                    let data = try encoder.encode(workspace)
                    try data.write(to: url)
                    print(String(format: NSLocalizedString("save.exported", comment: ""), url.path))
                } catch {
                    print(NSLocalizedString("save.exportFailed", comment: ""))
                }
            }
        }
    }
    
    private func exportToPNG() {
        print(NSLocalizedString("save.pngDevelopment", comment: ""))
        // TODO: Implement PNG export
    }
    #endif
}

#Preview {
    ContentView(
        vm: WorkspaceViewModel(),
        recentFilesManager: RecentFilesManager(),
        showStartScreen: .constant(false)
    )
}
