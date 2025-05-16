import Foundation

struct ThyroidSimulationResult {
    let time: [Double]
    let t4: [Double]
    let t3: [Double]
    let tsh: [Double]
    let ft4: [Double]
    let ft3: [Double]
}

class ThyroidSimulator {
    let t4Secretion: Double
    let t3Secretion: Double
    let gender: String
    let height: Double
    let weight: Double
    let days: Int

    init(t4Secretion: Double, t3Secretion: Double, gender: String, height: Double, weight: Double, days: Int) {
        self.t4Secretion = t4Secretion
        self.t3Secretion = t3Secretion
        self.gender = gender
        self.height = height
        self.weight = weight
        self.days = days
    }

    func runSimulation(recalculateIC: Bool = false, logTSHOutput: Bool = false) -> ThyroidSimulationResult {
        let dt = 0.01
        let totalSteps = Int(Double(days) / dt)

        let patient = ThyroidPatientParams(height: height, weight: weight, sex: gender)
        let (VP_new, VTSH_new, k05_new) = patient.computeAll()

        var q1 = 80.0 / 777.0 * VP_new
        var q4 = 1.3 / 651.0 * VP_new
        var q7 = 2.0 / 5.6 * VTSH_new
        var q4Lag = q4
        let tauLag = 0.25

        if recalculateIC {
            var t: Double = 0.0
            for _ in 0..<10000 {
                let circadian = sin(.pi * t / 12.0 - .pi / 2.0)
                let dQ4Lag = (q4 - q4Lag) / tauLag
                q4Lag += dQ4Lag * dt

                let f4 = ThyrosimConstants.k3 * (1.0 + (5.0 * ThyrosimConstants.Kf4) / (ThyrosimConstants.Kf4 + q4Lag))
                let fCIRC = pow(q4Lag, ThyrosimConstants.nHill) /
                            (pow(q4Lag, ThyrosimConstants.nHill) + pow(ThyrosimConstants.KCIRC, ThyrosimConstants.nHill))

                let SRTSH = ThyrosimConstants.B0 +
                            ThyrosimConstants.A0 * fCIRC * circadian *
                            (ThyrosimConstants.Km / (ThyrosimConstants.Km + pow(q4Lag, ThyrosimConstants.m)))

                let dQ7 = SRTSH - ThyrosimConstants.kDegTSH * q7
                let SR4 = (t4Secretion / 100.0) * ThyrosimConstants.S4 * q7
                let dQ1 = SR4 - ThyrosimConstants.kDegT4 * q1
                let SR3 = (t3Secretion / 100.0) * ThyrosimConstants.S3 + f4 * q1
                let dQ4 = SR3 + 0.005 * q1 - k05_new * q4

                q1 = max(q1 + dQ1 * dt, 0)
                q4 = max(q4 + dQ4 * dt, 0)
                q7 = max(q7 + dQ7 * dt, 0)
                t += dt
            }
        }

        var t4: [Double] = [], t3: [Double] = [], tsh: [Double] = [], time: [Double] = []
        var ft4: [Double] = [], ft3: [Double] = []

        for step in 0..<totalSteps {
            let t = Double(step) * dt
            let circadian = sin(.pi * t / 12.0 - .pi / 2.0)

            let dQ4Lag = (q4 - q4Lag) / tauLag
            q4Lag += dQ4Lag * dt

            let f4 = ThyrosimConstants.k3 * (1.0 + (5.0 * ThyrosimConstants.Kf4) / (ThyrosimConstants.Kf4 + q4Lag))
            let fCIRC = pow(q4Lag, ThyrosimConstants.nHill) /
                        (pow(q4Lag, ThyrosimConstants.nHill) + pow(ThyrosimConstants.KCIRC, ThyrosimConstants.nHill))

            let SRTSH = ThyrosimConstants.B0 +
                        ThyrosimConstants.A0 * fCIRC * circadian *
                        (ThyrosimConstants.Km / (ThyrosimConstants.Km + pow(q4Lag, ThyrosimConstants.m)))

            let dQ7 = SRTSH - ThyrosimConstants.kDegTSH * q7
            let SR4 = (t4Secretion / 100.0) * ThyrosimConstants.S4 * q7
            let dQ1 = SR4 - ThyrosimConstants.kDegT4 * q1
            let SR3 = (t3Secretion / 100.0) * ThyrosimConstants.S3 + f4 * q1
            let dQ4 = SR3 + 0.005 * q1 - k05_new * q4

            q1 = max(q1 + dQ1 * dt, 0)
            q4 = max(q4 + dQ4 * dt, 0)
            q7 = max(q7 + dQ7 * dt, 0)

            let yT4 = 777.0 * q1 / VP_new
            let yT3 = 651.0 * q4 / VP_new
            var yTSH = 5.6 * q7 / VTSH_new
            if logTSHOutput { yTSH = log10(max(yTSH, 0.001)) }

            let yFT4 = (ThyrosimConstants.ft4_A + ThyrosimConstants.ft4_B * yT4 + ThyrosimConstants.ft4_C * pow(yT4, 2) + ThyrosimConstants.ft4_D * pow(yT4, 3)) * yT4
            let yFT3 = (ThyrosimConstants.ft3_a + ThyrosimConstants.ft3_b * yT4 + ThyrosimConstants.ft3_c * pow(yT4, 2) + ThyrosimConstants.ft3_d * pow(yT4, 3)) * yT3

            t4.append(yT4)
            t3.append(yT3)
            tsh.append(yTSH)
            ft4.append(yFT4)
            ft3.append(yFT3)
            time.append(t)
        }

        return ThyroidSimulationResult(time: time, t4: t4, t3: t3, tsh: tsh, ft4: ft4, ft3: ft3)
    }
}
