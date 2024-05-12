import SwiftUI
import Accelerate

struct SignalView: View {
    @Binding var data: [(time: Int, voltage: Double, current: Double)]

    var body: some View {
        VStack {
            GeometryReader { geometry in
                let maxTime = CGFloat(data.last?.time ?? 1)
                let maxVoltage = data.max(by: { $0.voltage < $1.voltage })?.voltage ?? 1
                let maxCurrent = data.max(by: { $0.current < $1.current })?.current ?? 1
                
                let scaleX = geometry.size.width / maxTime
                let scaleYVoltage = geometry.size.height / CGFloat(maxVoltage)
                let scaleYCurrent = geometry.size.height / CGFloat(maxCurrent)

                ZStack {
                    // Grid
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

                    // Voltage path
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

                    // Current path
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
                .clipped()

         
                }
            }
            Text("Voltage and Current Graph").padding().font(.title)
        }
    }



