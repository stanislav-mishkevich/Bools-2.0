import SwiftUI

struct GridView: View {
    var spacing: CGFloat = 32
    var lineWidth: CGFloat = 0.5
    var color: Color = .secondary.opacity(0.18)
    var panOffset: CGSize = .zero
    var zoom: CGFloat = 1.0

    var body: some View {
        GeometryReader { geo in
            Path { path in
                // size in world coordinates
                let w = max(geo.size.width, 2000)
                let h = max(geo.size.height, 2000)
                // compute world-aligned offset so grid appears stable when panning/zooming
                let worldOffsetX = -panOffset.width / max(zoom, 0.0001)
                let worldOffsetY = -panOffset.height / max(zoom, 0.0001)

                let halfW = w * 2
                let halfH = h * 2

                // find starting x aligned to spacing
                let startX = CGFloat(fmod(Double(-halfW + worldOffsetX), Double(spacing))) - worldOffsetX
                var x = -halfW + startX
                while x <= halfW {
                    path.move(to: CGPoint(x: x, y: -halfH))
                    path.addLine(to: CGPoint(x: x, y: halfH))
                    x += spacing
                }

                let startY = CGFloat(fmod(Double(-halfH + worldOffsetY), Double(spacing))) - worldOffsetY
                var y = -halfH + startY
                while y <= halfH {
                    path.move(to: CGPoint(x: -halfW, y: y))
                    path.addLine(to: CGPoint(x: halfW, y: y))
                    y += spacing
                }
            }
            .stroke(color, lineWidth: lineWidth)
        }
    }
}
