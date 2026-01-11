//
//  HelpView.swift
//  Bools
//
//  Справка и документация приложения
//

import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab: String = "quickStart"
    
    var body: some View {
        VStack(spacing: 0) {
            // Заголовок
            HStack {
                Text(NSLocalizedString("menu.help.documentation", comment: ""))
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help("Close")
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .border(Color(NSColor.separatorColor), width: 1)
            
            // Содержание
            HStack(spacing: 0) {
                // Боковая панель навигации
                VStack(alignment: .leading, spacing: 0) {
                    NavigationSection(
                        title: NSLocalizedString("help.section.gettingStarted", comment: "Getting Started"),
                        items: [
                            ("quickStart", NSLocalizedString("help.quickStart", comment: "Quick Start")),
                            ("basics", NSLocalizedString("help.basics", comment: "Basics")),
                            ("interface", NSLocalizedString("help.interface", comment: "Interface"))
                        ],
                        selectedTab: $selectedTab
                    )
                    
                    NavigationSection(
                        title: NSLocalizedString("help.section.components", comment: "Components"),
                        items: [
                            ("gates", NSLocalizedString("help.logicGates", comment: "Logic Gates")),
                            ("physical", NSLocalizedString("help.physicalComponents", comment: "Physical Components")),
                            ("transistors", NSLocalizedString("help.transistors", comment: "Transistors"))
                        ],
                        selectedTab: $selectedTab
                    )
                    
                    NavigationSection(
                        title: NSLocalizedString("help.section.advanced", comment: "Advanced"),
                        items: [
                            ("circuits", NSLocalizedString("help.circuits", comment: "Circuits")),
                            ("simulation", NSLocalizedString("help.simulation", comment: "Simulation")),
                            ("examples", NSLocalizedString("help.examples", comment: "Examples"))
                        ],
                        selectedTab: $selectedTab
                    )
                    
                    Spacer()
                }
                .frame(width: 200)
                .background(Color(NSColor.controlBackgroundColor))
                .border(Color(NSColor.separatorColor), width: 1)
                
                // Основное содержание
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        switch selectedTab {
                        case "quickStart":
                            quickStartContent
                        case "basics":
                            basicsContent
                        case "interface":
                            interfaceContent
                        case "gates":
                            gatesContent
                        case "physical":
                            physicalContent
                        case "transistors":
                            transistorsContent
                        case "circuits":
                            circuitsContent
                        case "simulation":
                            simulationContent
                        case "examples":
                            examplesContent
                        default:
                            quickStartContent
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .frame(maxHeight: .infinity)
            }
        }
        .frame(minWidth: 900, minHeight: 600)
    }
    
    // MARK: - Содержание вкладок
    
    @ViewBuilder
    private var quickStartContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("help.quickStart.title", comment: ""))
                .font(.title2)
                .fontWeight(.bold)
            
            Text(NSLocalizedString("help.quickStart.content", comment: ""))
                .lineSpacing(6)
            
            VStack(alignment: .leading, spacing: 8) {
                HelpStep(number: 1, title: NSLocalizedString("help.step1", comment: ""), description: NSLocalizedString("help.step1.desc", comment: ""))
                HelpStep(number: 2, title: NSLocalizedString("help.step2", comment: ""), description: NSLocalizedString("help.step2.desc", comment: ""))
                HelpStep(number: 3, title: NSLocalizedString("help.step3", comment: ""), description: NSLocalizedString("help.step3.desc", comment: ""))
                HelpStep(number: 4, title: NSLocalizedString("help.step4", comment: ""), description: NSLocalizedString("help.step4.desc", comment: ""))
            }
        }
    }
    
    @ViewBuilder
    private var basicsContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("help.basics.title", comment: ""))
                .font(.title2)
                .fontWeight(.bold)
            
            Text(NSLocalizedString("help.basics.content", comment: ""))
                .lineSpacing(6)
        }
    }
    
    @ViewBuilder
    private var interfaceContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("help.interface.title", comment: ""))
                .font(.title2)
                .fontWeight(.bold)
            
            Text(NSLocalizedString("help.interface.content", comment: ""))
                .lineSpacing(6)
        }
    }
    
    @ViewBuilder
    private var gatesContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("help.logicGates.title", comment: ""))
                .font(.title2)
                .fontWeight(.bold)
            
            Text(NSLocalizedString("help.logicGates.content", comment: ""))
                .lineSpacing(6)
        }
    }
    
    @ViewBuilder
    private var physicalContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("help.physicalComponents.title", comment: ""))
                .font(.title2)
                .fontWeight(.bold)
            
            Text(NSLocalizedString("help.physicalComponents.content", comment: ""))
                .lineSpacing(6)
        }
    }
    
    @ViewBuilder
    private var transistorsContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("help.transistors.title", comment: ""))
                .font(.title2)
                .fontWeight(.bold)
            
            Text(NSLocalizedString("help.transistors.content", comment: ""))
                .lineSpacing(6)
        }
    }
    
    @ViewBuilder
    private var circuitsContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("help.circuits.title", comment: ""))
                .font(.title2)
                .fontWeight(.bold)
            
            Text(NSLocalizedString("help.circuits.content", comment: ""))
                .lineSpacing(6)
        }
    }
    
    @ViewBuilder
    private var simulationContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("help.simulation.title", comment: ""))
                .font(.title2)
                .fontWeight(.bold)
            
            Text(NSLocalizedString("help.simulation.content", comment: ""))
                .lineSpacing(6)
        }
    }
    
    @ViewBuilder
    private var examplesContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("help.examples.title", comment: ""))
                .font(.title2)
                .fontWeight(.bold)
            
            Text(NSLocalizedString("help.examples.content", comment: ""))
                .lineSpacing(6)
        }
    }
}

// MARK: - Компоненты

struct NavigationSection: View {
    let title: String
    let items: [(String, String)]
    @Binding var selectedTab: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            
            ForEach(items, id: \.0) { id, name in
                Button(action: { selectedTab = id }) {
                    Text(name)
                        .font(.callout)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedTab == id ? Color.accentColor.opacity(0.2) : Color.clear)
                        .foregroundStyle(selectedTab == id ? Color.accentColor : Color.primary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct HelpStep: View {
    let number: Int
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.accentColor)
                .frame(width: 24, height: 24)
                .overlay(
                    Text("\(number)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.callout)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    HelpView()
}
