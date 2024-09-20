import Accelerate

class FFTCalculator {
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

