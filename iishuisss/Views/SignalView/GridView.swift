import SwiftUI

struct GridView: View {
    let maxTime: CGFloat
    let maxVoltage: Double
    let scaleX: CGFloat
    let scaleYVoltage: CGFloat
    let geometry: GeometryProxy

    var body: some View {
        ZStack {
            ForEach(0..<Int(maxTime), id: \.self) { x in
                Path { path in
                    let xPosition = CGFloat(x) * scaleX
                    path.move(to: CGPoint(x: xPosition, y: 0))
                    path.addLine(to: CGPoint(x: xPosition, y: geometry.size.height))
                }
                .stroke(Color.gray.opacity(0.3))
            }

            ForEach(0..<Int(maxVoltage / 10), id: \.self) { y in
                Path { path in
                    let yPosition = CGFloat(y * 10) * scaleYVoltage
                    path.move(to: CGPoint(x: 0, y: yPosition))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: yPosition))
                }
                .stroke(Color.gray.opacity(0.3))
            }
        }
    }
}

