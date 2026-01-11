import Foundation

/// Сериализуемая структура данных рабочего пространства для операций сохранения и загрузки
struct WorkspaceData: Codable {
    let gates: [Gate]
    let wires: [Wire]
    
    init(gates: [Gate], wires: [Wire]) {
        self.gates = gates
        self.wires = wires
    }
}
