import SwiftUI

struct NavigationButtonsView: View {
    let data: [DataPoint]
    let computeFFT: ([Double]) -> [Double]

    var body: some View {
        HStack {
            NavigationLink(destination: SignalView(data: .constant(data))) {
                Text("Показать сигналы")
                    .foregroundColor(.white)
                    .padding()
                    .cornerRadius(8)
                    .shadow(radius: 3)
            }.disabled(data.isEmpty)

            NavigationLink(destination: SpectrumView(data: .constant(data), computeFFT: computeFFT)) {
                Text("Показать спектр сигнала")
                    .foregroundColor(.white)
                    .padding()
                    .cornerRadius(8)
                    .shadow(radius: 3)
            }.disabled(data.isEmpty)

            NavigationLink(destination: PowerView(data: .constant(data))) {
                Text("Показать графики мощностей")
                    .foregroundColor(.white)
                    .padding()
                    .cornerRadius(8)
                    .shadow(radius: 3)
            }.disabled(data.isEmpty)
        }
        .padding()
    }
}

