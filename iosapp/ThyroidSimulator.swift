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

    let t3OralDoses: [T3OralDose]
    let t3IVDoses: [T3IVDose]
    let t3InfusionDoses: [T3InfusionDose]
    let t4OralDoses: [T4OralDose]
    let t4IVDoses: [T4IVDose]
    let t4InfusionDoses: [T4InfusionDose]

    private let dt: Double = 0.01 // Time step in HOURS

    init(
        t4Secretion: Double, t3Secretion: Double,
        gender: String, height: Double, weight: Double, days: Int,
        t3OralDoses: [T3OralDose] = [], t3IVDoses: [T3IVDose] = [], t3InfusionDoses: [T3InfusionDose] = [],
        t4OralDoses: [T4OralDose] = [], t4IVDoses: [T4IVDose] = [], t4InfusionDoses: [T4InfusionDose] = []
    ) {
        self.t4Secretion = t4Secretion
        self.t3Secretion = t3Secretion
        self.gender = gender
        self.height = height
        self.weight = weight
        self.days = days
        
        self.t3OralDoses = t3OralDoses
        self.t3IVDoses = t3IVDoses
        self.t3InfusionDoses = t3InfusionDoses
        self.t4OralDoses = t4OralDoses
        self.t4IVDoses = t4IVDoses
        self.t4InfusionDoses = t4InfusionDoses
    }
    
    // MARK: - Initial Condition Calculation
    
    private func findSteadyState() -> (q1: Double, q4: Double, q7: Double, q4Lag: Double) {
        var q1 = 0.27275, q4 = 0.6053, q7 = 9.8109
        var q4Lag = q4

        let patient = ThyroidPatientParams(height: height, weight: weight, sex: gender)
        let (_, _, k05_new) = patient.computeAll()
        let tauLag_hours = 0.25 * 24.0

        let preRunTime_hours = 200 * 24.0
        let preRunSteps = Int(ceil(preRunTime_hours / dt))

        for step in 0..<preRunSteps {
            let t_hours = Double(step) * dt
            
            let (dQ1, dQ4, dQ7, _, _, _, _) = calculateDerivatives(
                t_hours: t_hours, q1: q1, q4: q4, q7: q7, q4Lag: q4Lag,
                q10: 0, q11: 0, q12: 0, q13: 0,
                k05: k05_new, u1: 0, u4: 0
            )
            
            let dQ4Lag = (q4 - q4Lag) / tauLag_hours

            q1 += dQ1 * dt
            q4 += dQ4 * dt
            q7 += dQ7 * dt
            q4Lag += dQ4Lag * dt
        }
        
        return (q1, q4, q7, q4Lag)
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
        
        var q1: Double, q4: Double, q7: Double, q4Lag: Double
        
        if recalculateIC {
            let newICs = findSteadyState()
            q1 = newICs.q1
            q4 = newICs.q4
            q7 = newICs.q7
            q4Lag = newICs.q4Lag
        } else {
            q1 = 0.2727519456861839
            q4 = 0.6053134808855783
            q7 = 9.810946716614794
            q4Lag = q4
        }
        
        var q10: Double = 0.0, q11: Double = 0.0
        var q12: Double = 0.0, q13: Double = 0.0

        let tauLag_hours = 0.25 * 24.0
        
        var time_results: [Double] = []
        var t4_results: [Double] = [], t3_results: [Double] = [], tsh_results: [Double] = []
        var ft4_results: [Double] = [], ft3_results: [Double] = []
        
        let logInterval_steps = Int(max(1.0, 1.0 / dt))

        for step in 0..<totalSteps {
            let t_hours = Double(step) * dt
            let t_days = t_hours / 24.0
            
            var u1: Double = 0.0
            var u4: Double = 0.0

            for dose in t4IVDoses where abs(t_days - Double(dose.T4IVDoseStart)) < (dt / 24.0 / 2.0) {
                q1 += Double(dose.T4IVDoseInput) / 777.0
            }
            for dose in t3IVDoses where abs(t_days - Double(dose.T3IVDoseStart)) < (dt / 24.0 / 2.0) {
                q4 += Double(dose.T3IVDoseInput) / 651.0
            }

            for dose in t4InfusionDoses where t_days >= Double(dose.T4InfusionDoseStart) && t_days < Double(dose.T4InfusionDoseEnd) {
                let duration_days = Double(dose.T4InfusionDoseEnd - dose.T4InfusionDoseStart)
                if duration_days > 0 {
                    let rate_per_day = Double(dose.T4InfusionDoseInput) / duration_days
                    u1 += (rate_per_day / 24.0) / 777.0
                }
            }
            for dose in t3InfusionDoses where t_days >= Double(dose.T3InfusionDoseStart) && t_days < Double(dose.T3InfusionDoseEnd) {
                let duration_days = Double(dose.T3InfusionDoseEnd - dose.T3InfusionDoseStart)
                if duration_days > 0 {
                    let rate_per_day = Double(dose.T3InfusionDoseInput) / duration_days
                    u4 += (rate_per_day / 24.0) / 651.0
                }
            }
            
            for dose in t4OralDoses {
                if dose.T4SingleDose {
                    if abs(t_days - Double(dose.T4OralDoseStart)) < (dt / 24.0 / 2.0) {
                        q10 += Double(dose.T4OralDoseInput) / 777.0
                    }
                } else if t_days >= Double(dose.T4OralDoseStart) && t_days <= Double(dose.T4OralDoseEnd) {
                    let interval_days = Double(dose.T4OralDoseInterval)
                    if interval_days > 0 && (t_days - Double(dose.T4OralDoseStart)).truncatingRemainder(dividingBy: interval_days) < (dt / 24.0) {
                         q10 += Double(dose.T4OralDoseInput) / 777.0
                    }
                }
            }
            for dose in t3OralDoses {
                 if dose.T3SingleDose {
                    if abs(t_days - Double(dose.T3OralDoseStart)) < (dt / 24.0 / 2.0) {
                        q12 += Double(dose.T3OralDoseInput) / 651.0
                    }
                } else if t_days >= Double(dose.T3OralDoseStart) && t_days <= Double(dose.T3OralDoseEnd) {
                    let interval_days = Double(dose.T3OralDoseInterval)
                    if interval_days > 0 && (t_days - Double(dose.T3OralDoseStart)).truncatingRemainder(dividingBy: interval_days) < (dt / 24.0) {
                         q12 += Double(dose.T3OralDoseInput) / 651.0
                    }
                }
            }

            let (dQ1, dQ4, dQ7, dQ10, dQ11, dQ12, dQ13) = calculateDerivatives(t_hours: t_hours, q1: q1, q4: q4, q7: q7, q4Lag: q4Lag, q10: q10, q11: q11, q12: q12, q13: q13, k05: k05_new, u1: u1, u4: u4)
            
            q1 = max(q1 + dQ1 * dt, 0)
            q4 = max(q4 + dQ4 * dt, 0)
            q7 = max(q7 + dQ7 * dt, 0)
            q10 = max(q10 + dQ10 * dt, 0)
            q11 = max(q11 + dQ11 * dt, 0)
            q12 = max(q12 + dQ12 * dt, 0)
            q13 = max(q13 + dQ13 * dt, 0)

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
    private func calculateDerivatives(t_hours: Double, q1: Double, q4: Double, q7: Double, q4Lag: Double, q10: Double, q11: Double, q12: Double, q13: Double, k05: Double, u1: Double, u4: Double) -> (Double, Double, Double, Double, Double, Double, Double) {
        
        let k4_dissolve = 0.5
        let k4_absorb = 0.035
        let k4_excrete = 0.005
        let k3_dissolve = 0.6
        let k3_absorb = 0.04
        let k3_excrete = 0.006
        
        let circadian = sin((.pi * t_hours / 12.0) - (.pi / 2.0))
        let f4 = ThyrosimConstants.k3 * (1.0 + (5.0 * ThyrosimConstants.Kf4) / (ThyrosimConstants.Kf4 + q4Lag))
        let fCIRC = pow(q4Lag, ThyrosimConstants.nHill) / (pow(q4Lag, ThyrosimConstants.nHill) + pow(ThyrosimConstants.KCIRC, ThyrosimConstants.nHill))
        let suppressionFeedback = ThyrosimConstants.Km / (ThyrosimConstants.Km + pow(q4Lag, ThyrosimConstants.m))
        let SRTSH = ThyrosimConstants.A0 * fCIRC * circadian + ThyrosimConstants.B0 * suppressionFeedback
        let dQ7 = SRTSH - ThyrosimConstants.kDegTSH * q7
        
        let SR4_endogenous = (self.t4Secretion / 100.0) * ThyrosimConstants.S4 * q7
        let SR3_direct_endogenous = (self.t3Secretion / 100.0) * ThyrosimConstants.S3

        let dQ10 = -k4_dissolve * q10
        let dQ11 = k4_dissolve * q10 - (k4_excrete + k4_absorb) * q11
        let dQ12 = -k3_dissolve * q12
        let dQ13 = k3_dissolve * q12 - (k3_excrete + k3_absorb) * q13

        let dQ1 = SR4_endogenous - ThyrosimConstants.kDegT4 * q1 + (k4_absorb * q11) + u1
        let dQ4 = SR3_direct_endogenous + f4 * q1 + 0.005 * q1 - k05 * q4 + (k3_absorb * q13) + u4
        
        return (dQ1, dQ4, dQ7, dQ10, dQ11, dQ12, dQ13)
    }

    private func logResults(time_hours: Double, q1: Double, q4: Double, q7: Double, vp: Double, vtsh: Double, logTSH: Bool,
                            time_results: inout [Double], t4_results: inout [Double], t3_results: inout [Double],
                            tsh_results: inout [Double], ft4_results: inout [Double], ft3_results: inout [Double]) {
        let currentTime_days = time_hours / 24.0
        time_results.append(currentTime_days)
        
        let yT4 = 777.0 * q1 / vp
        // **FIXED**: Corrected T3 scaling factor by 100x
        let yT3 = 6.51 * q4 / vp
        // **FIXED**: Corrected TSH scaling factor to match expected graph range
        var yTSH = 1.0 * q7 / vtsh
        
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
