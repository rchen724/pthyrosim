//
//  PatientParams.swift
//  iosapp
//
//  Created by Shruthi Sathya on 4/22/25.
//
import Foundation

struct ThyrosimConstants {
    static let a: Double = 1.27
    static let n: Double = 0.373
    static let CM: Double = 1.05
    static let base_k05: Double = 0.185
    static let VPref: Double = 1.144//3.199
}

struct ThyroidPatientParams {
    let height: Double  // in meters
    let weight: Double  // in kg
    let sex: String     // "Male" or "Female"
    
    func computeAll() -> (VP_new: Double, VTSH_new: Double, k05_new: Double) {
        // 1. Ideal Body Weight (iBW)
        let iBW: Double
        if sex == "Male" {
            iBW = 176.3 - 220.6 * height + 93.5 * pow(height, 2)
        } else {
            iBW = 145.8 - 182.7 * height + 79.55 * pow(height, 2)
        }
        
        let delta_iBW = 100 * (weight-iBW)/iBW
        
        let VB = ThyrosimConstants.a * pow(100+delta_iBW, ThyrosimConstants.n - 1.0) * weight
        
        let HEM = (sex=="Male") ? 0.45:0.4
        let VP = VB * (1-HEM)
        //
        //
        //        let iBW_male = 176.3 - 220.6 * height + 93.5 * pow(height, 2)
        //        let iBW_female = 145.8 - 182.7 * height + 79.55 * pow(height, 2)
        //        let delta_iBW_male = 100 * (weight-iBW_male)/iBW_male
        //        let delta_iBW_female = 100 * (weight-iBW_female)/iBW_female
        //
        //        let VB_male = ThyrosimConstants.a * pow(100+delta_iBW_male, ThyrosimConstants.n - 1.0) * weight
        //        let VB_female = ThyrosimConstants.a * pow(100+delta_iBW_female, ThyrosimConstants.n - 1.0) * weight
        //
        //        let VP_male = VB_male*(1-0.45)
        //        let VP_female = VB_female*(1-0.4)
        //        let VP_pref = (VP_male + VP_female)/2
        //        //
        let VP_new = 3.2 * VP / ThyrosimConstants.VPref
        let VTSH_new = 5.2 + (VP_new - 3.2)
        
        let k05_new: Double
        if sex == "Male" {
            let BWref = 76.97  // reference male weight for h=1.75m ref
            k05_new = ThyrosimConstants.CM * ThyrosimConstants.base_k05 * pow(weight / BWref, 0.75)
        } else {
            let BWref = 57.49  // reference female weight for h=1.62 m ref
            k05_new = ThyrosimConstants.base_k05 * pow(weight / BWref, 0.75)
        }
        return (VP_new, VTSH_new, k05_new)
    }
}
        
        
        
