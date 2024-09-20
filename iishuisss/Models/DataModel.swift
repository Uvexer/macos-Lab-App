import Foundation

struct DataPoint: Identifiable {
    let id = UUID()
    let time: Int
    let voltage: Double
    let current: Double
}

