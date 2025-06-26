import Foundation

struct ThyrosimConstants {
    // MARK: - Patient-Independent Model Parameters

    // Secretion & Degradation
    static let S4: Double = 0.00278      // T4 secretion parameter
    static let S3: Double = 0.0015       // T3 secretion parameter (direct)
    static let kDegT4: Double = 0.1      // T4 degradation rate constant (in plasma)
    static let kDegT3: Double = 0.8      // T3 degradation rate constant (in plasma)
    static let kDegTSH: Double = 0.1     // Basal TSH degradation rate constant

    // TSH Secretion Sub-model (Brain-Pituitary)
    static let B0: Double = 450.0        // Basal TSH secretion rate
    static let A0: Double = 220.0        // Amplitude of TSH circadian rhythm
    static let Km_SR_TSH: Double = 3.1   // Michaelis-Menten constant for TSH suppression by T3
    static let m_SR_TSH: Double = 6.29   // Hill coefficient for TSH suppression
    static let KCIRC: Double = 3.0       // T3 concentration for half-max circadian effect
    static let nHill_CIRC: Double = 5.68 // Hill coefficient for fCIRC
    static let k7: Double = 0.0589       // T3 transport/conversion param in brain (k3 in old code)
    static let Kf4_brain: Double = 8.5   // Hill constant for T4 to T3 conversion in brain
    static let k_deg_T3B: Double = 0.05  // T3 degradation in brain
    static let f_LAG: Double = 0.1       // Lag parameter for T3 effect in brain

    // Free Hormone Calculation (Polynomial coefficients)
    static let ft4_A = 0.000289, ft4_B = 0.000214, ft4_C = 0.000128, ft4_D = -0.00000883
    static let ft3_a = 0.015,    ft3_b = 0.002,    ft3_c = -0.000015,  ft3_d = 0.0000002

    // Inter-compartmental Transfer Rates (k_ij means from compartment i to j)
    static let k21: Double = 0.0125  // T4 Fast -> Plasma
    static let k12: Double = 0.0245  // T4 Plasma -> Fast
    static let k31: Double = 0.0003  // T4 Slow -> Plasma
    static let k13: Double = 0.0021  // T4 Plasma -> Slow
    static let k54: Double = 0.09    // T3 Fast -> Plasma
    static let k45: Double = 0.27    // T3 Plasma -> Fast
    static let k64: Double = 0.001  // T3 Slow -> Plasma
    static let k46: Double = 0.011  // T3 Plasma -> Slow
    
    // Deiodinase Parameters (T4 -> T3 conversion)
    // D1 Fast Tissue
    static let Vmax_D1_fast: Double = 1.81
    static let Km_D1_fast: Double = 3.08
    // D2 Fast Tissue
    static let Vmax_D2_fast: Double = 0.8
    static let Km_D2_fast: Double = 0.02
    // D1 Slow Tissue
    static let Vmax_D1_slow: Double = 0.2
    static let Km_D1_slow: Double = 3.08
    // D2 Slow Tissue
    static let Vmax_D2_slow: Double = 0.01
    static let Km_D2_slow: Double = 0.02

    // Gut Absorption Model
    static let k_pill_T4: Double = 1.0
    static let k_gut_T4: Double = 1.0
    static let k_absorb_T4: Double = 0.05
    
    static let k_pill_T3: Double = 1.0
    static let k_gut_T3: Double = 1.0
    static let k_absorb_T3: Double = 0.05

    // MARK: - Patient-Specific Scaling Parameters
    static let a_vb: Double = 1.27, n_vb: Double = 0.373
    static let CM: Double = 1.05, base_k05: Double = 0.185
    static let VPref: Double = 2.7749
    static let BW_M_ref: Double = 67.528, BW_F_ref: Double = 64.145
}


struct ThyroidPatientParams {
    let height: Double
    let weight: Double
    let sex: String

    func computeAll() -> (VP_new: Double, VTSH_new: Double, k05_new: Double) {
        let iBW: Double = sex == "Male"
            ? 176.3 - 220.6 * height + 93.5 * pow(height, 2)
            : 145.8 - 182.7 * height + 79.55 * pow(height, 2)

        let delta_iBW = 100 * (weight - iBW) / iBW
        let VB = ThyrosimConstants.a_vb * pow(100 + delta_iBW, ThyrosimConstants.n_vb - 1.0) * weight
        let HEM = (sex == "Male") ? 0.45 : 0.4
        let VP = VB * (1 - HEM)

        let VP_new = 3.2 * VP / ThyrosimConstants.VPref
        let VTSH_new = 5.2 + (VP_new - 3.2)

        let BWref = (sex == "Male") ? 67.528 : 64.145
        let k05_new = (sex == "Male")
            ? ThyrosimConstants.CM * ThyrosimConstants.base_k05 * pow(weight / BWref, 0.75)
            : ThyrosimConstants.base_k05 * pow(weight / BWref, 0.75)

        return (VP_new, VTSH_new, k05_new)
    }
}
