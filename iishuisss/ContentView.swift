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

struct SignalView: View {
    var data: [(time: Int, voltage: Double, current: Double)]
    var body: some View {
        GeometryReader { geometry in
            let maxTime = CGFloat(data.last?.time ?? 1) // Assuming time is ordered and increases
            let maxVoltage = data.max(by: { $0.voltage < $1.voltage })?.voltage ?? 1
            let maxCurrent = data.max(by: { $0.current < $1.current })?.current ?? 1
            
            let scaleX = geometry.size.width / maxTime
            let scaleYVoltage = geometry.size.height / CGFloat(maxVoltage)
            let scaleYCurrent = geometry.size.height / CGFloat(maxCurrent)

            Path { path in
                var firstPoint = true
                for point in data {
                    let xPosition = CGFloat(point.time) * scaleX
                    let yPositionVoltage = (1 - CGFloat(point.voltage / maxVoltage)) * geometry.size.height

                    if firstPoint {
                        path.move(to: CGPoint(x: xPosition, y: yPositionVoltage))
                        firstPoint = false
                    } else {
                        path.addLine(to: CGPoint(x: xPosition, y: yPositionVoltage))
                    }
                }
            }
            .stroke(Color.blue, lineWidth: 2)

            Path { path in
                var firstPoint = true
                for point in data {
                    let xPosition = CGFloat(point.time) * scaleX
                    let yPositionCurrent = (1 - CGFloat(point.current / maxCurrent)) * geometry.size.height

                    if firstPoint {
                        path.move(to: CGPoint(x: xPosition, y: yPositionCurrent))
                        firstPoint = false
                    } else {
                        path.addLine(to: CGPoint(x: xPosition, y: yPositionCurrent))
                    }
                }
            }
            .stroke(Color.red, lineWidth: 2)
        }
    }
}
import Accelerate

struct SpectrumView: View {
    var data: [(time: Int, voltage: Double, current: Double)]

    var body: some View {
        let fftResult = computeFFT(data.map { $0.voltage })
        let maxFrequency = fftResult.max() ?? 1

        return GeometryReader { geometry in
            Path { path in
                let scaleX = geometry.size.width / CGFloat(fftResult.count)
                let scaleY = geometry.size.height / CGFloat(maxFrequency)
                
                for (index, amplitude) in fftResult.enumerated() {
                    let xPosition = CGFloat(index) * scaleX
                    let yPosition = (1 - CGFloat(amplitude / maxFrequency)) * geometry.size.height
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: xPosition, y: yPosition))
                    } else {
                        path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                    }
                }
            }
            .stroke(Color.green, lineWidth: 2)
        }
    }

    func computeFFT(_ signal: [Double]) -> [Double] {
        let n = signal.count
        var real = signal
        var imaginary = [Double](repeating: 0.0, count: n)
        var magnitudes = [Double](repeating: 0.0, count: n/2)

        real.withUnsafeMutableBufferPointer { realPtr in
            imaginary.withUnsafeMutableBufferPointer { imagPtr in
                var splitComplex = DSPDoubleSplitComplex(realp: realPtr.baseAddress!, imagp: imagPtr.baseAddress!)

                let log2n = vDSP_Length(log2(Float(n)))
                if let fftSetup = vDSP_create_fftsetupD(log2n, FFTRadix(kFFTRadix2)) {
                    vDSP_fft_zipD(fftSetup, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))
                    vDSP_zvmagsD(&splitComplex, 1, &magnitudes, 1, vDSP_Length(n / 2))
                    vDSP_destroy_fftsetupD(fftSetup)
                }
            }
        }

        return magnitudes.map { sqrt($0) }
    }
}

struct PowerView: View {
    var data: [(time: Int, voltage: Double, current: Double)]

    var body: some View {
        GeometryReader { geometry in
            let maxTime = CGFloat(data.last?.time ?? 1)
            let scaleX = geometry.size.width / maxTime

            let powers = data.map { $0.voltage * $0.current }
            let activePower = powers.reduce(0, +) / Double(powers.count)
            let apparentPower = sqrt(powers.map { $0 * $0 }.reduce(0, +) / Double(powers.count))
            let reactivePower = sqrt(abs(apparentPower * apparentPower - activePower * activePower))

            let maxY = max(powers.max() ?? 1, apparentPower, activePower, reactivePower)
            let scaleY = geometry.size.height / maxY

            Path { path in
                var firstPoint = true
                for (index, power) in powers.enumerated() {
                    let xPosition = CGFloat(index) * scaleX
                    let yPosition = (1 - CGFloat(power / maxY)) * geometry.size.height

                    if firstPoint {
                        path.move(to: CGPoint(x: xPosition, y: yPosition))
                        firstPoint = false
                    } else {
                        path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                    }
                }
            }
            .stroke(Color.orange, lineWidth: 2)
            .onAppear { print("Drawing instant power graph") } // Debug

            // Add labels
            VStack {
                Spacer()
                HStack {
                    
                    Spacer()
                  
                }
            }
        }
        .navigationTitle("Power Graphs")
        .padding()
    }
}


