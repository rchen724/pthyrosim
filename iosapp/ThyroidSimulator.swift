import Foundation

// The result struct should have mutable properties to allow appending results.
struct ThyroidSimulationResult: Equatable {
    var time: [Double] = []
    var t4: [Double] = []
    var t3: [Double] = []
    var tsh: [Double] = []
    var ft4: [Double] = []
    var ft3: [Double] = []
}

class ThyroidSimulator {

    // MARK: - Class Properties
    
    // Patient and simulation parameters
    private let t4Secretion: Double
    private let t3Secretion: Double
    private let gender: String
    private let height: Double // meters
    private let weight: Double // kg
    private let days: Int

    // Dosing schedules
    private let t3OralDoses: [T3OralDose]
    private let t4OralDoses: [T4OralDose]
    private let t3IVDoses: [T3IVDose]
    private let t4IVDoses: [T4IVDose]
    private let t3InfusionDoses: [T3InfusionDose]
    private let t4InfusionDoses: [T4InfusionDose]

    // Simulation state variables
    private let dt: Double = 0.1 // Time step in hours
    private var q: [Double] = Array(repeating: 0.0, count: 20) // State vector for all ODEs
    
    // Calculated patient-specific parameters
    private var vp: Double = 0.0
    private var vtsh: Double = 0.0
    private var k05: Double = 0.0
    
    // Current infusion rates
    private var t4InfusionRate: Double = 0.0
    private var t3InfusionRate: Double = 0.0
    
    // A small constant (epsilon) to prevent division by zero.
    private let epsilon: Double = 1e-9

    init(
        t4Secretion: Double, t3Secretion: Double,
        gender: String, height: Double, weight: Double, days: Int,
        t3OralDoses: [T3OralDose] = [], t4OralDoses: [T4OralDose] = [],
        t3IVDoses: [T3IVDose] = [], t4IVDoses: [T4IVDose] = [],
        t3InfusionDoses: [T3InfusionDose] = [], t4InfusionDoses: [T4InfusionDose] = []
    ) {
        self.t4Secretion = t4Secretion
        self.t3Secretion = t3Secretion
        self.gender = gender
        self.height = height
        self.weight = weight
        self.days = days
        
        self.t3OralDoses = t3OralDoses
        self.t4OralDoses = t4OralDoses
        self.t3IVDoses = t3IVDoses
        self.t4IVDoses = t4IVDoses
        self.t3InfusionDoses = t3InfusionDoses
        self.t4InfusionDoses = t4InfusionDoses

        // Set default initial conditions
        q[0] = 70.0; q[1] = 145.0; q[2] = 500.0; q[3] = 2.0; q[4] = 6.0;
        q[5] = 1.0; q[6] = 20.0; q[7] = 1.0; q[8] = 1.0;
        // Initialize the TSH feedback delay chain with a reasonable baseline
        q[13] = 20.0; q[14] = 20.0; q[15] = 20.0; q[16] = 20.0; q[17] = 20.0; q[18] = 20.0; q[19] = 20.0;
    }

    func runSimulation(recalculateIC: Bool = false) -> ThyroidSimulationResult {
        let patient = ThyroidPatientParams(height: height, weight: weight, sex: gender)
        (self.vp, self.vtsh, self.k05) = patient.computeAll()
        
        let totalTimeHours = Double(days) * 24.0
        let numSteps = Int(totalTimeHours / dt)
        var results = ThyroidSimulationResult()

        for step in 0..<numSteps {
            let t_hours = Double(step) * dt
            
            applyDoses(at: t_hours)
            rk4Step(t: t_hours, dt: dt)
            logResults(time_hours: t_hours, results: &results)
        }
        
        return results
    }

    // MARK: - Private Simulation Methods

    private func applyDoses(at t_hours: Double) {
        let t_days = t_hours / 24.0
        let tolerance = (dt / 24.0) / 2.0

        // IV Doses
        for dose in t4IVDoses where abs(t_days - Double(dose.T4IVDoseStart)) < tolerance {
            q[0] += Double(dose.T4IVDoseInput)
        }
        for dose in t3IVDoses where abs(t_days - Double(dose.T3IVDoseStart)) < tolerance {
            q[3] += Double(dose.T3IVDoseInput)
        }

        // Correctly calculate infusion rates
        t4InfusionRate = t4InfusionDoses.filter { t_days >= Double($0.T4InfusionDoseStart) && t_days < Double($0.T4InfusionDoseEnd) }
                                     .reduce(0.0) { $0 + Double($1.T4InfusionDoseInput) }

        t3InfusionRate = t3InfusionDoses.filter { t_days >= Double($0.T3InfusionDoseStart) && t_days < Double($0.T3InfusionDoseEnd) }
                                     .reduce(0.0) { $0 + Double($1.T3InfusionDoseInput) }


        // Oral Doses
        for dose in t4OralDoses {
            if dose.T4SingleDose {
                if abs(t_days - Double(dose.T4OralDoseStart)) < tolerance {
                    q[9] += Double(dose.T4OralDoseInput)
                }
            } else if t_days >= Double(dose.T4OralDoseStart) && t_days <= Double(dose.T4OralDoseEnd) {
                let interval_days = Double(dose.T4OralDoseInterval)
                if interval_days > 0 && (t_days - Double(dose.T4OralDoseStart)).truncatingRemainder(dividingBy: interval_days) < tolerance {
                    q[9] += Double(dose.T4OralDoseInput)
                }
            }
        }
        for dose in t3OralDoses {
                if dose.T3SingleDose {
                if abs(t_days - Double(dose.T3OralDoseStart)) < tolerance {
                    q[11] += Double(dose.T3OralDoseInput)
                }
            } else if t_days >= Double(dose.T3OralDoseStart) && t_days <= Double(dose.T3OralDoseEnd) {
                let interval_days = Double(dose.T3OralDoseInterval)
                if interval_days > 0 && (t_days - Double(dose.T3OralDoseStart)).truncatingRemainder(dividingBy: interval_days) < tolerance {
                    q[11] += Double(dose.T3OralDoseInput)
                }
            }
        }
    }

    private func rk4Step(t: Double, dt: Double) {
        let k1 = calculateDerivatives(q_in: q, t: t)
        
        var q_k2 = q
        for i in 0..<q.count { q_k2[i] += k1[i] * dt / 2.0 }
        let k2 = calculateDerivatives(q_in: q_k2, t: t + dt / 2.0)
        
        var q_k3 = q
        for i in 0..<q.count { q_k3[i] += k2[i] * dt / 2.0 }
        let k3 = calculateDerivatives(q_in: q_k3, t: t + dt / 2.0)
        
        var q_k4 = q
        for i in 0..<q.count { q_k4[i] += k3[i] * dt }
        let k4 = calculateDerivatives(q_in: q_k4, t: t + dt)
        
        for i in 0..<q.count {
            q[i] += (k1[i] + 2 * k2[i] + 2 * k3[i] + k4[i]) * dt / 6.0
            
            // Clamp all state variables to be non-negative after each step.
            q[i] = max(0, q[i])
        }
    }

    private func calculateDerivatives(q_in: [Double], t: Double) -> [Double] {
        var dqdt = [Double](repeating: 0.0, count: 20)

        // Ensure concentrations are non-negative to prevent invalid calculations
        let q = q_in.map { max(0, $0) }
        
        // Correctly unpack state variables
        let (q0, q1, q2, q3, q4, q5, q6, q7, q8, q9, q10, q11, q12, q13, q14, q15, q16, q17, q18, q19) =
            (q[0], q[1], q[2], q[3], q[4], q[5], q[6], q[7], q[8], q[9], q[10], q[11], q[12], q[13], q[14], q[15], q[16], q[17], q[18], q[19])

        // Auxiliary equations
        let safe_vp = max(self.vp, epsilon)
        let YT4p = 777.0 * q0 / safe_vp
        let FT4P = (ThyrosimConstants.ft4_A + ThyrosimConstants.ft4_B * YT4p + ThyrosimConstants.ft4_C * pow(YT4p, 2) + ThyrosimConstants.ft4_D * pow(YT4p, 3)) * YT4p
        let YT3p = 651.0 * q3 / safe_vp
        let FT3P = (ThyrosimConstants.ft3_a + ThyrosimConstants.ft3_b * YT4p + ThyrosimConstants.ft3_c * pow(YT4p, 2) + ThyrosimConstants.ft3_d * pow(YT4p, 3)) * YT3p

        let f_CIRC_num = pow(q8, ThyrosimConstants.nHill_CIRC)
        let f_CIRC_den = pow(ThyrosimConstants.KCIRC, ThyrosimConstants.nHill_CIRC) + f_CIRC_num
        let f_CIRC = f_CIRC_num / (f_CIRC_den + epsilon)
        
        let SR_TSH_Inhib_den = pow(ThyrosimConstants.Km_SR_TSH, ThyrosimConstants.m_SR_TSH) + pow(q8, ThyrosimConstants.m_SR_TSH)
        let SR_TSH_Inhib = pow(ThyrosimConstants.Km_SR_TSH, ThyrosimConstants.m_SR_TSH) / (SR_TSH_Inhib_den + epsilon)
        
        let SR_TSH = (ThyrosimConstants.B0 + ThyrosimConstants.A0 * f_CIRC * sin((.pi / 12) * (t) - .pi)) * SR_TSH_Inhib

        // Use q18, the final output of the TSH delay chain
        let SR4 = (self.t4Secretion / 100.0) * ThyrosimConstants.S4 * q19
        let SR3 = (self.t3Secretion / 100.0) * ThyrosimConstants.S3 * q19

        let NL = ThyrosimConstants.Vmax_D1_fast / (ThyrosimConstants.Km_D1_fast + q1 + epsilon)
        let D1_slow = ThyrosimConstants.Vmax_D1_slow / (ThyrosimConstants.Km_D1_slow + q2 + epsilon)
        let D2_slow = ThyrosimConstants.Vmax_D2_slow / (ThyrosimConstants.Km_D2_slow + q2 + epsilon)
        let f4 = ThyrosimConstants.k7 * (1 + (5 * pow(ThyrosimConstants.Kf4_brain, 2)) / (pow(ThyrosimConstants.Kf4_brain, 2) + pow(q7, 2) + epsilon))
        
        // --- CORRECTED Differential Equations ---
        
        dqdt[0] = t4InfusionRate + SR4 + ThyrosimConstants.k21 * q1 + ThyrosimConstants.k31 * q2 - (ThyrosimConstants.k12 + ThyrosimConstants.k13) * FT4P - (ThyrosimConstants.kDegT4 * q0) + (ThyrosimConstants.k_absorb_T4 * q10)
        dqdt[1] = ThyrosimConstants.k12 * FT4P - (ThyrosimConstants.k21 + NL) * q1
        dqdt[2] = ThyrosimConstants.k13 * FT4P - (ThyrosimConstants.k31 + D1_slow + D2_slow) * q2
        dqdt[3] = t3InfusionRate + SR3 + ThyrosimConstants.k54 * q4 + ThyrosimConstants.k64 * q5 - (ThyrosimConstants.k45 + ThyrosimConstants.k46) * FT3P - k05 * q3 + (ThyrosimConstants.k_absorb_T3 * q12)
        dqdt[4] = ThyrosimConstants.k45 * FT3P + NL * q1 - (ThyrosimConstants.k54 + k05) * q4
        dqdt[5] = ThyrosimConstants.k46 * FT3P + (D1_slow + D2_slow) * q2 - ThyrosimConstants.k64 * q5
        dqdt[6] = SR_TSH - ThyrosimConstants.kDegTSH * q6
        dqdt[7] = (f4 / 70.0) * YT4p + (ThyrosimConstants.k7 / 2.0) * YT3p - ThyrosimConstants.k_deg_T3B * q7
        dqdt[8] = ThyrosimConstants.f_LAG * (q7 - q8)
        
        // Corrected Gut Model
        dqdt[9] = -ThyrosimConstants.k_pill_T4 * q9
        dqdt[10] = ThyrosimConstants.k_pill_T4 * q9 - (ThyrosimConstants.k_gut_T4 + ThyrosimConstants.k_absorb_T4) * q10
        dqdt[11] = -ThyrosimConstants.k_pill_T3 * q11
        dqdt[12] = ThyrosimConstants.k_pill_T3 * q11 - (ThyrosimConstants.k_gut_T3 + ThyrosimConstants.k_absorb_T3) * q12
        
        // Corrected TSH Delay Chain
        let k_delay = 1.0;
        dqdt[13] = -k_delay * q13 + q6
        dqdt[14] = k_delay * (q13 - q14)
        dqdt[15] = k_delay * (q14 - q15)
        dqdt[16] = k_delay * (q15 - q16)
        dqdt[17] = k_delay * (q16 - q17)
        dqdt[18] = k_delay * (q17 - q18)
        dqdt[19] = k_delay * (q18 - q19)
        
        return dqdt
    }

    private func logResults(time_hours: Double, results: inout ThyroidSimulationResult) {
        let currentTime_days = time_hours / 24.0
        
        guard vp > 0, vtsh > 0 else { return }

        let yT4_total = 777.0 * q[0] / vp
        let yT3_total = 651.0 * q[3] / vp
        let yTSH = 5.6 * q[6] / vtsh
        
        let yFT4_num = ThyrosimConstants.ft4_A + ThyrosimConstants.ft4_B * yT4_total + ThyrosimConstants.ft4_C * pow(yT4_total, 2) + ThyrosimConstants.ft4_D * pow(yT4_total, 3)
        let yFT4 = yFT4_num * yT4_total
        
        let yFT3_num = ThyrosimConstants.ft3_a + ThyrosimConstants.ft3_b * yT4_total + ThyrosimConstants.ft3_c * pow(yT4_total, 2) + ThyrosimConstants.ft3_d * pow(yT4_total, 3)
        let yFT3 = yFT3_num * yT3_total
        
        if yT4_total.isFinite, yT3_total.isFinite, yTSH.isFinite, yFT4.isFinite, yFT3.isFinite {
            results.time.append(currentTime_days)
            results.t4.append(yT4_total)
            results.t3.append(yT3_total)
            results.tsh.append(yTSH)
            results.ft4.append(yFT4)
            results.ft3.append(yFT3)
        }
    }
}
