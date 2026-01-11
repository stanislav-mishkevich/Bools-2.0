import Foundation
import CoreGraphics

struct Wire: Identifiable, Codable {
    let id: UUID
    let fromGateID: UUID
    let fromPinIndex: Int
    let toGateID: UUID
    let toPinIndex: Int
    var signal: Bool = false

    init(id: UUID = UUID(), fromGateID: UUID, fromPinIndex: Int, toGateID: UUID, toPinIndex: Int) {
        self.id = id
        self.fromGateID = fromGateID
        self.fromPinIndex = fromPinIndex
        self.toGateID = toGateID
        self.toPinIndex = toPinIndex
    }
}
