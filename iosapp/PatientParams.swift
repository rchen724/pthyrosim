import Foundation

struct ThyrosimConstants {
    static let a: Double = 1.27
    static let n: Double = 0.373
    static let CM: Double = 1.05
    static let base_k05: Double = 0.185
    static let VPref: Double = 31.94
    static let S4: Double = 0.00278
    static let S3: Double = 0.0015
    static let kDegT4: Double = 0.05
    static let kDegTSH: Double = 0.1
    static let B0: Double = 450.0
    static let A0: Double = 220.0
    static let Km: Double = 3.1
    static let m: Double = 6.3
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

        let BWref = (sex == "Male") ? 90.63 : 77.47
        let k05_new = (sex == "Male")
            ? ThyrosimConstants.CM * ThyrosimConstants.base_k05 * pow(weight / BWref, 0.75)
            : ThyrosimConstants.base_k05 * pow(weight / BWref, 0.75)

        return (VP_new, VTSH_new, k05_new)
    }
}
