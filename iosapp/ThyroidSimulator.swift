import Foundation

struct ThyroidSimulationResult {
    let time: [Double]
    let t4: [Double]
    let t3: [Double]
    let tsh: [Double]
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

        if recalculateIC {
            for _ in 0..<10000 {
                let circadian = sin(.pi * 0 / 12.0 - .pi / 2.0)
                let SRTSH = (ThyrosimConstants.B0 + ThyrosimConstants.A0 * circadian) * (ThyrosimConstants.Km / (ThyrosimConstants.Km + pow(q4, ThyrosimConstants.m)))
                let dQ7 = SRTSH - ThyrosimConstants.kDegTSH * q7
                let SR4 = (t4Secretion / 100.0) * ThyrosimConstants.S4 * q7
                let dQ1 = SR4 - ThyrosimConstants.kDegT4 * q1
                let SR3 = (t3Secretion / 100.0) * ThyrosimConstants.S3
                let dQ4 = SR3 + 0.005 * q1 - k05_new * q4
                q1 = max(q1 + dQ1 * dt, 0)
                q4 = max(q4 + dQ4 * dt, 0)
                q7 = max(q7 + dQ7 * dt, 0)
            }
        }

        var t4: [Double] = [], t3: [Double] = [], tsh: [Double] = [], time: [Double] = []

        for step in 0..<totalSteps {
            let t = Double(step) * dt
            let circadian = sin(.pi * t / 12.0 - .pi / 2.0)
            let SRTSH = (ThyrosimConstants.B0 + ThyrosimConstants.A0 * circadian) * (ThyrosimConstants.Km / (ThyrosimConstants.Km + pow(q4, ThyrosimConstants.m)))
            let dQ7 = SRTSH - ThyrosimConstants.kDegTSH * q7
            let SR4 = (t4Secretion / 100.0) * ThyrosimConstants.S4 * q7
            let dQ1 = SR4 - ThyrosimConstants.kDegT4 * q1
            let SR3 = (t3Secretion / 100.0) * ThyrosimConstants.S3
            let dQ4 = SR3 + 0.005 * q1 - k05_new * q4
            q1 = max(q1 + dQ1 * dt, 0)
            q4 = max(q4 + dQ4 * dt, 0)
            q7 = max(q7 + dQ7 * dt, 0)
            let yT4 = 777.0 * q1 / VP_new
            let yT3 = 651.0 * q4 / VP_new
            var yTSH = 5.6 * q7 / VTSH_new
            if logTSHOutput { yTSH = log10(max(yTSH, 0.001)) }
            t4.append(yT4)
            t3.append(yT3)
            tsh.append(yTSH)
            time.append(t)
        }

        return ThyroidSimulationResult(time: time, t4: t4, t3: t3, tsh: tsh)
    }
}
