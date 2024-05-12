import SwiftUI
import Accelerate

class ViewModel: ObservableObject {
    @Published var filePath: String = ""
    @Published var experimentDuration: String = ""
    @Published var data: [(time: Int, voltage: Double, current: Double)] = []
    
    func selectFile() {
        let dialog = NSOpenPanel()
        dialog.title = "Выберите CSV файл"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseDirectories = false
        dialog.canChooseFiles = true
        dialog.allowedContentTypes = [.commaSeparatedText]
        
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

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        NavigationView {
            VStack {
                Button("Выбрать файл") {
                    viewModel.selectFile()
                }
                Text("Продолжительность эксперимента: \(viewModel.experimentDuration)")
                List(viewModel.data, id: \.time) { item in
                    Text("Время: \(item.time), Напряжение: \(item.voltage), Ток: \(item.current)")
                }
                HStack {
                    NavigationLink(destination: SignalView(data: viewModel.data)) {
                        Text("Показать сигналы")
                    }.disabled(viewModel.data.isEmpty)

                    NavigationLink(destination: SpectrumView(data: viewModel.data)) {
                        Text("Показать спектр сигнала")
                    }.disabled(viewModel.data.isEmpty)
                    
                    NavigationLink(destination: PowerView(data: viewModel.data)) {
                        Text("Показать графики мощностей")
                    }.disabled(viewModel.data.isEmpty)
                }
            }
            .padding()
        }
    }
}

