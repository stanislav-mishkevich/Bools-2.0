//
//  SettingsView.swift
//  Bools 2.0
//
//  Settings window for application preferences
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("gridSize") private var gridSize: Double = 20
    @AppStorage("showGrid") private var showGrid: Bool = true
    @AppStorage("snapToGrid") private var snapToGrid: Bool = true
    @AppStorage("autoSave") private var autoSave: Bool = false
    @AppStorage("theme") private var theme: String = "system"
    @AppStorage("buzzerSoundEnabled") private var buzzerSoundEnabled: Bool = true
    @AppStorage("buzzerSoundType") private var buzzerSoundType: String = "beep"
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(.top, 20)
                
                Text(NSLocalizedString("settings.title", comment: "Settings"))
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
            }
            .padding(.bottom, 20)
            
            Divider()
            
            // Settings content
            Form {
                // Grid Settings Section
                Section {
                    Toggle(NSLocalizedString("settings.grid.show", comment: "Show Grid"), isOn: $showGrid)
                        .toggleStyle(.switch)
                    
                    Toggle(NSLocalizedString("settings.grid.snap", comment: "Snap to Grid"), isOn: $snapToGrid)
                        .toggleStyle(.switch)
                        .disabled(!showGrid)
                    
                    HStack {
                        Text(NSLocalizedString("settings.grid.size", comment: "Grid Size"))
                        Spacer()
                        Slider(value: $gridSize, in: 10...40, step: 5)
                            .frame(maxWidth: 150)
                        Text("\(Int(gridSize))")
                            .foregroundColor(.secondary)
                            .frame(width: 30)
                            .monospacedDigit()
                    }
                    .disabled(!showGrid)
                } header: {
                    Label(NSLocalizedString("settings.section.grid", comment: "Grid"), systemImage: "square.grid.2x2")
                        .font(.system(.headline, design: .rounded))
                }
                
                // General Settings Section
                Section {
                    Toggle(NSLocalizedString("settings.general.autosave", comment: "Auto-save"), isOn: $autoSave)
                        .toggleStyle(.switch)
                    
                    Picker(NSLocalizedString("settings.general.theme", comment: "Theme"), selection: $theme) {
                        Text(NSLocalizedString("settings.theme.system", comment: "System")).tag("system")
                        Text(NSLocalizedString("settings.theme.light", comment: "Light")).tag("light")
                        Text(NSLocalizedString("settings.theme.dark", comment: "Dark")).tag("dark")
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Label(NSLocalizedString("settings.section.general", comment: "General"), systemImage: "slider.horizontal.3")
                        .font(.system(.headline, design: .rounded))
                }
                
                // Sound Settings Section
                Section {
                    Toggle(NSLocalizedString("settings.sound.buzzer", comment: "Buzzer Sound"), isOn: $buzzerSoundEnabled)
                        .toggleStyle(.switch)
                    
                    Picker(NSLocalizedString("settings.sound.type", comment: "Sound Type"), selection: $buzzerSoundType) {
                        Text(NSLocalizedString("settings.sound.beep", comment: "Beep")).tag("beep")
                        Text(NSLocalizedString("settings.sound.alarm", comment: "Alarm")).tag("alarm")
                        Text(NSLocalizedString("settings.sound.tone", comment: "Tone")).tag("tone")
                    }
                    .pickerStyle(.segmented)
                    .disabled(!buzzerSoundEnabled)
                } header: {
                    Label(NSLocalizedString("settings.section.sound", comment: "Sound"), systemImage: "speaker.wave.2")
                        .font(.system(.headline, design: .rounded))
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            
            Divider()
            
            // Footer with Close button
            HStack {
                Spacer()
                Button(NSLocalizedString("settings.close", comment: "Close")) {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 500, height: 450)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    SettingsView()
}
