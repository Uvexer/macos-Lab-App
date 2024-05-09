//
//  SignalView.swift
//  iishuisss
//
//  Created by Bogdan Chupakhin on 06.05.2024.
//

import SwiftUI

struct SignalView: View {
    var data: [(time: Int, voltage: Double, current: Double)]
    var body: some View {
        VStack {
            GeometryReader { geometry in
                let maxTime = CGFloat(data.last?.time ?? 1)
                let maxVoltage = data.max(by: { $0.voltage < $1.voltage })?.voltage ?? 1
                let maxCurrent = data.max(by: { $0.current < $1.current })?.current ?? 1
                
                let scaleX = geometry.size.width / maxTime
                let scaleYVoltage = geometry.size.height / CGFloat(maxVoltage)
                let scaleYCurrent = geometry.size.height / CGFloat(maxCurrent)

                ZStack(alignment: .bottomLeading) {
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

                    // Axes labels
                //    Text("Time (s)").font(.caption).position(x: geometry.size.width / 2, y: geometry.size.height + 15)
                  //  Text("Amplitude").font(.caption).rotationEffect(.degrees(-90)).position(x: -20, y: geometry.size.height / 2)
                }
            }

            Text("Voltage and Current Graph").font(.headline)
        }
    }
}
