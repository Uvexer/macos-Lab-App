import SwiftUI

struct VoltagePath: View {
    let data: [DataPoint]
    let maxVoltage: Double
    let scaleX: CGFloat
    let geometry: GeometryProxy

    var body: some View {
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
    }
}

