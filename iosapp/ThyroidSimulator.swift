import Foundation

// MARK: - Result and Dose Data Structures
struct ThyroidSimulationResult {
    let time: [Double]
    let t4: [Double]
    let t3: [Double]
    let tsh: [Double]
    let ft4: [Double]
    let ft3: [Double]
}

// MARK: - Main Simulator Class
class ThyroidSimulator {
    // MARK: Properties
    let t4Secretion: Double
    let t3Secretion: Double
    let gender: String
    let height: Double // Expected in meters
    let weight: Double // Expected in kg
    let days: Int

    private let dt: Double = 0.01 // Time step in HOURS

    // MARK: Initializer (Simplified for Run 1)
    init(
        t4Secretion: Double, t3Secretion: Double,
        gender: String, height: Double, weight: Double, days: Int
    ) {
        self.t4Secretion = t4Secretion
        self.t3Secretion = t3Secretion
        self.gender = gender
        self.height = height
        self.weight = weight
        self.days = days
    }

    // MARK: - Simulation Logic
    func runSimulation(recalculateIC: Bool = false, logTSHOutput: Bool = false) -> ThyroidSimulationResult {
        let totalSimulationTime_hours = Double(days) * 24.0
        let totalSteps = Int(ceil(totalSimulationTime_hours / dt))

        guard totalSteps > 0 else {
            return .init(time: [], t4: [], t3: [], tsh: [], ft4: [], ft3: [])
        }

        let patient = ThyroidPatientParams(height: height, weight: weight, sex: gender)
        let (vp_new, vtsh_new, k05_new) = patient.computeAll()

        guard vp_new > 0, vtsh_new > 0 else {
            return .init(time: [], t4: [], t3: [], tsh: [], ft4: [], ft3: [])
        }

        // --- Default Initial Conditions ---
        // We will replace these hard-coded values after finding the stable ones.
        var q1 = 0.2727519456861839
        var q4 = 0.6053134808855783
        var q7 = 9.810946716614794
        
        var q4Lag = q4
        let tauLag_hours = 0.25 * 24.0

        // --- Recalculate ICs if Toggle is ON ---
        if recalculateIC {
            // This block finds the stable equilibrium for the given secretion rates.
            let ic_duration_hours = 200.0 * 24.0
            let ic_steps = Int(ceil(ic_duration_hours / dt))
            
            for i in 0..<ic_steps {
                let t_ic_hours = Double(i) * dt
                let (dQ1_ic, dQ4_ic, dQ7_ic) = calculateDerivatives(t_hours: t_ic_hours, q1: q1, q4: q4, q7: q7, q4Lag: q4Lag, k05: k05_new)
                q1 = max(q1 + dQ1_ic * dt, 0)
                q4 = max(q4 + dQ4_ic * dt, 0)
                q7 = max(q7 + dQ7_ic * dt, 0)
                
                let dQ4Lag_ic = (q4 - q4Lag) / tauLag_hours
                q4Lag += dQ4Lag_ic * dt
            }
            // Print the stable values so we can use them as our new defaults.
            print("STABLE EUTHYROID VALUES ==> q1: \(q1), q4: \(q4), q7: \(q7)")
        }
        
        // --- Main Simulation Loop ---
        var time_results: [Double] = []
        var t4_results: [Double] = [], t3_results: [Double] = [], tsh_results: [Double] = []
        var ft4_results: [Double] = [], ft3_results: [Double] = []
        
        let logInterval_steps = Int(max(1.0, 1.0 / dt)) // Log results every simulated hour

        for step in 0..<totalSteps {
            let t_hours = Double(step) * dt
            
            let (dQ1, dQ4, dQ7) = calculateDerivatives(t_hours: t_hours, q1: q1, q4: q4, q7: q7, q4Lag: q4Lag, k05: k05_new)
            
            q1 = max(q1 + dQ1 * dt, 0)
            q4 = max(q4 + dQ4 * dt, 0)
            q7 = max(q7 + dQ7 * dt, 0)

            let dQ4Lag = (q4 - q4Lag) / tauLag_hours
            q4Lag += dQ4Lag * dt

            if step % logInterval_steps == 0 || step == totalSteps - 1 {
                logResults(time_hours: t_hours, q1: q1, q4: q4, q7: q7, vp: vp_new, vtsh: vtsh_new, logTSH: logTSHOutput,
                           time_results: &time_results, t4_results: &t4_results, t3_results: &t3_results,
                           tsh_results: &tsh_results, ft4_results: &ft4_results, ft3_results: &ft3_results)
            }
        }
        return ThyroidSimulationResult(time: time_results, t4: t4_results, t3: t3_results, tsh: tsh_results, ft4: ft4_results, ft3: ft3_results)
    }
    
    // MARK: - Helper Methods
    private func calculateDerivatives(t_hours: Double, q1: Double, q4: Double, q7: Double, q4Lag: Double, k05: Double) -> (Double, Double, Double) {
        let circadian = sin((.pi * t_hours / 12.0) - (.pi / 2.0))
        
        let f4 = ThyrosimConstants.k3 * (1.0 + (5.0 * ThyrosimConstants.Kf4) / (ThyrosimConstants.Kf4 + q4Lag))
        let fCIRC = pow(q4Lag, ThyrosimConstants.nHill) / (pow(q4Lag, ThyrosimConstants.nHill) + pow(ThyrosimConstants.KCIRC, ThyrosimConstants.nHill))
        
        // This is the corrected TSH secretion logic
        let suppressionFeedback = ThyrosimConstants.Km / (ThyrosimConstants.Km + pow(q4Lag, ThyrosimConstants.m))
        let SRTSH = ThyrosimConstants.A0 * fCIRC * circadian + ThyrosimConstants.B0 * suppressionFeedback
        
        let dQ7 = SRTSH - ThyrosimConstants.kDegTSH * q7
        
        let SR4_endogenous = (self.t4Secretion / 100.0) * ThyrosimConstants.S4 * q7
        let dQ1 = SR4_endogenous - ThyrosimConstants.kDegT4 * q1
        
        let SR3_direct_endogenous = (self.t3Secretion / 100.0) * ThyrosimConstants.S3
        let dQ4 = SR3_direct_endogenous + f4 * q1 + 0.005 * q1 - k05 * q4
        
        return (dQ1, dQ4, dQ7)
    }

    private func logResults(time_hours: Double, q1: Double, q4: Double, q7: Double, vp: Double, vtsh: Double, logTSH: Bool,
                            time_results: inout [Double], t4_results: inout [Double], t3_results: inout [Double],
                            tsh_results: inout [Double], ft4_results: inout [Double], ft3_results: inout [Double]) {
        let currentTime_days = time_hours / 24.0
        time_results.append(currentTime_days)
        
        let yT4 = 777.0 * q1 / vp
        let yT3 = 6.51 * q4 / vp
        var yTSH = 0.56 * q7 / vtsh
        if logTSH { yTSH = log10(max(yTSH, 0.001)) }

        let yFT4 = (ThyrosimConstants.ft4_A + ThyrosimConstants.ft4_B * yT4 + ThyrosimConstants.ft4_C * pow(yT4, 2) + ThyrosimConstants.ft4_D * pow(yT4, 3)) * yT4
        let yFT3 = (ThyrosimConstants.ft3_a + ThyrosimConstants.ft3_b * yT4 + ThyrosimConstants.ft3_c * pow(yT4, 2) + ThyrosimConstants.ft3_d * pow(yT4, 3)) * yT3

        t4_results.append(yT4)
        t3_results.append(yT3)
        tsh_results.append(yTSH)
        ft4_results.append(yFT4)
        ft3_results.append(yFT3)
    }
}
