import SwiftUI

struct SpectrumView: View {
    @Binding var data: [DataPoint]
    var computeFFT: ([Double]) -> [Double]

    var body: some View {
        VStack {
            GeometryReader { geometry in
                let fftResult = computeFFT(data.map { $0.voltage }) 
                let maxFrequency = fftResult.max() ?? 1
                let scaleX = geometry.size.width / CGFloat(fftResult.count)

                Path { path in
                    for (index, amplitude) in fftResult.enumerated() {
                        let xPosition = CGFloat(index) * scaleX
                        let yPosition = (1 - CGFloat(amplitude / maxFrequency)) * geometry.size.height
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: xPosition, y: yPosition))
                        } else {
                            path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                        }
                    }
                }
                .stroke(Color.green, lineWidth: 2)
            }

            Text("Spectrum Analysis Graph").font(.headline)
        }
    }
}
