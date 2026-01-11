//
//  CloseConfirmationModifier.swift
//  Bools
//
//  Модификатор для отображения диалога подтверждения при закрытии окна
//

import SwiftUI

#if os(macOS)
import AppKit

struct CloseConfirmationModifier: ViewModifier {
    @ObservedObject var viewModel: WorkspaceViewModel
    var onSave: () -> Void
    var onDiscard: () -> Void
    
    func body(content: Content) -> some View {
        content
            .background(WindowAccessor(viewModel: viewModel, onSave: onSave, onDiscard: onDiscard))
    }
}

struct WindowAccessor: NSViewRepresentable {
    @ObservedObject var viewModel: WorkspaceViewModel
    var onSave: () -> Void
    var onDiscard: () -> Void
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        
        DispatchQueue.main.async {
            if let window = view.window {
                context.coordinator.setupWindow(window)
            }
        }
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        if context.coordinator.window == nil, let window = nsView.window {
            context.coordinator.setupWindow(window)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel, onSave: onSave, onDiscard: onDiscard)
    }
    
    class Coordinator: NSObject, NSWindowDelegate {
        var window: NSWindow?
        var viewModel: WorkspaceViewModel
        var onSave: () -> Void
        var onDiscard: () -> Void
        
        init(viewModel: WorkspaceViewModel, onSave: @escaping () -> Void, onDiscard: @escaping () -> Void) {
            self.viewModel = viewModel
            self.onSave = onSave
            self.onDiscard = onDiscard
        }
        
        func setupWindow(_ window: NSWindow) {
            guard self.window == nil else { return }
            self.window = window
            window.delegate = self
        }
        
        func windowShouldClose(_ sender: NSWindow) -> Bool {
            // Если нет несохраненных изменений, разрешаем закрытие
            guard viewModel.hasUnsavedChanges else {
                return true
            }
            
            // Показываем диалог подтверждения
            let alert = NSAlert()
            alert.messageText = NSLocalizedString("close.confirm.title", comment: "")
            alert.informativeText = NSLocalizedString("close.confirm.message", comment: "")
            alert.alertStyle = .warning
            alert.addButton(withTitle: NSLocalizedString("close.confirm.save", comment: ""))
            alert.addButton(withTitle: NSLocalizedString("close.confirm.discard", comment: ""))
            alert.addButton(withTitle: NSLocalizedString("close.confirm.cancel", comment: ""))
            
            let response = alert.runModal()
            
            switch response {
            case .alertFirstButtonReturn:
                // Сохранить
                onSave()
                // Если после сохранения все еще есть несохраненные изменения,
                // значит пользователь отменил сохранение - не закрываем окно
                return !viewModel.hasUnsavedChanges
                
            case .alertSecondButtonReturn:
                // Не сохранять
                onDiscard()
                return true
                
            default:
                // Отменить
                return false
            }
        }
    }
}

extension View {
    func closeConfirmation(viewModel: WorkspaceViewModel, onSave: @escaping () -> Void, onDiscard: @escaping () -> Void) -> some View {
        self.modifier(CloseConfirmationModifier(viewModel: viewModel, onSave: onSave, onDiscard: onDiscard))
    }
}
#endif
