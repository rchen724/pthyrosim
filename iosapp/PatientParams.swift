// PatientParams.swift (Direct Julia Translation)
import Foundation

// Direct translation of Julia plasma volume functions
struct ThyroidPatientParams {
    let height: Double // in meters
    let weight: Double // in kg
    let sex: String

    // Exact V_p function from Julia implementation
    private func V_p(sex: String, BW: Double, height_m: Double) -> Double {
        let idealBW: Double
        let hematocrit: Double

        if sex.lowercased() == "male" {
            // Formula from Julia: 176.3 - 220.6*h + 93.5*h^2
            idealBW = 176.3 - (220.6 * height_m) + (93.5 * pow(height_m, 2))
            hematocrit = 0.45
        } else { // "female"
            // Formula from Julia: 145.8 - 182.7*h + 79.55*h^2
            idealBW = 145.8 - (182.7 * height_m) + (79.55 * pow(height_m, 2))
            hematocrit = 0.4
        }

        let deviBW = 100.0 * (BW - idealBW) / idealBW
        
        // Exact blood volume calculation from Julia
        let Vb_per_kg: Double
        if sex.lowercased() == "male" {
            Vb_per_kg = 71.96 * exp(-0.007516 * deviBW)
        } else {
            Vb_per_kg = 43.65 + 20.79 * exp(-0.01545 * deviBW) + 2.043 * exp(-0.08392 * deviBW)
        }
        
        let Vb = Vb_per_kg * BW / 1000.0
        let specificV_plasma = Vb * (1.0 - hematocrit)

        return specificV_plasma
    }

    /// Computes patient-specific parameters based on the exact Julia implementation.
    func computeAll() -> (VP_new: Double, VTSH_new: Double, k05_new: Double) {

        // Calculate the volume for the current patient
        let patient_vp = V_p(sex: self.sex, BW: self.weight, height_m: self.height)
        
        // Reference patient values from Julia implementation (exact match)
        // Julia uses: male_ref_height = 1.7, female_ref_height = 1.63, ref_bmi = 22.5
        let male_ref_weight = 22.5 * pow(1.7, 2)  // BMI * height^2
        let female_ref_weight = 22.5 * pow(1.63, 2)  // BMI * height^2
        
        let male_ref_vp = V_p(sex: "male", BW: male_ref_weight, height_m: 1.7)
        let fem_ref_vp = V_p(sex: "female", BW: female_ref_weight, height_m: 1.63)
        let avg_ref_vp = (male_ref_vp + fem_ref_vp) / 2.0

        // Normalize the patient's Vp against the reference average
        let VP_new = 3.2 * patient_vp / avg_ref_vp
        
        // Debug: Concise plasma volume info
        print("🔍 Vp: \(self.sex) \(self.height)m \(self.weight)kg → patient=\(String(format: "%.3f", patient_vp)), ref=\(String(format: "%.3f", avg_ref_vp)), final=\(String(format: "%.3f", VP_new))")

        let VTSH_new = 5.2 + (VP_new - 3.2)

        let k05_base = 0.184972339613 / 24.0 // Exact from Julia p[29]

        // Correct k05 calculation from Julia - only sex scaling, no allometric scaling
        let k05_new: Double
        if self.sex.lowercased() == "male" {
            k05_new = 1.0499391485135692 * k05_base  // Exact from Julia p[80] * p[29]
        } else {
            k05_new = k05_base  // Exact from Julia p[29]
        }

        return (VP_new, VTSH_new, k05_new)
    }
}