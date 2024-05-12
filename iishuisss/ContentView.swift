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
            VStack(alignment: .leading) {
                Button(action: {
                    withAnimation {
                        viewModel.selectFile()
                    }
                }) {
                    Text("Выбрать файл")
                        .fontWeight(.medium)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)
                .padding(.top)

                Text("Продолжительность эксперимента: \(viewModel.experimentDuration)")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top, 5)

                List(viewModel.data, id: \.time) { item in
                    HStack {
                        Text("Время: \(item.time)")
                        Spacer()
                        Text("Напряжение: \(String(format: "%.2f", item.voltage)) V")
                        Spacer()
                        Text("Ток: \(String(format: "%.2f", item.current)) A")
                    }
                    .padding(.vertical, 4)
                }
                HStack {
                    NavigationLink(destination: SignalView(data: $viewModel.data)) {
                        Text("Показать сигналы")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(8)
                            .shadow(radius: 3)
                    }.disabled(viewModel.data.isEmpty)

                    NavigationLink(destination: SpectrumView(data: $viewModel.data)) {
                        Text("Показать спектр сигнала")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(8)
                            .shadow(radius: 3)
                    }.disabled(viewModel.data.isEmpty)

                    NavigationLink(destination: PowerView(data: $viewModel.data)) {
                        Text("Показать графики мощностей")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(8)
                            .shadow(radius: 3)
                    }.disabled(viewModel.data.isEmpty)
                }
                .padding()
            }
        }
    }
}
