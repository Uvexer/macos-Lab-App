import SwiftUI

struct CurrentPath: View {
    let data: [DataPoint]
    let maxCurrent: Double
    let scaleX: CGFloat
    let geometry: GeometryProxy

    var body: some View {
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

