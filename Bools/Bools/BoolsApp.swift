//
//  Bools_2_0App.swift
//  Bools 2.0
//
//  Created by Mishkevich Stanislav on 11/11/25.
//

import SwiftUI
import UniformTypeIdentifiers

@main
struct BoolsApp: App {
    @StateObject private var recentFilesManager = RecentFilesManager()
    @AppStorage("theme") private var theme: String = "system"
    
    var body: some Scene {
        WindowGroup {
            AppRootView(recentFilesManager: recentFilesManager)
                .preferredColorScheme(colorScheme)
        }
        #if os(macOS)
        .defaultSize(width: 1200, height: 700)
        .commands {
            AppCommands()
        }
        #endif
    }
    
    private var colorScheme: ColorScheme? {
        switch theme {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil // system default
        }
    }
}

// Корневое представление приложения с управлением начальным экраном
struct AppRootView: View {
    @StateObject private var vm = WorkspaceViewModel()
    @ObservedObject var recentFilesManager: RecentFilesManager
    @State private var showStartScreen = true
    
    var body: some View {
        Group {
            if showStartScreen {
                StartScreenView(
                    showStartScreen: $showStartScreen,
                    recentFilesManager: recentFilesManager,
                    onNewDocument: {
                        vm.newDocument()
                    },
                    onOpenDocument: {
                        Task { await loadWorkspace() }
                    },
                    onOpenRecentFile: { url in
                        Task { await loadWorkspace(from: url) }
                    }
                )
            } else {
                ContentView(vm: vm, recentFilesManager: recentFilesManager, showStartScreen: $showStartScreen)
                    .frame(minWidth: 900, minHeight: 600)
                    #if os(macOS)
                    .closeConfirmation(
                        viewModel: vm,
                        onSave: {
                            saveWorkspace()
                        },
                        onDiscard: {
                            // Просто разрешаем закрытие
                        }
                    )
                    #endif
            }
        }
        .onAppear { adjustWindowSize(forStart: showStartScreen) }
        .onChange(of: showStartScreen) { newValue in adjustWindowSize(forStart: newValue) }
    }
    
    private func loadWorkspace(from url: URL? = nil) async {
        #if os(macOS)
        if let url = url {
            // Открываем конкретный файл
            do {
                try await vm.loadFromURL(url)
                recentFilesManager.addRecentFile(url)
                showStartScreen = false
            } catch {
                let alert = NSAlert()
                alert.messageText = "Ошибка открытия файла"
                alert.informativeText = error.localizedDescription
                alert.alertStyle = .warning
                alert.runModal()
            }
        } else {
            // Показываем диалог выбора файла
            let panel = NSOpenPanel()
            panel.allowedContentTypes = [.json]
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = false
            
            if panel.runModal() == .OK, let url = panel.url {
                do {
                    try await vm.loadFromURL(url)
                    recentFilesManager.addRecentFile(url)
                    showStartScreen = false
                } catch {
                    let alert = NSAlert()
                    alert.messageText = "Ошибка открытия файла"
                    alert.informativeText = error.localizedDescription
                    alert.alertStyle = .warning
                    alert.runModal()
                }
            }
        }
        #endif
    }
    
    #if os(macOS)
    private func adjustWindowSize(forStart: Bool) {
        DispatchQueue.main.async {
            guard let window = NSApp.keyWindow ?? NSApp.windows.first else { return }
            if forStart {
                let target = NSSize(width: 700, height: 420)
                window.setContentSize(target)
                window.titleVisibility = .hidden
                window.center()
            } else {
                let target = NSSize(width: 1200, height: 700)
                window.setContentSize(target)
                window.titleVisibility = .visible
                window.center()
            }
        }
    }
    #endif

    private func saveWorkspace() {
        #if os(macOS)
        if let url = vm.currentFileURL {
            // Сохраняем в текущий файл
            do {
                try vm.saveToURL(url)
                recentFilesManager.addRecentFile(url)
            } catch {
                let alert = NSAlert()
                alert.messageText = "Ошибка сохранения"
                alert.informativeText = error.localizedDescription
                alert.alertStyle = .warning
                alert.runModal()
            }
        } else {
            // Показываем диалог "Сохранить как..."
            saveWorkspaceAs()
        }
        #endif
    }
    
    private func saveWorkspaceAs() {
        #if os(macOS)
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "Untitled.json"
        
        if panel.runModal() == .OK, let url = panel.url {
            do {
                try vm.saveToURL(url)
                recentFilesManager.addRecentFile(url)
            } catch {
                let alert = NSAlert()
                alert.messageText = "Ошибка сохранения"
                alert.informativeText = error.localizedDescription
                alert.alertStyle = .warning
                alert.runModal()
            }
        }
        #endif
    }
}
