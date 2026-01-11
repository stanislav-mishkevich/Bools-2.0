import SwiftUI

struct ResizableDivider: View {
    @Binding var width: CGFloat
    let minWidth: CGFloat
    let maxWidth: CGFloat
    let isTrailing: Bool
    
    @State private var isDragging = false
    @State private var dragStartWidth: CGFloat = 0
    
    init(width: Binding<CGFloat>, minWidth: CGFloat, maxWidth: CGFloat, isTrailing: Bool = false) {
        self._width = width
        self.minWidth = minWidth
        self.maxWidth = maxWidth
        self.isTrailing = isTrailing
    }
    
    var body: some View {
        Rectangle()
            .fill(isDragging ? Color.accentColor.opacity(0.3) : Color.secondary.opacity(0.12))
            .frame(width: 1)
            .overlay(
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 8)
                    .contentShape(Rectangle())
            )
            .onHover { hovering in
                if hovering {
                    #if os(macOS)
                    NSCursor.resizeLeftRight.push()
                    #endif
                } else {
                    #if os(macOS)
                    NSCursor.pop()
                    #endif
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                            dragStartWidth = width
                        }
                        let delta = isTrailing ? -value.translation.width : value.translation.width
                        let newWidth = dragStartWidth + delta
                        width = min(max(newWidth, minWidth), maxWidth)
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
    }
}
