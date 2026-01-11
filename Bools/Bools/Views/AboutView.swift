//
//  AboutView.swift
//  Bools 2.0
//
//  About window with developer info
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            // App Icon
            #if os(macOS)
            if let appIcon = NSImage(named: "AppIcon") {
                Image(nsImage: appIcon)
                    .resizable()
                    .frame(width: 80, height: 80)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    .padding(.top, 16)
            } else {
                Image(systemName: "cpu.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(.top, 16)
            }
            #else
            Image(systemName: "cpu.fill")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(.top, 16)
            #endif
            
            // App Name
            Text(NSLocalizedString("about.app.name", comment: ""))
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)
            
            // Version
            Text(NSLocalizedString("about.version", comment: ""))
                .font(.system(.caption, design: .rounded))
                .foregroundColor(.secondary)
            
            Divider()
                .padding(.horizontal, 30)
            
            // Description
            VStack(spacing: 6) {
                Text(NSLocalizedString("about.description.title", comment: ""))
                    .font(.system(.callout, design: .rounded))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(NSLocalizedString("about.description.detail", comment: ""))
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            .padding(.horizontal, 24)
            
            Divider()
                .padding(.horizontal, 30)
            
            // Developer Info
            VStack(spacing: 4) {
                Text(NSLocalizedString("about.developer.title", comment: ""))
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                
                Text(NSLocalizedString("about.developer.name", comment: ""))
                    .font(.system(.callout, design: .rounded))
                    .fontWeight(.semibold)
                
                // GitHub link
                Link(destination: URL(string: "https://github.com/stanislav-mishkevich")!) {
                    HStack(spacing: 3) {
                        Image(systemName: "link.circle.fill")
                            .font(.system(size: 10))
                        Text("github.com/stanislav-mishkevich")
                            .font(.system(.caption2, design: .rounded))
                    }
                    .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                
                Text(NSLocalizedString("about.year", comment: ""))
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 12)
            
            // Close button
            Button(NSLocalizedString("about.ok", comment: "")) {
                dismiss()
            }
            .keyboardShortcut(.defaultAction)
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
            .padding(.bottom, 16)
        }
        .frame(width: 320, height: 420)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    AboutView()
}
