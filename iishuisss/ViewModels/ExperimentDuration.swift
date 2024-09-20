import SwiftUI

class ExperimentDurationCalculator {
    func calculateExperimentDuration(from data: [DataPoint]) -> String {
        guard let firstTime = data.first?.time, let lastTime = data.last?.time else {
            return "Неизвестно"
        }
        let durationSeconds = lastTime - firstTime
        let hours = durationSeconds / 3600
        let minutes = (durationSeconds % 3600) / 60
        let seconds = (durationSeconds % 3600) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

