// PatientParams.swift (Corrected & Final)
import Foundation

struct ThyrosimConstants {
    // MARK: - Patient-Independent Model Parameters (All rates are per HOUR)
    // Values are sourced from the Python script and converted from per-day to per-hour rates by dividing by 24.

    static let S4: Double = (0.06648 * 17) / 24.0
    static let S3: Double = (0.008064 * 17) / 24.0
    static let kDegT4: Double = 0.4536 / 24.0 // k02 in Python

    // TSH Secretion Sub-model
    static let B0: Double = 10800.0 / 24.0
    static let A0: Double = 5272.8 / 24.0
    static let phi: Double = -0.154583 // This is a phase shift, unitless
    static let kDegTSH: Double = 12.72 / 24.0 // kdegTSH-HYPO
    static let VmaxTSH: Double = 5.424 / 24.0
    static let K50TSH: Double = 23.0
    static let k7: Double = 1.41072 / 24.0 // k3 in Python
    static let T4P_eu: Double = 0.29
    static let T3P_eu: Double = 0.006
    static let k_deg_T3B: Double = 0.888 / 24.0 // KdegT3B
    static let f_LAG_base: Double = 0.0816 / 24.0 // KLAG-HYPO
    static let KLAG: Double = 5.0 // Original value from Python params[41]
    static let KCIRC: Double = 3.00101 // K_circ
    static let Km_SR_TSH: Double = 3.0947 // K_srTSH
    static let nHill_CIRC: Double = 5.6747 // n_hillcirc
    static let m_SR_TSH: Double = 6.2908 // m_hillcirc
    static let Kf4_brain: Double = 8.4983 // K_f4
    static let l_hillf3: Double = 14.366 // l_hillf3

    // Free Hormone Calculation (Polynomial coefficients)
    static let ft4_A = 0.000289, ft4_B = 0.000214, ft4_C = 0.000128, ft4_D = -0.00000883
    static let ft3_a = 0.00395, ft3_b = 0.00185, ft3_c = 0.00061, ft3_d = -0.000505

    // Inter-compartmental rates (per hour)
    static let k12: Double = 20.832 / 24.0
    static let k13: Double = 2.592 / 24.0
    static let k31free: Double = 14016.0 / 24.0
    static let k21free: Double = 36072.0 / 24.0
    static let k45: Double = 128.88 / 24.0
    static let k46: Double = 1.6536 / 24.0
    static let k64free: Double = 3048.0 / 24.0
    static let k54free: Double = 49032.0 / 24.0

    // Deiodinase Parameters
    static let Vmax_D1_fast: Double = 0.2904 / 24.0
    static let Km_D1_fast: Double = 2.85 // Original value from Python params[13]
    static let Vmax_D1_slow: Double = 0.015912 / 24.0
    static let Km_D1_slow: Double = 95.0 // Original value from Python params[15]
    static let Vmax_D2_slow: Double = 0.01776 / 24.0 // Original value from Python params[16]
    static let Km_D2_slow: Double = 0.075

    // Gut Absorption Model
    static let k_pill_T4: Double = 31.2 / 24.0 // k4dissolve
    static let k_excrete_T4: Double = 2.88 / 24.0 // k4excrete
    static let k_absorb_T4: Double = 21.12 / 24.0 // k4absorb
    static let k_pill_T3: Double = 42.72 / 24.0 // k3dissolve
    static let k_excrete_T3: Double = 2.88 / 24.0 // k3excrete
    static let k_absorb_T3: Double = 21.12 / 24.0 // k3absorb

    // TSH Delay constant
    static let k_delay: Double = 15.0 // This is used in a formula where time is in days
}

// CORRECTED PatientParams.swift
struct ThyroidPatientParams {
    let height: Double // in meters
    let weight: Double // in kg
    let sex: String

    // Direct translation of the V_p function from the Python notebook
    private func V_p(sex: String, BW: Double, height_m: Double) -> Double {
        let idealBW: Double
        let hematocrit: Double

        if sex.lowercased() == "male" {
            // Formula from Python: 176.3 - 220.6*h + 93.5*h^2
            idealBW = 176.3 - (220.6 * height_m) + (93.5 * pow(height_m, 2))
            hematocrit = 0.45
        } else { // "female"
            // Formula from Python: 145.8 - 182.7*h + 79.55*h^2
            idealBW = 145.8 - (182.7 * height_m) + (79.55 * pow(height_m, 2))
            hematocrit = 0.4
        }

        let deviBW = 100.0 * (BW - idealBW) / idealBW
        // Python: 1.27*BW*(100+deviBW)**(0.373-1). (0.373-1) is -0.627
        let specificV_blood = 1.27 * BW * pow(100.0 + deviBW, -0.627)
        let specificV_plasma = specificV_blood * (1.0 - hematocrit)

        return specificV_plasma
    }

    /// Computes patient-specific parameters based on the Python `newsolver3` function.
    func computeAll() -> (VP_new: Double, VTSH_new: Double, k05_new: Double) {

        // This calculates the volume for the current patient
        let patient_vp = V_p(sex: self.sex, BW: self.weight, height_m: self.height)

        // These are the reference patient values from the Python script
        let male_ref_vp = V_p(sex: "male", BW: 67.61, height_m: 1.7608)
        let fem_ref_vp = V_p(sex: "female", BW: 64.06, height_m: 1.669)
        let avg_ref_vp = (male_ref_vp + fem_ref_vp) / 2.0

        // Normalize the patient's Vp against the reference average
        let VP_new = 3.2 * patient_vp / avg_ref_vp

        let VTSH_new = 5.2 + (VP_new - 3.2)

        let k05_base = 4.43928 / 24.0 // Base k05 per hour

        let k05_new: Double
        if self.sex.lowercased() == "male" {
            k05_new = 1.05 * k05_base * pow(self.weight / 67.61, 0.75)
        } else {
            k05_new = k05_base * pow(self.weight / 64.06, 0.75)
        }

        return (VP_new, VTSH_new, k05_new)
    }
}
