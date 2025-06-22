import Foundation

struct ThyrosimConstants {
    // Corrected values from the research paper (Table 2)
    static let B0: Double = 1.0        // Basal TSH secretion rate
    static let A0: Double = 1.1        // Amplitude of TSH circadian rhythm
    static let Km: Double = 3.0        // Michaelis-Menten constant for TSH suppression by T3
    static let m: Double = 5.68        // Hill coefficient for TSH suppression
    static let KCIRC: Double = 3.0     // T3 concentration for half-max circadian effect
    static let nHill: Double = 5.68    // Hill coefficient for fCIRC (matches 'm')

    // Other existing constants from your file (some may need review but these are the critical ones)
    static let a: Double = 1.27
    static let n: Double = 0.373
    static let CM: Double = 1.05
    static let base_k05: Double = 0.185
    static let VPref: Double = 2.7749
    static let S4: Double = 0.00278
    static let S3: Double = 0.0015
    static let kDegTSH: Double = 0.1
    static let kDegT4: Double = 0.1
    static let Kf4: Double = 8.4
    static let k3: Double = 0.0589

    // Free hormone constants (these are likely fine)
    static let ft4_A = 0.000289
    static let ft4_B = 0.000214
    static let ft4_C = 0.000128
    static let ft4_D = -0.00000883
    static let ft3_a = 0.015
    static let ft3_b = 0.002
    static let ft3_c = -0.000015
    static let ft3_d = 0.0000002
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
        let VB = ThyrosimConstants.a * pow(100 + delta_iBW, ThyrosimConstants.n - 1.0) * weight
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
