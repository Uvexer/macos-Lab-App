import SwiftUI
import Accelerate

struct SpectrumView: View {
    var data: [(time: Int, voltage: Double, current: Double)]

    var body: some View {
        let fftResult = computeFFT(data.map { $0.voltage })
        let maxFrequency = fftResult.max() ?? 1

        return GeometryReader { geometry in
            Path { path in
                let scaleX = geometry.size.width / CGFloat(fftResult.count)
       //         _ = geometry.size.height / CGFloat(maxFrequency)
                
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
    }

    func computeFFT(_ signal: [Double]) -> [Double] {
        let n = signal.count
        var real = signal
        var imaginary = [Double](repeating: 0.0, count: n)
        var magnitudes = [Double](repeating: 0.0, count: n/2)

        real.withUnsafeMutableBufferPointer { realPtr in
            imaginary.withUnsafeMutableBufferPointer { imagPtr in
                var splitComplex = DSPDoubleSplitComplex(realp: realPtr.baseAddress!, imagp: imagPtr.baseAddress!)

                let log2n = vDSP_Length(log2(Float(n)))
                if let fftSetup = vDSP_create_fftsetupD(log2n, FFTRadix(kFFTRadix2)) {
                    vDSP_fft_zipD(fftSetup, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))
                    vDSP_zvmagsD(&splitComplex, 1, &magnitudes, 1, vDSP_Length(n / 2))
                    vDSP_destroy_fftsetupD(fftSetup)
                }
            }
        }

        return magnitudes.map { sqrt($0) }
    }
}
