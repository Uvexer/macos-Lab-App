import SwiftUI

class ViewModel: ObservableObject {
    @Published var filePath: String = ""
    @Published var experimentDuration: String = ""
    @Published var data: [DataPoint] = []

    private let fileHandler = FileHandler()
    private let csvParser = CSVParser()
    private let durationCalculator = ExperimentDurationCalculator()
    private let fftCalculator = FFTCalculator()

    func selectFile() {
        fileHandler.selectFile { [weak self] url in
            self?.filePath = url.path
            self?.loadFileContents(at: url)
        }
    }

    private func loadFileContents(at url: URL) {
        fileHandler.loadFileContents(at: url) { [weak self] contents in
            self?.parseCSV(contents)
        }
    }

    private func parseCSV(_ csvData: String) {
        data = csvParser.parseCSV(csvData)
        if data.isEmpty {
            print("Data parsed is empty")
        } else {
            calculateExperimentDuration()
        }
    }

    private func calculateExperimentDuration() {
        experimentDuration = durationCalculator.calculateExperimentDuration(from: data)
    }

    func computeFFT(_ signal: [Double]) -> [Double] {
        return fftCalculator.computeFFT(signal)
    }
}

