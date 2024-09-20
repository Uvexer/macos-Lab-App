import SwiftUI

struct SignalView: View {
    @Binding var data: [DataPoint]

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
                    GridView(maxTime: maxTime, maxVoltage: maxVoltage, scaleX: scaleX, scaleYVoltage: scaleYVoltage, geometry: geometry)

                    VoltagePath(data: data, maxVoltage: maxVoltage, scaleX: scaleX, geometry: geometry)

                    CurrentPath(data: data, maxCurrent: maxCurrent, scaleX: scaleX, geometry: geometry)
                }
                .clipped()
            }
            Text("Voltage and Current Graph")
                .padding()
                .font(.title)
        }
    }
}

