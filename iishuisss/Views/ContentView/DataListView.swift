import SwiftUI

struct DataListView: View {
    let data: [DataItem]

    var body: some View {
        List(data) { item in
            HStack {
                Text("Время: \(item.time)")
                Spacer()
                Text("Напряжение: \(formatValue(item.voltage)) V")
                Spacer()
                Text("Ток: \(formatValue(item.current)) A")
            }
            .padding(.vertical, 4)
        }
    }

    private func formatValue(_ value: Double) -> String {
        String(format: "%.2f", value)
    }
}

