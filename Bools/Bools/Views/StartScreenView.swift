//
//  StartScreenView.swift
//  Bools
//
//  Начальный экран приложения
//

import SwiftUI

struct StartScreenView: View {
    @Binding var showStartScreen: Bool
    @ObservedObject var recentFilesManager: RecentFilesManager
    @State private var hoveredFileURL: URL? = nil
    
    var onNewDocument: () -> Void
    var onOpenDocument: () -> Void
    var onOpenRecentFile: (URL) -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Левая панель - информация о приложении
            VStack(spacing: 12) {
                VStack(spacing: 6) {
                    #if os(macOS)
                    if let appIcon = NSImage(named: "AppIcon") {
                        Image(nsImage: appIcon)
                            .resizable()
                            .frame(width: 48, height: 48)
                            .cornerRadius(8)
                    } else {
                        Image(systemName: "cpu.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    #else
                    Image(systemName: "cpu.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    #endif
                    
                    Text(NSLocalizedString("startscreen.app.name", comment: ""))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(NSLocalizedString("startscreen.app.version", comment: ""))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .padding(.horizontal, 20)
                
                VStack(spacing: 8) {
                    Text(NSLocalizedString("startscreen.description.title", comment: ""))
                        .font(.headline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                    
                    Text(NSLocalizedString("startscreen.description.detail", comment: ""))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 16)
                
                Divider()
                    .padding(.horizontal, 20)
                
                VStack(spacing: 10) {
                    FeatureRow(icon: "cpu", title: NSLocalizedString("startscreen.feature.gates.title", comment: ""), description: NSLocalizedString("startscreen.feature.gates.description", comment: ""))
                    FeatureRow(icon: "arrow.triangle.branch", title: NSLocalizedString("startscreen.feature.wires.title", comment: ""), description: NSLocalizedString("startscreen.feature.wires.description", comment: ""))
                    FeatureRow(icon: "play.circle", title: NSLocalizedString("startscreen.feature.simulation.title", comment: ""), description: NSLocalizedString("startscreen.feature.simulation.description", comment: ""))
                    FeatureRow(icon: "doc.text", title: NSLocalizedString("startscreen.feature.save.title", comment: ""), description: NSLocalizedString("startscreen.feature.save.description", comment: ""))
                }
                
                Spacer()
                
                // Кнопки действий
                VStack(spacing: 8) {
                    Button(action: {
                        showStartScreen = false
                        onNewDocument()
                    }) {
                        HStack {
                            Image(systemName: "doc.badge.plus")
                            Text(NSLocalizedString("startscreen.button.new", comment: ""))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        showStartScreen = false
                        onOpenDocument()
                    }) {
                        HStack {
                            Image(systemName: "folder")
                            Text(NSLocalizedString("startscreen.button.open", comment: ""))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.secondary.opacity(0.1))
                        .foregroundColor(.primary)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 12)
            }
            .frame(maxWidth: 360)
            .padding(24)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Правая панель - недавние файлы
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(NSLocalizedString("startscreen.recent.title", comment: ""))
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    if !recentFilesManager.recentFiles.isEmpty {
                        Button(action: {
                            recentFilesManager.clearRecentFiles()
                        }) {
                            Text(NSLocalizedString("startscreen.recent.clear", comment: ""))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(NSColor.windowBackgroundColor))
                
                Divider()
                
                if recentFilesManager.recentFiles.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)
                        
                        Text(NSLocalizedString("startscreen.recent.empty.title", comment: ""))
                            .font(.callout)
                            .foregroundColor(.secondary)
                        
                        Text(NSLocalizedString("startscreen.recent.empty.description", comment: ""))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(recentFilesManager.recentFiles, id: \.self) { fileURL in
                                RecentFileRow(
                                    fileURL: fileURL,
                                    isHovered: hoveredFileURL == fileURL,
                                    onOpen: {
                                        showStartScreen = false
                                        onOpenRecentFile(fileURL)
                                    },
                                    onRemove: {
                                        recentFilesManager.removeRecentFile(fileURL)
                                    }
                                )
                                .onHover { hovering in
                                    hoveredFileURL = hovering ? fileURL : nil
                                }
                                
                                if fileURL != recentFilesManager.recentFiles.last {
                                    Divider()
                                }
                            }
                        }
                    }
                }
            }
            .frame(width: 300)
            .background(Color(NSColor.windowBackgroundColor))
        }
        .fixedSize()
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.accentColor)
                .frame(width: 16)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
    }
}

struct RecentFileRow: View {
    let fileURL: URL
    let isHovered: Bool
    let onOpen: () -> Void
    let onRemove: () -> Void
    
    @State private var fileInfo: (name: String, date: String, path: String)?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(fileInfo?.name ?? fileURL.lastPathComponent)
                    .font(.callout)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(fileInfo?.date ?? "")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text(fileInfo?.path ?? fileURL.path)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if isHovered {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help(NSLocalizedString("startscreen.recent.remove", comment: ""))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isHovered ? Color.accentColor.opacity(0.1) : Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            onOpen()
        }
        .onAppear {
            loadFileInfo()
        }
    }
    
    private func loadFileInfo() {
        do {
            let values = try fileURL.resourceValues(forKeys: [.contentModificationDateKey, .nameKey])
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            
            let name = values.name ?? fileURL.lastPathComponent
            let date = values.contentModificationDate.map { formatter.string(from: $0) } ?? ""
            let path = fileURL.deletingLastPathComponent().path
            
            fileInfo = (name: name, date: date, path: path)
        } catch {
            fileInfo = (name: fileURL.lastPathComponent, date: "", path: fileURL.path)
        }
    }
}
