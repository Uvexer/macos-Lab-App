import SwiftUI
import Accelerate

struct PowerView: View {
    var data: [(time: Int, voltage: Double, current: Double)]

    var body: some View {
        VStack {
            GeometryReader { geometry in
                let maxTime = CGFloat(data.last?.time ?? 1)
                let scaleX = geometry.size.width / maxTime

                let powers = data.map { $0.voltage * $0.current }
                let maxY = powers.max() ?? 1
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
                
          //      Text("Time (s)").font(.caption).position(x: geometry.size.width / 2, y: geometry.size.height + 15)
            //    Text("Power (W)").font(.caption).rotationEffect(.degrees(-90)).position(x: -20, y: geometry.size.height / 2)
            }

            Text("Instantaneous Power Graph").font(.headline)
        }
    }
}
