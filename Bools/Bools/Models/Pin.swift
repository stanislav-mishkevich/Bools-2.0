import Foundation
import CoreGraphics

enum PinType: String, Codable {
    case input, output
}

struct Pin: Identifiable, Codable {
    let id: UUID
    let type: PinType
    var value: Bool
    /// Смещение относительно начала гейта, в пунктах
    var offset: CGPoint
    /// Метка пина (например, "+", "-", "COM", "NO", "NC")
    var label: String?

    init(id: UUID = UUID(), type: PinType, value: Bool = false, offset: CGPoint = .zero, label: String? = nil) {
        self.id = id
        self.type = type
        self.value = value
        self.offset = offset
        self.label = label
    }
}
