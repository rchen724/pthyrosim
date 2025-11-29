//
//  DosingModels.swift
//  iosapp
//
//  Created by Shruthi Sathya on 6/17/25.
//

import Foundation

// MARK: - Dosing Data Models (Single Source of Truth)

// Defines the structure for an oral T3 dose.
struct T3OralDose: Identifiable, Equatable {
    let id = UUID()
    let T3OralDoseInput: Float
    let T3OralDoseStart: Float
    let T3OralDoseEnd: Float
    let T3OralDoseInterval: Float
    let T3SingleDose: Bool
}

// Defines the structure for an IV T3 dose.
struct T3IVDose: Identifiable, Equatable {
    let id = UUID()
    let T3IVDoseInput: Float
    let T3IVDoseStart: Float
}

// Defines the structure for a T3 infusion.
struct T3InfusionDose: Identifiable, Equatable {
    let id = UUID()
    let T3InfusionDoseInput: Float
    let T3InfusionDoseStart: Float
    let T3InfusionDoseEnd: Float
}

// Defines the structure for an oral T4 dose.
struct T4OralDose: Identifiable, Equatable {
    let id = UUID()
    let T4OralDoseInput: Float
    let T4OralDoseStart: Float
    let T4OralDoseEnd: Float
    let T4OralDoseInterval: Float
    let T4SingleDose: Bool
}

// Defines the structure for an IV T4 dose.
struct T4IVDose: Identifiable, Equatable {
    let id = UUID()
    let T4IVDoseInput: Float
    let T4IVDoseStart: Float
}

// Defines the structure for a T4 infusion.
struct T4InfusionDose: Identifiable, Equatable {
    let id = UUID()
    let T4InfusionDoseInput: Float
    let T4InfusionDoseStart: Float
    let T4InfusionDoseEnd: Float
}


// Defines the possible popups for adding doses.
enum ActivePopup: Identifiable, Equatable {
    case T3OralInputs, T3IVInputs, T3InfusionInputs
    case T4OralInputs, T4IVInputs, T4InfusionInputs
    
    var id: Int { hashValue }
}
