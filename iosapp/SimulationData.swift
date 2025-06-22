//
//  SimulationData.swift
//  iosapp
//
//  Created by Shruthi Sathya on 6/17/25.
//
import Foundation
import Combine

// This class acts as a single source of truth for all dosing regimens.
// By making it an ObservableObject, we can share it across different views.
class SimulationData: ObservableObject {
    @Published var t3oralinputs: [T3OralDose] = []
    @Published var t3ivinputs: [T3IVDose] = []
    @Published var t3infusioninputs: [T3InfusionDose] = []
    
    @Published var t4oralinputs: [T4OralDose] = []
    @Published var t4ivinputs: [T4IVDose] = []
    @Published var t4infusioninputs: [T4InfusionDose] = []
}
