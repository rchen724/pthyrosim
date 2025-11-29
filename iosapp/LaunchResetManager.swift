//
//  LaunchResetManager.swift
//  iosapp
//
//  Created by Rita Chen on 10/29/25.
//


import Foundation

enum LaunchResetManager {
    private static var didResetThisLaunch = false

    /// Call this once at app launch to force defaults and clear R2/R3 state.
    static func resetOnColdLaunch(simulationData: SimulationData) {
        guard !didResetThisLaunch else { return }
        didResetThisLaunch = true

        // ---- Reset input defaults (these are the same keys you use in @AppStorage) ----
        let defaults: [String: Any] = [
            "t4Secretion": "100",
            "t3Secretion": "100",
            "t4Absorption": "88",
            "t3Absorption": "88",
            "height": "170",
            "weight": "70",
            "selectedHeightUnit": "cm",
            "selectedWeightUnit": "kg",
            "selectedGender": "FEMALE",
            "simulationDays": "5",
            // Toggle ON by default:
            "isInitialConditionsOn": true,
            // Keep Run 1 labeling as "Run 1" going forward if you use this flag
            "hasRunRun1Once": true
        ]

        let ud = UserDefaults.standard
        for (k, v) in defaults {
            ud.set(v, forKey: k)
        }
        ud.synchronize()

        // ---- Clear Run 2 & Run 3 state; keep Run 1 state ----
        simulationData.t4oralinputs.removeAll()
        simulationData.t3oralinputs.removeAll()
        simulationData.t4ivinputs.removeAll()
        simulationData.t3ivinputs.removeAll()
        simulationData.t4infusioninputs.removeAll()
        simulationData.t3infusioninputs.removeAll()

        // Run 2 specific
        simulationData.run2T4oralinputs.removeAll()
        simulationData.run2T3oralinputs.removeAll()
        simulationData.run2T4ivinputs.removeAll()
        simulationData.run2T3ivinputs.removeAll()
        simulationData.run2T4infusioninputs.removeAll()
        simulationData.run2T3infusioninputs.removeAll()
        simulationData.previousRun2Results.removeAll()
        simulationData.run2Result = nil

        // Run 3 specific
        simulationData.run3T4oralinputs.removeAll()
        simulationData.run3T3oralinputs.removeAll()
        simulationData.run3T4ivinputs.removeAll()
        simulationData.run3T3ivinputs.removeAll()
        simulationData.run3T4infusioninputs.removeAll()
        simulationData.run3T3infusioninputs.removeAll()
        simulationData.previousRun3Results.removeAll()
        // If you keep a current run3Result property, nil it here:
        // simulationData.run3Result = nil

        // (Intentionally do NOT touch simulationData.run1Result)
    }
    
    static func resetAll(simulationData: SimulationData) {
        // ---- Reset input defaults (these are the same keys you use in @AppStorage) ----
        let defaults: [String: Any] = [
            "t4Secretion": "100",
            "t3Secretion": "100",
            "t4Absorption": "88",
            "t3Absorption": "88",
            "height": "170",
            "weight": "70",
            "selectedHeightUnit": "cm",
            "selectedWeightUnit": "kg",
            "selectedGender": "FEMALE",
            "simulationDays": "5",
            // Toggle ON by default:
            "isInitialConditionsOn": true,
            // Keep Run 1 labeling as "Run 1" going forward if you use this flag
            "hasRunRun1Once": true
        ]

        let ud = UserDefaults.standard
        for (k, v) in defaults {
            ud.set(v, forKey: k)
        }
        ud.synchronize()

        // ---- Clear Run 2 & Run 3 state; keep Run 1 state ----
        simulationData.run1Result = nil
        simulationData.t4oralinputs.removeAll()
        simulationData.t3oralinputs.removeAll()
        simulationData.t4ivinputs.removeAll()
        simulationData.t3ivinputs.removeAll()
        simulationData.t4infusioninputs.removeAll()
        simulationData.t3infusioninputs.removeAll()

        // Run 2 specific
        simulationData.run2T4oralinputs.removeAll()
        simulationData.run2T3oralinputs.removeAll()
        simulationData.run2T4ivinputs.removeAll()
        simulationData.run2T3ivinputs.removeAll()
        simulationData.run2T4infusioninputs.removeAll()
        simulationData.run2T3infusioninputs.removeAll()
        simulationData.previousRun2Results.removeAll()
        simulationData.run2Result = nil

        // Run 3 specific
        simulationData.run3T4oralinputs.removeAll()
        simulationData.run3T3oralinputs.removeAll()
        simulationData.run3T4ivinputs.removeAll()
        simulationData.run3T3ivinputs.removeAll()
        simulationData.run3T4infusioninputs.removeAll()
        simulationData.run3T3infusioninputs.removeAll()
        simulationData.previousRun3Results.removeAll()
        simulationData.run3Result = nil // Clear current run3 result as well

        // Run 4 specific (NEW)
        simulationData.run4T4oralinputs.removeAll()
        simulationData.run4T3oralinputs.removeAll()
        simulationData.run4T4ivinputs.removeAll()
        simulationData.run4T3ivinputs.removeAll()
        simulationData.run4T4infusioninputs.removeAll()
        simulationData.run4T3infusioninputs.removeAll()
        simulationData.previousRun4Results.removeAll()
        simulationData.run4Result = nil // Clear current run4 result
    }
}
