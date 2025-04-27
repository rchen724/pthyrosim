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

    init(
        t4Secretion: Double,
        t3Secretion: Double,
        gender: String,
        height: Double,
        weight: Double,
        days: Int
    ) {
        self.t4Secretion = t4Secretion
        self.t3Secretion = t3Secretion
        self.gender = gender
        self.height = height
        self.weight = weight
        self.days = days
    }

    func runSimulation() -> ThyroidSimulationResult {
        let dt = 0.01
        let totalSteps = Int(Double(days) / dt)

        // Get personalized parameters
        let patient = ThyroidPatientParams(
            height: height,
            weight: weight,
            sex: gender
        )
        let (VP_new, VTSH_new, k05_new) = patient.computeAll()

        // Initial hormone levels (arbitrary but realistic starting points)
        var q1 = 0.32  // T4P (µmol)
        var q4 = 0.0064  // T3P (µmol)
        var q7 = 10.4 // TSHP (µmol)

        var t4: [Double] = []
        var t3: [Double] = []
        var tsh: [Double] = []
        var time: [Double] = []

        for step in 0..<totalSteps {
            let t = Double(step) * dt

            // Measurement equations from your PDF
            let yT4P = 777.0 * q1 / VP_new // µg/L
            let yT3P = 651.0 * q4 / VP_new // µg/L
            let yTSHP = 5.6 * q7 / VTSH_new // mU/L

            // Store values for plotting
            t4.append(yT4P)
            t3.append(yT3P)
            tsh.append(yTSHP)
            time.append(t)

            // Simulate some simplified dynamics (placeholder until full ODEs added)
            // Add circadian rhythm (12-hour phase shift)
//            let circadian = 0.5 * sin(.pi * t / 12.0 - .pi / 2.0)
//
//            // Simulated TSH production (with feedback from T3)
//            let SRTSH = (0.6 + circadian) * (1.0 / (1.0 + 3 * pow(q4, 2)))
//            let dQ7 = SRTSH - 0.1 * q7
//            
//            let q7_stim = min(q7, 1.0) // Clamp TSH effect to avoid runaway
//            let dQ1 = (t4Secretion / 100.0) * (1.0 + 0.5 * q7_stim) - 0.2 * q1
//
//            // T4 and T3 dynamics with TSH stimulation and T4→T3 conversion
//            let dQ4 = (t3Secretion / 100.0 * 0.2) + 0.03 * q1 - k05_new * q4
            
            let circadian = 0.5 * sin(.pi * t / 12.0 - .pi / 2.0)

            let SRTSH = (1.2 + circadian) * (1.0 / (1.0 + 8 * pow(q4, 2))) // T3 feedback
            let dQ7 = SRTSH - 0.3 * q7

            let dQ1 = (t4Secretion / 100.0) * (1.0 + q7) - 0.4 * q1
            let dQ4 = (t3Secretion / 100.0 * 0.2) + 0.02 * q1 - k05_new * q4

            
            
        
            q1 += dQ1 * dt
            q4 += dQ4 * dt
            q7 += dQ7 * dt

//            q1 = max(q1, 0)
//            q4 = max(q4, 0)
//            q7 = max(q7, 0)
//            
            q1 = min(max(q1, 0), 2.0)
            q4 = min(max(q4, 0), 2.0)
            q7 = min(max(q7, 0), 1.5)
            
        }

        return ThyroidSimulationResult(
            time: time,
            t4: t4,
            t3: t3,
            tsh: tsh
        )
    }
}
