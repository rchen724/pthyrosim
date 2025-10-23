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

// MARK: - Dose Event Structure
private struct DoseEvent: Comparable {
    let timeHours: Double
    let hormone: HormoneType
    let doseType: DoseType
    let amountMicrograms: Double
    let rateMicrogramsPerHour: Double

    static func < (lhs: DoseEvent, rhs: DoseEvent) -> Bool {
        return lhs.timeHours < rhs.timeHours
    }

    enum HormoneType { case t3, t4 }
    enum DoseType { case oral, iv, infusionStart, infusionEnd }
}

// MARK: - Thyroid Simulator Class (Direct Julia Translation)
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
    private var tOffset: Double = 0.0
    var initialState: [Double]? = nil

    private let dt: Double = 0.05 // Smaller time step for higher accuracy (closer to Rodas5)
    private var q: [Double]
    
    // Exact initial conditions from Julia code
    private let defaultInitialConditions: [Double] = [
        0.322114215761171, 0.201296960359917, 0.638967411907560, 0.00663104034826483, 0.0112595761822961,
        0.0652960640300348, 1.78829584764370, 7.05727560072869, 7.05714474742141, 0, 0, 0, 0,
        3.34289716182018, 3.69277248068433, 3.87942133769244, 3.90061903207543, 3.77875734283571, 3.55364471589659
    ]

    private var vp: Double = 3.2
    private var vtsh: Double = 5.2
    private var k05: Double = 0.184972339613 / 24.0
    private let epsilon: Double = 1e-9
    
    // Infusion rates (in micrograms per hour)
    private var t4InfusionRate: Double = 0.0
    private var t3InfusionRate: Double = 0.0
    
    // Keeps starting concentrations the same after vp/vtsh scaling,
    // and aligns the TSH delay chain to avoid the initial swoop.
    private func seedICsForNoRecalcJump() {
        self.q = self.defaultInitialConditions

        let vpRatio   = vp   / 3.2
        let vtshRatio = vtsh / 5.2

        // Keep concentrations constant when vp/vtsh change
        q[0] *= vpRatio   // T4 plasma
        q[3] *= vpRatio   // T3 plasma
        q[6] *= vtshRatio // TSH plasma

        // Align TSH lag compartments with TSHp
        for i in 13...18 { q[i] = q[6] }
    }
    
    

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
    func runSimulation() -> ThyroidSimulationResult {
        
        (self.vp, self.vtsh, self.k05) = patientParams.computeAll()
        
        // Debug plasma volume calculation
        print("🔍 DEBUG - Plasma Volume Calculation:")
        print("   Patient: \(patientParams.sex), Height: \(patientParams.height)m, Weight: \(patientParams.weight)kg")
        print("   Calculated VP: \(self.vp)")
        print("   Calculated VTSH: \(self.vtsh)")
        print("   Calculated k05: \(self.k05)")
        
        // Set initial state
        if let initialState = self.initialState {
            // For Run 2: use the provided initial state (from Run 1's final state)
            self.q = initialState
        } else {
            // For Run 1: start with default conditions
            self.q = self.defaultInitialConditions
            // Find steady state if requested
            if isInitialConditionsOn {
                self.q = findSteadyState()
            } else {
                seedICsForNoRecalcJump()
            }
        }
    
        if initialState != nil {
            print("🚀 SIMULATOR (Run 2) - STARTING...")
            print("   - Initial 'q' vector: \(self.q)")
            print("   - Patient Vp: \(self.vp), Vtsh: \(self.vtsh), k05: \(self.k05)")
            
        }

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
            let t4_total_ug_L_start = q[0] * 777.0 / vp

            let ft4_ng_L_start: Double = {
                // same formula you use in logResults, just local for the print
                let q0 = q[0]
                let free_T4_amount_umol =
                    1.1 * 0.45
                    * (0.000289 + 0.000214*q0 + 0.000128*q0*q0 - 8.83e-6*q0*q0*q0)
                    * q0
                let free_T4_umol_L = free_T4_amount_umol / vp
                return free_T4_umol_L * 777.0 * 1000.0
            }()

            print(String(format: "START TT4 = %.2f ug/L | START FT4 = %.0f ng/L",
                         t4_total_ug_L_start, ft4_ng_L_start))
            
            if eventIndex < doseEvents.count && abs(currentTime - nextEventTime) < dt / 2.0 {
                applyImpulseDose(event: doseEvents[eventIndex])
                eventIndex += 1
            }
        }
        
        // Store the final state of the simulation
        results.q_final = self.q

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

    private func createEvents<T>(
        from dose: T,
        hormone: DoseEvent.HormoneType,
        type: DoseEvent.DoseType,
        totalTime: Double
    ) -> [DoseEvent] {
        var doseEvents: [DoseEvent] = []

        let doseAmount: Double, isSingle: Bool
        let startDays: Double, endDays: Double, intervalDays: Double

        switch dose {
        case let d as T4OralDose:
            (doseAmount, isSingle, startDays, endDays, intervalDays) =
                (Double(d.T4OralDoseInput), d.T4SingleDose,
                 Double(d.T4OralDoseStart), Double(d.T4OralDoseEnd), Double(d.T4OralDoseInterval))

        case let d as T3OralDose:
            (doseAmount, isSingle, startDays, endDays, intervalDays) =
                (Double(d.T3OralDoseInput), d.T3SingleDose,
                 Double(d.T3OralDoseStart), Double(d.T3OralDoseEnd), Double(d.T3OralDoseInterval))

        default: return []
        }

        let eps  = 1e-6
        let startH = startDays * 24.0
        let endH   = endDays   * 24.0
        let intH   = max(intervalDays * 24.0, 1e-9)

        if isSingle {
            // If start is 0, nudge to epsilon so it doesn't alter the t=0 intercept
            let t = max(startH, eps)
            if t <= totalTime {
                doseEvents.append(.init(timeHours: t, hormone: hormone, doseType: type,
                                        amountMicrograms: doseAmount, rateMicrogramsPerHour: 0))
            }
        } else {
            // first at start + interval (Julia-like) and never at t=0
            var t = max(startH + intH, eps)
            while t <= endH && t <= totalTime {
                doseEvents.append(.init(timeHours: t, hormone: hormone, doseType: type,
                                        amountMicrograms: doseAmount, rateMicrogramsPerHour: 0))
                t += intH
            }
        }

        return doseEvents.sorted()
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
            // Start infusion by setting the infusion rate
            if event.hormone == .t4 {
                t4InfusionRate = event.rateMicrogramsPerHour
            } else {
                t3InfusionRate = event.rateMicrogramsPerHour
            }
        case .infusionEnd:
            // Stop infusion by setting the infusion rate to zero
            if event.hormone == .t4 {
                t4InfusionRate = 0.0
            } else {
                t3InfusionRate = 0.0
            }
        }
    }
    
    // MARK: - Steady-State Solver
    private func findSteadyState() -> [Double] {
        let steadyStateSimulator = ThyroidSimulator(
            t4Secretion: self.t4Secretion, t3Secretion: self.t3Secretion,
            t4Absorption: self.t4Absorption, t3Absorption: self.t3Absorption,
            gender: self.patientParams.sex, height: self.patientParams.height, weight: self.patientParams.weight,
            days: 30, // Exact match to Julia: run simulation for 30 days to get approximate steady state
            t3OralDoses: [], t4OralDoses: [], t3IVDoses: [], t4IVDoses: [], t3InfusionDoses: [], t4InfusionDoses: [],
            isInitialConditionsOn: false // Prevent infinite recursion
        )
        
        let result = steadyStateSimulator.runSimulation()
        return result.q_final ?? self.defaultInitialConditions
    }

    // MARK: - Higher-Order Numerical Solver (Closer to Julia Rodas5)
    private func rk4Step(t: Double, dt: Double) {
        // Use 5th-order Runge-Kutta method for higher accuracy (closer to Rodas5)
        let k1 = calculateDerivatives(q_in: q, t: t)
        let q2 = q.add(k1.multiply(by: 0.25 * dt))
        let k2 = calculateDerivatives(q_in: q2, t: t + 0.25 * dt)
        
        let q3 = q.add(k1.multiply(by: 0.125 * dt)).add(k2.multiply(by: 0.125 * dt))
        let k3 = calculateDerivatives(q_in: q3, t: t + 0.25 * dt)
        
        let q4 = q.add(k1.multiply(by: -0.5 * dt)).add(k2.multiply(by: 0.5 * dt)).add(k3.multiply(by: dt))
        let k4 = calculateDerivatives(q_in: q4, t: t + 0.5 * dt)
        
        let q5 = q.add(k1.multiply(by: 0.1875 * dt)).add(k3.multiply(by: 0.5625 * dt)).add(k4.multiply(by: 0.1875 * dt))
        let k5 = calculateDerivatives(q_in: q5, t: t + 0.75 * dt)
        
        let q6 = q.add(k1.multiply(by: -0.3 * dt)).add(k2.multiply(by: 0.9 * dt)).add(k3.multiply(by: -1.2 * dt)).add(k4.multiply(by: 1.8 * dt)).add(k5.multiply(by: 0.6 * dt))
        let k6 = calculateDerivatives(q_in: q6, t: t + dt)
        
        // 5th-order Runge-Kutta formula (Butcher tableau)
        let total_deriv = k1.multiply(by: 7.0/90.0)
            .add(k3.multiply(by: 32.0/90.0))
            .add(k4.multiply(by: 12.0/90.0))
            .add(k5.multiply(by: 32.0/90.0))
            .add(k6.multiply(by: 7.0/90.0))
        
        q = q.add(total_deriv.multiply(by: dt))
        q = q.map { max(0, $0) }
        
        // Additional precision: ensure small values don't accumulate numerical errors
        q = q.map { abs($0) < 1e-12 ? 0.0 : $0 }
    }

    // MARK: - ODE System (Exact Julia Translation with Proper Oscillations)
    private func calculateDerivatives(q_in: [Double], t: Double, dosing: Bool = true) -> [Double] {
        var dqdt = [Double](repeating: 0.0, count: 19)
        
        // Exact Julia parameters
        let kdelay = 5.0 / 8.0
        
        // Volume scaling ratios (from Julia p[69]^p[71], p[74]^p[71], p[75]^p[71])
        // Julia: p[69] = predict_Vp(height, weight, sex) / ref_Vp, p[71] = 1.0
        // So plasma_volume_ratio = (patient_Vp / reference_Vp)^1.0 = patient_Vp / reference_Vp
        let patient_Vp = vp
        let reference_Vp = 3.2  // Julia's default reference plasma volume
        let plasma_volume_ratio = patient_Vp / reference_Vp
        let slow_volume_ratio = 1.0    // p[74]^p[71] = 1.0^1.0 = 1.0
        let fast_volume_ratio = 1.0    // p[75]^p[71] = 1.0^1.0 = 1.0
        
        // Scale compartment sizes (exact from Julia)
        let q1 = q_in[0] * 1.0 / plasma_volume_ratio  // q[1] * 1 / p[69]
        let q2 = q_in[1] * 1.0  // q[2] * 1
        let q3 = q_in[2] * 1.0  // q[3] * 1
        let q4 = q_in[3] * 1.0 / plasma_volume_ratio  // q[4] * 1 / p[69]
        let q5 = q_in[4] * 1.0  // q[5] * 1
        let q6 = q_in[5] * 1.0  // q[6] * 1
        let q7 = q_in[6] * 1.0 / plasma_volume_ratio  // q[7] * 1 / p[69]

        // Auxiliary equations (exact from Julia)
        let q4F = (0.00395 + 0.00185 * q1 + 0.00061 * pow(q1, 2) + (-0.000505) * pow(q1, 3)) * q4  // FT3p
        let q1F = (0.000289 + 0.000214 * q1 + 0.000128 * pow(q1, 2) + (-8.83e-6) * pow(q1, 3)) * q1  // FT4p
        let SR3 = (0.00033572 * (self.t3Secretion / 100.0) * q_in[18])  // Brain delay (dial 3) - CORRECTED INDEX
        let SR4 = (0.0027785399344 * (self.t4Secretion / 100.0) * q_in[18])  // Brain delay (dial 1) - CORRECTED INDEX
        let fCIRC = pow(q_in[8], 5.674773816316) / (pow(q_in[8], 5.674773816316) + pow(3.001011022378, 5.674773816316))
        let SRTSH = (450.0 + 219.7085301388 * fCIRC * sin(Double.pi / 12.0 * t - (-3.71))) * (pow(3.094711690204, 6.290803221796) / (pow(3.094711690204, 6.290803221796) + pow(q_in[8], 6.290803221796)))
        let fdegTSH = 0.53 + 0.226 / (23.0 + q7)
        let fLAG = 0.0034 + 2.0 * pow(q_in[7], 11) / (pow(5.0, 11) + pow(q_in[7], 11))
        let f4 = 0.058786935033 * (1.0 + 5.0 * pow(8.498343729591, 14.36664496926) / (pow(8.498343729591, 14.36664496926) + pow(q_in[7], 14.36664496926)))
        let NL = 0.012101809339 / (2.85 + q2)

        // ODEs (exact from Julia - note: Julia uses 1-based indexing, iOS uses 0-based)
        // Julia dq[1] = p[81] + (SR4 + p[3] * q2 + p[4] * q3 - (p[5] + p[6]) * q1F) * plasma_volume_ratio + p[11] * q[11]
        dqdt[0] = t4InfusionRate / 777.0 + (SR4 + 0.868 * q2 + 0.108 * q3 - (584.0 + 1503.0) * q1F) * plasma_volume_ratio + 0.88 * q_in[10]
        
        // Julia dq[2] = (p[6] * q1F - (p[3] + p[12] + NL) * q2)
        dqdt[1] = (1503.0 * q1F - (0.868 + 0.0189 + NL) * q2)
        
        // Julia dq[3] = (p[5] * q1F -(p[4] + p[15] / (p[16] + q3) + p[17] /(p[18] + q3)) * q3)
        dqdt[2] = (584.0 * q1F - (0.108 + 0.000663 / (95.0 + q3) + 0.00074619 / (0.075 + q3)) * q3)
        
        // Julia dq[4] = p[82] + (SR3 + p[20] * q5 + p[21] * q6 - (p[22] + p[23]) * q4F) * plasma_volume_ratio + p[28] * q[13]
        dqdt[3] = t3InfusionRate / 651.0 + (SR3 + 5.37 * q5 + 0.0689 * q6 - (127.0 + 2043.0) * q4F) * plasma_volume_ratio + 0.88 * q_in[12]
        
        // Julia dq[5] = (p[23] * q4F + NL * q2 - (p[20] + p[29]) * q5)
        dqdt[4] = (2043.0 * q4F + NL * q2 - (5.37 + self.k05 * 24.0) * q5)
        
        // Julia dq[6] = (p[22] * q4F + p[15] * q3 / (p[16] + q3) + p[17] * q3 / (p[18] + q3) -(p[21])*q6)
        dqdt[5] = (127.0 * q4F + (0.000663 / (95.0 + q3) + 0.00074619 / (0.075 + q3)) * q3 - 0.0689 * q6)
        
        // Julia dq[7] = (SRTSH - fdegTSH * q7) * plasma_volume_ratio
        dqdt[6] = (SRTSH - fdegTSH * q7) * plasma_volume_ratio
        
        // Julia dq[8] = f4 / p[38] * q1 + p[37] / p[39] * q4 - p[40] * q[8]
        dqdt[7] = f4 / 0.29 * q1 + 0.058786935033 / 0.006 * q4 - 0.037 * q_in[7]
        
        // Julia dq[9] = fLAG * (q[8] - q[9])
        dqdt[8] = fLAG * (q_in[7] - q_in[8])

        // Julia dq[10] = -p[43] * q[10]
        dqdt[9] = -1.3 * q_in[9]
        
        // Julia dq[11] = p[43] * q[10] - (p[44] * p[58]+ p[11]) * q[11]
        // p[58] = dial[2] = t4Absorption/100 (convert from 0-100 to 0-1 range), p[44] = 0.12, p[11] = 0.88
        dqdt[10] = 1.3 * q_in[9] - (0.12 * (self.t4Absorption / 100.0) + 0.88) * q_in[10]
        
        // Julia dq[12] = -p[45] * q[12]
        dqdt[11] = -1.78 * q_in[11]
        
        // Julia dq[13] = p[45] * q[12] - (p[46] * p[60] + p[28]) * q[13]
        // p[60] = dial[4] = t3Absorption/100 (convert from 0-100 to 0-1 range), p[46] = 0.12, p[28] = 0.88
        dqdt[12] = 1.78 * q_in[11] - (0.12 * (self.t3Absorption / 100.0) + 0.88) * q_in[12]
        
        // Delay ODEs (exact from Julia - Julia dq[14] = kdelay * (q7 - q[14]))
        dqdt[13] = kdelay * (q7 - q_in[13])  // Julia delay1
        dqdt[14] = kdelay * (q_in[13] - q_in[14])  // Julia delay2
        dqdt[15] = kdelay * (q_in[14] - q_in[15])  // Julia delay3
        dqdt[16] = kdelay * (q_in[15] - q_in[16])  // Julia delay4
        dqdt[17] = kdelay * (q_in[16] - q_in[17])  // Julia delay5
        dqdt[18] = kdelay * (q_in[17] - q_in[18])  // Julia delay6
        
        return dqdt
    }

    // MARK: - Result Logging and Unit Conversion (Exact Julia Translation)
    private func logResults(time_hours: Double, results: inout ThyroidSimulationResult) {
        guard vp > 0, vtsh > 0 else { return }
        
        let MW_T4 = 777.0
        let MW_T3 = 651.0
        
        let T4_total_umol = q[0]
        let T3_total_umol = q[3]
        
        // Exact calculations matching Julia code: MW * compartment_value / plasma_volume
        let yT4_total_ug_L = T4_total_umol * MW_T4 / vp
        let yT3_total_ug_L = T3_total_umol * MW_T3 / vp
        
        // Debug: Concise output for final values only
        if time_hours >= Double(days) * 24.0 - 1.0 { // Near end of simulation
            print("🔍 T4: q[0]=\(String(format: "%.6f", T4_total_umol)), vp=\(String(format: "%.3f", vp)), Total=\(String(format: "%.1f", yT4_total_ug_L))")
            print("🔍 T3: q[3]=\(String(format: "%.6f", T3_total_umol)), vp=\(String(format: "%.3f", vp)), Total=\(String(format: "%.1f", yT3_total_ug_L))")
        }
        

        // Exact free hormone calculations from Julia
        let free_T4_amount_umol = 1.1 * 0.45 * (0.000289 + 0.000214 * T4_total_umol + 0.000128 * pow(T4_total_umol, 2) + (-8.83e-6) * pow(T4_total_umol, 3)) * T4_total_umol
        let free_T4_umol_L = free_T4_amount_umol / vp

        let free_T3_amount_umol = 1.05 * 0.5 * (0.00395 + 0.00185 * T4_total_umol + 0.00061 * pow(T4_total_umol, 2) + (-0.000505) * pow(T4_total_umol, 3)) * T3_total_umol
        let free_T3_umol_L = free_T3_amount_umol / vp
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
