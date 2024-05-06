import SwiftUI
import Accelerate
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
