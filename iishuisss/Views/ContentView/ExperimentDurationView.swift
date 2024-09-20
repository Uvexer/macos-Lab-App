import SwiftUI

struct ExperimentDurationView: View {
    let duration: String

    var body: some View {
        Text("Продолжительность эксперимента: \(duration)")
            .font(.headline)
            .padding(.horizontal)
            .padding(.top, 5)
    }
}

