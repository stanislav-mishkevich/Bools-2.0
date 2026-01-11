//
//  AppCommands.swift
//  Bools 2.0
//
//  Команды меню macOS
//

import SwiftUI

struct AppCommands: Commands {
    var body: some Commands {
        // Заменяет стандартный пункт меню О программе
        CommandGroup(replacing: .appInfo) {
            Button("About Bools") {
                NotificationCenter.default.post(name: .showAbout, object: nil)
            }
            
            Divider()
            
            Button(NSLocalizedString("menu.settings", comment: "Settings...")) {
                NotificationCenter.default.post(name: .showSettings, object: nil)
            }
            .keyboardShortcut(",", modifiers: .command)
        }
        
        // Меню Файл
        CommandGroup(replacing: .newItem) {
            Button(NSLocalizedString("menu.file.new", comment: "New Document")) {
                NotificationCenter.default.post(name: .newDocument, object: nil)
            }
            .keyboardShortcut("n", modifiers: .command)
            
            Button(NSLocalizedString("menu.file.open", comment: "Open...")) {
                NotificationCenter.default.post(name: .openDocument, object: nil)
            }
            .keyboardShortcut("o", modifiers: .command)
            
            Divider()
            
            Button(NSLocalizedString("menu.file.save", comment: "Save")) {
                NotificationCenter.default.post(name: .saveDocument, object: nil)
            }
            .keyboardShortcut("s", modifiers: .command)
            
            Button(NSLocalizedString("menu.file.saveAs", comment: "Save As...")) {
                NotificationCenter.default.post(name: .saveDocumentAs, object: nil)
            }
            .keyboardShortcut("s", modifiers: [.command, .shift])
        }
        
        // Меню Правка - добавляем команды после стандартных Undo/Redo
        CommandGroup(after: .undoRedo) {
            Divider()
            
            Button(NSLocalizedString("menu.edit.cut", comment: "Cut")) {
                NotificationCenter.default.post(name: .cutSelected, object: nil)
            }
            .keyboardShortcut("x", modifiers: .command)
            
            Button(NSLocalizedString("menu.edit.copy", comment: "Copy")) {
                NotificationCenter.default.post(name: .copySelected, object: nil)
            }
            .keyboardShortcut("c", modifiers: .command)
            
            Button(NSLocalizedString("menu.edit.paste", comment: "Paste")) {
                NotificationCenter.default.post(name: .pasteSelected, object: nil)
            }
            .keyboardShortcut("v", modifiers: .command)
            
            Divider()
            
            Button(NSLocalizedString("menu.edit.delete", comment: "Delete Selected")) {
                NotificationCenter.default.post(name: .deleteSelected, object: nil)
            }
            .keyboardShortcut(.delete, modifiers: [])
            
            Button(NSLocalizedString("menu.edit.selectAll", comment: "Select All Gates")) {
                NotificationCenter.default.post(name: .selectAllGates, object: nil)
            }
            .keyboardShortcut("a", modifiers: .command)
            
            Button(NSLocalizedString("menu.edit.deselectAll", comment: "Deselect All")) {
                NotificationCenter.default.post(name: .deselectAll, object: nil)
            }
            .keyboardShortcut("d", modifiers: .command)
        }
        
        // Заменяем стандартное меню Undo/Redo нашими командами
        CommandGroup(replacing: .undoRedo) {
            Button(NSLocalizedString("menu.edit.undo", comment: "Undo")) {
                NotificationCenter.default.post(name: .undoAction, object: nil)
            }
            .keyboardShortcut("z", modifiers: .command)
            
            Button(NSLocalizedString("menu.edit.redo", comment: "Redo")) {
                NotificationCenter.default.post(name: .redoAction, object: nil)
            }
            .keyboardShortcut("z", modifiers: [.command, .shift])
            
            // Альтернативная горячая клавиша для Redo
            Button(NSLocalizedString("menu.edit.redo", comment: "Redo")) {
                NotificationCenter.default.post(name: .redoAction, object: nil)
            }
            .keyboardShortcut("y", modifiers: .command)
        }
        
        // Меню Вид - заменяем CommandMenu на CommandGroup
        CommandGroup(after: .sidebar) {
            Divider()
            
            Button(NSLocalizedString("menu.view.zoomIn", comment: "Zoom In")) {
                NotificationCenter.default.post(name: .zoomIn, object: nil)
            }
            .keyboardShortcut("+", modifiers: .command)
            
            Button(NSLocalizedString("menu.view.zoomOut", comment: "Zoom Out")) {
                NotificationCenter.default.post(name: .zoomOut, object: nil)
            }
            .keyboardShortcut("-", modifiers: .command)
            
            Button(NSLocalizedString("menu.view.zoomReset", comment: "Reset Zoom")) {
                NotificationCenter.default.post(name: .resetZoom, object: nil)
            }
            .keyboardShortcut("0", modifiers: .command)
            
            Divider()
            
            Button(NSLocalizedString("menu.view.toggleSidebar", comment: "Toggle Sidebar")) {
                NotificationCenter.default.post(name: .toggleSidebar, object: nil)
            }
            .keyboardShortcut("1", modifiers: [.command, .control])
            
            Button(NSLocalizedString("menu.view.toggleInspector", comment: "Toggle Inspector")) {
                NotificationCenter.default.post(name: .toggleInspector, object: nil)
            }
            .keyboardShortcut("2", modifiers: [.command, .control])
        }
        
        // Меню Схема
        CommandMenu(NSLocalizedString("menu.circuit", comment: "Circuit")) {
            Button(NSLocalizedString("menu.circuit.simulate", comment: "Run Simulation")) {
                NotificationCenter.default.post(name: .runSimulation, object: nil)
            }
            .keyboardShortcut("r", modifiers: .command)
            
            Divider()
            
            Button(NSLocalizedString("menu.circuit.export.json", comment: "Export as JSON...")) {
                NotificationCenter.default.post(name: .exportJSON, object: nil)
            }
            .keyboardShortcut("e", modifiers: [.command, .shift])
            
            Button(NSLocalizedString("menu.circuit.export.png", comment: "Export as PNG...")) {
                NotificationCenter.default.post(name: .exportPNG, object: nil)
            }
            .keyboardShortcut("p", modifiers: [.command, .shift])
        }
        
        // Меню Справка
        CommandMenu(NSLocalizedString("menu.help", comment: "Help")) {
            Button(NSLocalizedString("menu.help.documentation", comment: "Show Documentation")) {
                NotificationCenter.default.post(name: .showHelp, object: nil)
            }
            .keyboardShortcut("?", modifiers: [.command, .shift])
        }
    }
}

// Имена уведомлений для команд меню
extension Notification.Name {
    static let showAbout = Notification.Name("showAbout")
    static let showSettings = Notification.Name("showSettings")
    static let showHelp = Notification.Name("showHelp")
    static let newDocument = Notification.Name("newDocument")
    static let openDocument = Notification.Name("openDocument")
    static let saveDocument = Notification.Name("saveDocument")
    static let saveDocumentAs = Notification.Name("saveDocumentAs")
    static let undoAction = Notification.Name("undoAction")
    static let redoAction = Notification.Name("redoAction")
    static let cutSelected = Notification.Name("cutSelected")
    static let copySelected = Notification.Name("copySelected")
    static let pasteSelected = Notification.Name("pasteSelected")
    static let deleteSelected = Notification.Name("deleteSelected")
    static let selectAllGates = Notification.Name("selectAllGates")
    static let deselectAll = Notification.Name("deselectAll")
    static let zoomIn = Notification.Name("zoomIn")
    static let zoomOut = Notification.Name("zoomOut")
    static let resetZoom = Notification.Name("resetZoom")
    static let toggleSidebar = Notification.Name("toggleSidebar")
    static let toggleInspector = Notification.Name("toggleInspector")
    static let runSimulation = Notification.Name("runSimulation")
    static let exportJSON = Notification.Name("exportJSON")
    static let exportPNG = Notification.Name("exportPNG")
}
