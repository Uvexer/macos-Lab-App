import SwiftUI
import Accelerate
struct ContentView: View {
    @State private var filePath: String = ""
    @State private var experimentDuration: String = ""
    @State private var data: [(time: Int, voltage: Double, current: Double)] = []

    var body: some View {
        NavigationView {
            VStack {
                Button("Выбрать файл") {
                    selectFile()
                }
                Text("Продолжительность эксперимента: \(experimentDuration)")
                List(data, id: \.time) { item in
                    Text("Время: \(item.time), Напряжение: \(item.voltage), Ток: \(item.current)")
                }
                HStack {
                    NavigationLink(destination: SignalView(data: data)) {
                        Text("Показать сигналы")
                    }.disabled(data.isEmpty)

                    NavigationLink(destination: SpectrumView(data: data)) {
                        Text("Показать спектр сигнала")
                    }.disabled(data.isEmpty)
                    
                    NavigationLink(destination: PowerView(data: data)) {
                        Text("Показать графики мощностей")
                    }.disabled(data.isEmpty)
                }
            }
            .padding()
        }
    }

    func selectFile() {
        // Assuming using NSOpenPanel here is part of a macOS app.
        let dialog = NSOpenPanel()
        dialog.title = "Выберите CSV файл"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseDirectories = false
        dialog.canChooseFiles = true
        dialog.allowedContentTypes = [.commaSeparatedText] // Use correct content types
        
        if dialog.runModal() == .OK {
            if let url = dialog.url {
                filePath = url.path
                loadFileContents(at: url)
            }
        }
    }
    
    func loadFileContents(at url: URL) {
        do {
            let contents = try String(contentsOf: url)
            parseCSV(contents)
        } catch {
            print("Error reading file: \(error)")
            // Consider showing an alert or updating the UI to reflect the error
        }
    }
    func parseCSV(_ csvData: String) {
        let rows = csvData.components(separatedBy: "\n")
        data = rows.compactMap { row in
            let columns = row.split(separator: ",").map(String.init)
            if columns.count == 3,
               let time = Int(columns[0]),
               let voltage = Double(columns[1]),
               let current = Double(columns[2]) {
                return (time: time, voltage: voltage, current: current)
            }
            return nil
        }
        if data.isEmpty {
            print("Data parsed is empty")
        } else {
            calculateExperimentDuration()
        }
    }
    func calculateExperimentDuration() {
        guard let firstTime = data.first?.time, let lastTime = data.last?.time else {
            experimentDuration = "Неизвестно"
            return
        }
        let durationSeconds = lastTime - firstTime
        let hours = durationSeconds / 3600
        let minutes = (durationSeconds % 3600) / 60
        let seconds = (durationSeconds % 3600) % 60
        experimentDuration = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
