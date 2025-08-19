import Foundation

// MARK: - Simulation Result Structure
struct ThyroidSimulationResult: Equatable {
    var time: [Double] = []
    var t4: [Double] = []
    var t3: [Double] = []
    var tsh: [Double] = []
    var ft4: [Double] = []
    var ft3: [Double] = []
    var q_final: [Double]? = nil

}

// MARK: - Dose Event Structure (Helper for the new logic)
private struct DoseEvent: Comparable {
    let timeHours: Double
    let hormone: HormoneType
    let doseType: DoseType
    let amountMicrograms: Double // For bolus/oral doses
    let rateMicrogramsPerHour: Double // For infusions

    static func < (lhs: DoseEvent, rhs: DoseEvent) -> Bool {
        return lhs.timeHours < rhs.timeHours
    }

    enum HormoneType { case t3, t4 }
    enum DoseType { case oral, iv, infusionStart, infusionEnd }
}

// MARK: - Thyroid Simulator Class
class ThyroidSimulator {

    // MARK: - Properties
    private let patientParams: ThyroidPatientParams
    private let t4Secretion: Double
    private let t3Secretion: Double
    private let t4Absorption: Double
    private let t3Absorption: Double
    private let days: Int
    private let t3OralDoses: [T3OralDose]
    private let t4OralDoses: [T4OralDose]
    private let t3IVDoses: [T3IVDose]
    private let t4IVDoses: [T4IVDose]
    private let t3InfusionDoses: [T3InfusionDose]
    private let t4InfusionDoses: [T4InfusionDose]
    private let isInitialConditionsOn: Bool
    var initialState: [Double]? = nil

    private let dt: Double = 0.1 // Time step in hours
    private var q: [Double]
    
    private let defaultInitialConditions: [Double] = [
        0.3221, 0.2012, 0.6389, 0.0066, 0.0112, 0.0652, 1.7882,
        7.0572, 7.0571, 0, 0, 0, 0, 3.3428, 5.6927, 3.8794,
        3.9006, 3.7787, 3.5536
    ]

    private var vp: Double = 3.2
    private var vtsh: Double = 5.2
    private var k05: Double = 4.43928 / 24.0
    private let epsilon: Double = 1e-9

    // MARK: - Initialization
    init(
        t4Secretion: Double, t3Secretion: Double,
        t4Absorption: Double, t3Absorption: Double,
        gender: String, height: Double, weight: Double, days: Int,
        t3OralDoses: [T3OralDose] = [], t4OralDoses: [T4OralDose] = [],
        t3IVDoses: [T3IVDose] = [], t4IVDoses: [T4IVDose] = [],
        t3InfusionDoses: [T3InfusionDose] = [], t4InfusionDoses: [T4InfusionDose] = [],
        isInitialConditionsOn: Bool
    ) {
        self.patientParams = ThyroidPatientParams(height: height, weight: weight, sex: gender)
        self.t4Secretion = t4Secretion
        self.t3Secretion = t3Secretion
        self.t4Absorption = t4Absorption
        self.t3Absorption = t3Absorption
        self.days = days
        self.isInitialConditionsOn = isInitialConditionsOn
        self.t3OralDoses = t3OralDoses
        self.t4OralDoses = t4OralDoses
        self.t3IVDoses = t3IVDoses
        self.t4IVDoses = t4IVDoses
        self.t3InfusionDoses = t3InfusionDoses
        self.t4InfusionDoses = t4InfusionDoses
        self.q = self.defaultInitialConditions
    }

    // MARK: - Main Simulation Runner
    // In ThyroidSimulator.swift

    func runSimulation() -> ThyroidSimulationResult {
        
        
            // --- (MODIFIED) Logic to correctly set the initial state ---
            if let initialState = self.initialState {
                self.q = initialState
            } else {
                self.q = self.defaultInitialConditions
            }

            (self.vp, self.vtsh, self.k05) = patientParams.computeAll()
            
            // Only find steady state if no initial state was passed in (i.e., for Run 1)
            if self.initialState == nil && isInitialConditionsOn {
                self.q = findSteadyState()
            }
        
        
        if initialState != nil {
               print("🚀 SIMULATOR (Run 2) - STARTING...")
               print("   - Initial 'q' vector: \(self.q)")
               print("   - Patient Vp: \(self.vp), Vtsh: \(self.vtsh), k05: \(self.k05)")
           }
            // --- End of Modifications ---

            var results = ThyroidSimulationResult()
            let totalTimeHours = Double(days) * 24.0
            let doseEvents = createDoseEventSchedule()

            var eventIndex = 0
            var currentTime: Double = 0
            let logInterval: Double = 2.0

            logResults(time_hours: currentTime, results: &results)

            while currentTime < totalTimeHours {
                let nextEventTime = (eventIndex < doseEvents.count) ? doseEvents[eventIndex].timeHours : totalTimeHours
                let nextLogTime = currentTime + logInterval
                var stepEndTime = min(nextLogTime, nextEventTime)
                stepEndTime = min(stepEndTime, totalTimeHours)

                let timeStep = stepEndTime - currentTime
                
                if timeStep > 1e-5 {
                    let numSteps = Int((timeStep / dt).rounded(.up))
                    for _ in 0..<numSteps {
                        if currentTime >= stepEndTime { break }
                        rk4Step(t: currentTime, dt: dt)
                        currentTime += dt
                    }
                } else {
                    currentTime = stepEndTime
                }
                
                logResults(time_hours: currentTime, results: &results)
                
                if eventIndex < doseEvents.count && abs(currentTime - nextEventTime) < dt / 2.0 {
                    applyImpulseDose(event: doseEvents[eventIndex])
                    eventIndex += 1
                }
            }
            
            // --- (ADDED) Store the final state of the simulation ---
            results.q_final = self.q

            //printResults(results)
            return results
        }
    // MARK: - Dosing Logic
    private func createDoseEventSchedule() -> [DoseEvent] {
        var events: [DoseEvent] = []
        let totalTimeHours = Double(days) * 24.0

        // Oral T4 Doses
        t4OralDoses.forEach { dose in
            let eventsForDose = createEvents(from: dose, hormone: .t4, type: .oral, totalTime: totalTimeHours)
            events.append(contentsOf: eventsForDose)
        }
        // Oral T3 Doses
        t3OralDoses.forEach { dose in
            let eventsForDose = createEvents(from: dose, hormone: .t3, type: .oral, totalTime: totalTimeHours)
            events.append(contentsOf: eventsForDose)
        }
        // IV T4 Doses
        t4IVDoses.forEach { dose in
            let time = Double(dose.T4IVDoseStart) * 24.0
            if time <= totalTimeHours {
                events.append(DoseEvent(timeHours: time, hormone: .t4, doseType: .iv, amountMicrograms: Double(dose.T4IVDoseInput), rateMicrogramsPerHour: 0))
            }
        }
        // IV T3 Doses
        t3IVDoses.forEach { dose in
            let time = Double(dose.T3IVDoseStart) * 24.0
            if time <= totalTimeHours {
                events.append(DoseEvent(timeHours: time, hormone: .t3, doseType: .iv, amountMicrograms: Double(dose.T3IVDoseInput), rateMicrogramsPerHour: 0))
            }
        }

        // T4 Infusions - Create Start and End events
        t4InfusionDoses.forEach { dose in
            let startTime = Double(dose.T4InfusionDoseStart) * 24.0
            let endTime = Double(dose.T4InfusionDoseEnd) * 24.0
            if startTime <= totalTimeHours {
                events.append(DoseEvent(timeHours: startTime, hormone: .t4, doseType: .infusionStart, amountMicrograms: 0, rateMicrogramsPerHour: Double(dose.T4InfusionDoseInput) / 24.0))
            }
            if endTime <= totalTimeHours {
                events.append(DoseEvent(timeHours: endTime, hormone: .t4, doseType: .infusionEnd, amountMicrograms: 0, rateMicrogramsPerHour: Double(dose.T4InfusionDoseInput) / 24.0))
            }
        }

        // T3 Infusions - Create Start and End events
        t3InfusionDoses.forEach { dose in
            let startTime = Double(dose.T3InfusionDoseStart) * 24.0
            let endTime = Double(dose.T3InfusionDoseEnd) * 24.0
            if startTime <= totalTimeHours {
                events.append(DoseEvent(timeHours: startTime, hormone: .t3, doseType: .infusionStart, amountMicrograms: 0, rateMicrogramsPerHour: Double(dose.T3InfusionDoseInput) / 24.0))
            }
            if endTime <= totalTimeHours {
                events.append(DoseEvent(timeHours: endTime, hormone: .t3, doseType: .infusionEnd, amountMicrograms: 0, rateMicrogramsPerHour: Double(dose.T3InfusionDoseInput) / 24.0))
            }
        }

        return events.sorted()
    }

    private func createEvents<T>(from dose: T, hormone: DoseEvent.HormoneType, type: DoseEvent.DoseType, totalTime: Double) -> [DoseEvent] {
        var doseEvents: [DoseEvent] = []
        let doseAmount: Double, isSingleDose: Bool, startTimeDays: Double, endTimeDays: Double, intervalDays: Double

        switch dose {
            case let d as T4OralDose: (doseAmount, isSingleDose, startTimeDays, endTimeDays, intervalDays) = (Double(d.T4OralDoseInput), d.T4SingleDose, Double(d.T4OralDoseStart), Double(d.T4OralDoseEnd), Double(d.T4OralDoseInterval))
            case let d as T3OralDose: (doseAmount, isSingleDose, startTimeDays, endTimeDays, intervalDays) = (Double(d.T3OralDoseInput), d.T3SingleDose, Double(d.T3OralDoseStart), Double(d.T3OralDoseEnd), Double(d.T3OralDoseInterval))
            default: return []
        }

        let startTimeHours = startTimeDays * 24.0

        if isSingleDose {
            if startTimeHours <= totalTime {
                doseEvents.append(DoseEvent(timeHours: startTimeHours, hormone: hormone, doseType: type, amountMicrograms: doseAmount, rateMicrogramsPerHour: 0))
            }
        } else {
            let endTimeHours = endTimeDays * 24.0
            let intervalHours = intervalDays * 24.0
            if intervalHours > 0 {
                var currentTime = startTimeHours
                while currentTime <= endTimeHours && currentTime <= totalTime {
                    doseEvents.append(DoseEvent(timeHours: currentTime, hormone: hormone, doseType: type, amountMicrograms: doseAmount, rateMicrogramsPerHour: 0))
                    currentTime += intervalHours
                }
            }
        }
        return doseEvents
    }
    
    private func applyImpulseDose(event: DoseEvent) {
        let MW_T4 = 777.0
        let MW_T3 = 651.0

        switch event.doseType {
        case .oral:
            if event.hormone == .t4 {
                q[9] += event.amountMicrograms / MW_T4
            } else {
                q[11] += event.amountMicrograms / MW_T3
            }
        case .iv:
            if event.hormone == .t4 {
                q[0] += event.amountMicrograms / MW_T4
            } else {
                q[3] += event.amountMicrograms / MW_T3
            }
        case .infusionStart:
            // This is handled by a separate infusion rate variable, no impulse needed
            break
        case .infusionEnd:
            // This is handled by a separate infusion rate variable, no impulse needed
            break
        }
    }
    
    // MARK: - Steady-State Solver
    private func findSteadyState() -> [Double] {
            let steadyStateSimulator = ThyroidSimulator(
                t4Secretion: self.t4Secretion, t3Secretion: self.t3Secretion,
                t4Absorption: self.t4Absorption, t3Absorption: self.t3Absorption,
                gender: self.patientParams.sex, height: self.patientParams.height, weight: self.patientParams.weight,
                days: 200, // Run for a long time to ensure steady state
                t3OralDoses: [], t4OralDoses: [], t3IVDoses: [], t4IVDoses: [], t3InfusionDoses: [], t4InfusionDoses: [],
                isInitialConditionsOn: false // Prevent infinite recursion
            )
            
            let result = steadyStateSimulator.runSimulation()
            return result.q_final ?? self.defaultInitialConditions
        }

    // MARK: - Numerical Solver
    private func rk4Step(t: Double, dt: Double) {
        let k1 = calculateDerivatives(q_in: q, t: t)
        let q2 = q.add(k1.multiply(by: 0.5 * dt)); let k2 = calculateDerivatives(q_in: q2, t: t + 0.5 * dt)
        let q3 = q.add(k2.multiply(by: 0.5 * dt)); let k3 = calculateDerivatives(q_in: q3, t: t + 0.5 * dt)
        let q4 = q.add(k3.multiply(by: dt)); let k4 = calculateDerivatives(q_in: q4, t: t + dt)
        let total_deriv = k1.add(k2.multiply(by: 2)).add(k3.multiply(by: 2)).add(k4)
        q = q.add(total_deriv.multiply(by: dt / 6.0))
        q = q.map { max(0, $0) }
    }

    // MARK: - ODE System
    private func calculateDerivatives(q_in: [Double], t: Double, dosing: Bool = true) -> [Double] {
        var dqdt = [Double](repeating: 0.0, count: 19)
        let C = ThyrosimConstants.self
        let t_days = t / 24.0
        
        let (q0_T4p, q1_T4fast, q2_T4slow, q3_T3p, q4_T3fast, q5_T3slow, q6_TSHp, q7_T3B, q8_T3B_lag, q9, q10, q11, q12, q13, q14, q15, q16, q17, q18) =
            (q_in[0], q_in[1], q_in[2], q_in[3], q_in[4], q_in[5], q_in[6], q_in[7], q_in[8],
             q_in[9], q_in[10], q_in[11], q_in[12],
             q_in[13], q_in[14], q_in[15], q_in[16], q_in[17], q_in[18])

        let t4AbsorptionRate = C.k_absorb_T4 * (self.t4Absorption / 88.0)
        let t3AbsorptionRate = C.k_absorb_T3 * (self.t3Absorption / 88.0)

        let pv_ratio = 1.0, slow_scale = 1.0, fast_scale = 1.0
        let q1_temp = q0_T4p / pv_ratio, q2_temp = q1_T4fast / fast_scale, q3_temp = q2_T4slow / slow_scale
        let q4_temp = q3_T3p / pv_ratio, q5_temp = q4_T3fast / fast_scale, q6_temp = q5_T3slow / slow_scale
        let q7_temp = q6_TSHp / pv_ratio
        let q4F = (C.ft3_a + C.ft3_b * q1_temp + C.ft3_c * pow(q1_temp, 2) + C.ft3_d * pow(q1_temp, 3)) * q4_temp
        let q1F = (C.ft4_A + C.ft4_B * q1_temp + C.ft4_C * pow(q1_temp, 2) + C.ft4_D * pow(q1_temp, 3)) * q1_temp

        let SR4 = C.S4 * q18 * (self.t4Secretion / 100.0)
        let SR3 = C.S3 * q18 * (self.t3Secretion / 100.0)

        let f_CIRC = pow(q8_T3B_lag, C.nHill_CIRC) / (pow(q8_T3B_lag, C.nHill_CIRC) + pow(C.KCIRC, C.nHill_CIRC) + epsilon)
        let SR_TSH_Inhib = pow(C.Km_SR_TSH, C.m_SR_TSH) / (pow(C.Km_SR_TSH, C.m_SR_TSH) + pow(q8_T3B_lag, C.m_SR_TSH) + epsilon)
        let SR_TSH_rate = (C.B0 + C.A0 * f_CIRC * sin(2.0 * Double.pi * t_days - C.phi)) * SR_TSH_Inhib
        let fdegTSH = C.kDegTSH + C.VmaxTSH / (C.K50TSH + q7_temp + epsilon)
        let f_LAG = C.f_LAG_base + 2.0 * pow(q7_T3B, 11) / (pow(C.KLAG, 11) + pow(q7_T3B, 11) + epsilon)
        let f4_term = pow(q7_T3B, C.l_hillf3)
        let f4 = C.k7 * (1.0 + (5.0 * pow(C.Kf4_brain, C.l_hillf3)) / (pow(C.Kf4_brain, C.l_hillf3) + f4_term + epsilon))
        let NL = C.Vmax_D1_fast / (C.Km_D1_fast + q2_temp + epsilon)
        
        dqdt[0] = (SR4 + C.k12*q2_temp + C.k13*q3_temp - (C.k31free + C.k21free)*q1F) * pv_ratio + t4AbsorptionRate*q10
        dqdt[1] = (C.k21free*q1F - (C.k12 + C.kDegT4 + NL)*q2_temp) * fast_scale
        let t4_conversion_slow = (C.Vmax_D1_slow / (C.Km_D1_slow + q3_temp + epsilon)) + (C.Vmax_D2_slow / (C.Km_D2_slow + q3_temp + epsilon))
        dqdt[2] = (C.k31free * q1F - (C.k13 + t4_conversion_slow) * q3_temp) * slow_scale
        dqdt[3] = (SR3 + C.k45*q5_temp + C.k46*q6_temp - (C.k64free + C.k54free)*q4F) * pv_ratio + t3AbsorptionRate*q12
        dqdt[4] = (C.k54free * q4F + NL * q2_temp - (C.k45 + self.k05) * q5_temp) * fast_scale
        let t3_production_slow = t4_conversion_slow * q3_temp
        dqdt[5] = (C.k64free * q4F + t3_production_slow - C.k46 * q6_temp) * slow_scale
        dqdt[6] = (SR_TSH_rate - fdegTSH*q7_temp) * pv_ratio
        dqdt[7] = (f4 / C.T4P_eu) * q1_temp + (C.k7 / C.T3P_eu) * q4_temp - C.k_deg_T3B * q7_T3B
        dqdt[8] = f_LAG * (q7_T3B - q8_T3B_lag)

        dqdt[9] = -C.k_pill_T4 * q9
        dqdt[10] = C.k_pill_T4*q9 - (C.k_excrete_T4 + t4AbsorptionRate)*q10
        dqdt[11] = -C.k_pill_T3 * q11
        dqdt[12] = C.k_pill_T3*q11 - (C.k_excrete_T3 + t3AbsorptionRate)*q12
        
        dqdt[13] = (q7_temp - C.k_delay * q13)
        
        dqdt[14] = C.k_delay * (q13 - q14)
        dqdt[15] = C.k_delay * (q14 - q15)
        dqdt[16] = C.k_delay * (q15 - q16)
        dqdt[17] = C.k_delay * (q16 - q17)
        dqdt[18] = C.k_delay * (q17 - q18)
        
    
        
        return dqdt
    }

    // MARK: - Result Logging and Unit Conversion
    private func logResults(time_hours: Double, results: inout ThyroidSimulationResult) {
        let C = ThyrosimConstants.self
        guard vp > 0, vtsh > 0 else { return }
        
        let MW_T4 = 777.0
        let MW_T3 = 651.0
        
        let T4_total_umol = q[0]
        let T3_total_umol = q[3]
        
        let T4_total_umol_L = T4_total_umol / vp
        let T3_total_umol_L = T3_total_umol / vp

        let free_T4_amount_umol = 0.45 * (C.ft4_A + C.ft4_B * T4_total_umol + C.ft4_C * pow(T4_total_umol, 2) + C.ft4_D * pow(T4_total_umol, 3)) * T4_total_umol
        let free_T4_umol_L = free_T4_amount_umol / vp

        let free_T3_amount_umol = 0.5 * (C.ft3_a + C.ft3_b * T4_total_umol + C.ft3_c * pow(T4_total_umol, 2) + C.ft3_d * pow(T4_total_umol, 3)) * T3_total_umol
        let free_T3_umol_L = free_T3_amount_umol / vp
        
        let yT4_total_ug_L = T4_total_umol_L * MW_T4
        let yT3_total_ug_L = T3_total_umol_L * MW_T3
        let yTSH_mU_L = q[6] * 5.6 / vtsh
        
        let yFT4_ng_L = free_T4_umol_L * MW_T4 * 1000.0
        let yFT3_pg_mL = free_T3_umol_L * MW_T3 * 1000.0

        let time_days = time_hours / 24.0
        results.time.append(time_days)
        results.t4.append(yT4_total_ug_L)
        results.t3.append(yT3_total_ug_L)
        results.tsh.append(yTSH_mU_L)
        results.ft4.append(yFT4_ng_L)
        results.ft3.append(yFT3_pg_mL)
    }
    
    private func printResults(_ results: ThyroidSimulationResult) {
            print("--- Thyroid Simulation Results (Run 2) ---")
            
            print("\n--- T4 Data (Time, Value) ---")
            for i in 0..<results.time.count {
                print(String(format: "(%.2f, %.4f)", results.time[i], results.t4[i]))
            }
            
            print("\n--- Free T4 Data (Time, Value) ---")
            for i in 0..<results.time.count {
                print(String(format: "(%.2f, %.4f)", results.time[i], results.ft4[i]))
            }
            
            print("\n--- T3 Data (Time, Value) ---")
            for i in 0..<results.time.count {
                print(String(format: "(%.2f, %.4f)", results.time[i], results.t3[i]))
            }
            
            print("\n--- Free T3 Data (Time, Value) ---")
            for i in 0..<results.time.count {
                print(String(format: "(%.2f, %.4f)", results.time[i], results.ft3[i]))
            }
            
            print("\n--- TSH Data (Time, Value) ---")
            for i in 0..<results.time.count {
                print(String(format: "(%.2f, %.4f)", results.time[i], results.tsh[i]))
            }
            
            print("\n--- End of Simulation Data ---")
        }
    
    
}

// MARK: - Array Helper Extensions
private extension Array where Element == Double {
    func add(_ other: [Double]) -> [Double] { zip(self, other).map(+) }
    func multiply(by scalar: Double) -> [Double] { self.map { $0 * scalar } }
}

private extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
