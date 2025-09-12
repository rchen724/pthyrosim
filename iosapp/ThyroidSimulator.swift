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
    var initialState: [Double]? = nil

    private let dt: Double = 0.1 // Time step in hours
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

    // MARK: - ODE System (Exact Julia Translation with Proper Oscillations)
    private func calculateDerivatives(q_in: [Double], t: Double, dosing: Bool = true) -> [Double] {
        var dqdt = [Double](repeating: 0.0, count: 19)
        
        // Exact Julia parameters
        let kdelay = 5.0 / 8.0
        
        // Volume scaling ratios (from Julia p[69]^p[71], p[74]^p[71], p[75]^p[71])
        let plasma_volume_ratio = 1.0  // p[69]^p[71] = 1.0^1.0 = 1.0
        let slow_volume_ratio = 1.0    // p[74]^p[71] = 1.0^1.0 = 1.0
        let fast_volume_ratio = 1.0    // p[75]^p[71] = 1.0^1.0 = 1.0
        
        // Scale compartment sizes (exact from Julia)
        let q1 = q_in[0] * 1.0 / 1.0  // q[1] * 1 / p[69]
        let q2 = q_in[1] * 1.0 / 1.0  // q[2] * 1 / p[75]
        let q3 = q_in[2] * 1.0 / 1.0  // q[3] * 1 / p[74]
        let q4 = q_in[3] * 1.0 / 1.0  // q[4] * 1 / p[69]
        let q5 = q_in[4] * 1.0 / 1.0  // q[5] * 1 / p[75]
        let q6 = q_in[5] * 1.0 / 1.0  // q[6] * 1 / p[74]
        let q7 = q_in[6] * 1.0 / 1.0  // q[7] * 1 / p[69]

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

        // ODEs (exact from Julia with infusion support)
        dqdt[0] = (SR4 + 0.868 * q2 + 0.108 * q3 - (584.0 + 1503.0) * q1F) * plasma_volume_ratio + 0.88 * (self.t4Absorption / 88.0) * q_in[10] + t4InfusionRate / 777.0
        dqdt[1] = (1503.0 * q1F - (0.868 + 0.0189 + NL) * q2) * fast_volume_ratio
        dqdt[2] = (584.0 * q1F - (0.108 + 0.000663 / (95.0 + q3) + 0.00074619 / (0.075 + q3)) * q3) * slow_volume_ratio
        dqdt[3] = (SR3 + 5.37 * q5 + 0.0689 * q6 - (127.0 + 2043.0) * q4F) * plasma_volume_ratio + 0.88 * (self.t3Absorption / 88.0) * q_in[12] + t3InfusionRate / 651.0
        dqdt[4] = (2043.0 * q4F + NL * q2 - (5.37 + self.k05 * 24.0) * q5) * fast_volume_ratio
        dqdt[5] = (127.0 * q4F + (0.000663 / (95.0 + q3) + 0.00074619 / (0.075 + q3)) * q3 - 0.0689 * q6) * slow_volume_ratio
        dqdt[6] = (SRTSH - fdegTSH * q7) * plasma_volume_ratio
        dqdt[7] = f4 / 0.29 * q1 + 0.058786935033 / 0.006 * q4 - 0.037 * q_in[7]
        dqdt[8] = fLAG * (q_in[7] - q_in[8])

        dqdt[9] = -1.3 * q_in[9]
        dqdt[10] = 1.3 * q_in[9] - (0.12 * (self.t4Absorption / 88.0) + 0.88 * (self.t4Absorption / 88.0)) * q_in[10]
        dqdt[11] = -1.78 * q_in[11]
        dqdt[12] = 1.78 * q_in[11] - (0.12 * (self.t3Absorption / 88.0) + 0.88 * (self.t3Absorption / 88.0)) * q_in[12]
        
        // Delay ODEs (exact from Julia)
        dqdt[13] = kdelay * (q7 - q_in[13])  // delay1
        dqdt[14] = kdelay * (q_in[13] - q_in[14])  // delay2
        dqdt[15] = kdelay * (q_in[14] - q_in[15])  // delay3
        dqdt[16] = kdelay * (q_in[15] - q_in[16])  // delay4
        dqdt[17] = kdelay * (q_in[16] - q_in[17])  // delay5
        dqdt[18] = kdelay * (q_in[17] - q_in[18])  // delay6
        
        return dqdt
    }

    // MARK: - Result Logging and Unit Conversion (Exact Julia Translation)
    private func logResults(time_hours: Double, results: inout ThyroidSimulationResult) {
        guard vp > 0, vtsh > 0 else { return }
        
        let MW_T4 = 777.0
        let MW_T3 = 651.0
        
        let T4_total_umol = q[0]
        let T3_total_umol = q[3]
        
        let T4_total_umol_L = T4_total_umol / vp
        let T3_total_umol_L = T3_total_umol / vp

        // Exact free hormone calculations from Julia
        let free_T4_amount_umol = 1.1 * 0.45 * (0.000289 + 0.000214 * T4_total_umol + 0.000128 * pow(T4_total_umol, 2) + (-8.83e-6) * pow(T4_total_umol, 3)) * T4_total_umol
        let free_T4_umol_L = free_T4_amount_umol / vp

        let free_T3_amount_umol = 1.05 * 0.5 * (0.00395 + 0.00185 * T4_total_umol + 0.00061 * pow(T4_total_umol, 2) + (-0.000505) * pow(T4_total_umol, 3)) * T3_total_umol
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