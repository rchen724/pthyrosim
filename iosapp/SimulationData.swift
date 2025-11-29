import Foundation
import Combine
import SwiftUI

// This class acts as a single source of truth for all simulation data.
// By making it an ObservableObject, we can share it across different views.
class SimulationData: ObservableObject {
    @Published var t3oralinputs: [T3OralDose] = []
    @Published var t3ivinputs: [T3IVDose] = []
    @Published var t3infusioninputs: [T3InfusionDose] = []
    
    @Published var t4oralinputs: [T4OralDose] = []
    @Published var t4ivinputs: [T4IVDose] = []
    @Published var t4infusioninputs: [T4InfusionDose] = []
    
    // Run2-specific dose arrays
    @Published var run2T3oralinputs: [T3OralDose] = []
    @Published var run2T3ivinputs: [T3IVDose] = []
    @Published var run2T3infusioninputs: [T3InfusionDose] = []
    
    @Published var run2T4oralinputs: [T4OralDose] = []
    @Published var run2T4ivinputs: [T4IVDose] = []
    @Published var run2T4infusioninputs: [T4InfusionDose] = []
    
    // Run3-specific dose arrays
    @Published var run3T3oralinputs: [T3OralDose] = []
    @Published var run3T3ivinputs: [T3IVDose] = []
    @Published var run3T3infusioninputs: [T3InfusionDose] = []
    
    @Published var run3T4oralinputs: [T4OralDose] = []
    @Published var run3T4ivinputs: [T4IVDose] = []
    @Published var run3T4infusioninputs: [T4InfusionDose] = []
    
    // Run4-specific dose arrays
    @Published var run4T3oralinputs: [T3OralDose] = []
    @Published var run4T3ivinputs: [T3IVDose] = []
    @Published var run4T3infusioninputs: [T3InfusionDose] = []
    
    @Published var run4T4oralinputs: [T4OralDose] = []
    @Published var run4T4ivinputs: [T4IVDose] = []
    @Published var run4T4infusioninputs: [T4InfusionDose] = []
    
    // To store the result of the first simulation (euthyroid)
    @Published var run1Result: ThyroidSimulationResult? = nil
    
    // To store previous Run2 results for superimposition
    @Published var previousRun2Results: [ThyroidSimulationResult] = []
    
    // To store the result of Run2 for Run3 initial state
    @Published var run2Result: ThyroidSimulationResult? = nil
    
    // To store previous Run3 results for superimposition
    @Published var previousRun3Results: [ThyroidSimulationResult] = []

    // To store the result of Run3 for Run4 initial state
    @Published var run3Result: ThyroidSimulationResult? = nil
    
    // To store previous Run4 results for superimposition
    @Published var previousRun4Results: [ThyroidSimulationResult] = []
    
    @Published var run4Result: ThyroidSimulationResult? = nil
    
    // Additional properties that might be referenced elsewhere
    @Published var currentRun2Result: ThyroidSimulationResult? = nil
    @Published var currentRun3Result: ThyroidSimulationResult? = nil
    @Published var currentRun4Result: ThyroidSimulationResult? = nil
}
