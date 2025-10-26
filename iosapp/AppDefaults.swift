//
//  AppDefaults.swift
//  iosapp
//
//  Created by Rita Chen on 10/25/25.
//


import SwiftUI

struct AppDefaults {
    /// Call on cold launch to reset all persisted values to defaults.
    static func resetAll(simData: SimulationData) {
        // ---- AppStorage-backed defaults ----
        let ud = UserDefaults.standard
        ud.set("100", forKey: "t4Secretion")
        ud.set("88",  forKey: "t4Absorption")
        ud.set("100", forKey: "t3Secretion")
        ud.set("88",  forKey: "t3Absorption")

        ud.set("170", forKey: "height")              // cm
        ud.set("70",  forKey: "weight")              // kg
        ud.set("FEMALE", forKey: "selectedGender")
        ud.set("cm",  forKey: "selectedHeightUnit")
        ud.set("kg",  forKey: "selectedWeightUnit")
        ud.set("5",   forKey: "simulationDays")

        // Toggle default ON
        ud.set(true,  forKey: "isInitialConditionsOn")

        // Tab selections
        ud.set(0,     forKey: "selectedMainTab")     // Intro
        ud.set(0,     forKey: "moreSelectedSubTab")  // first sub-tab in More

        // If you use any other AppStorage keys, set their defaults here too.

        // ---- Clear in-memory model state ----
        simData.run1Result = nil
        simData.run2Result = nil
        simData.previousRun2Results.removeAll()
        simData.previousRun3Results.removeAll()

        // Clear ALL Run 2 dose inputs
        simData.run2T3oralinputs.removeAll()
        simData.run2T3ivinputs.removeAll()
        simData.run2T3infusioninputs.removeAll()
        simData.run2T4oralinputs.removeAll()
        simData.run2T4ivinputs.removeAll()
        simData.run2T4infusioninputs.removeAll()

        // Clear ALL Run 3 dose inputs
        simData.run3T3oralinputs.removeAll()
        simData.run3T3ivinputs.removeAll()
        simData.run3T3infusioninputs.removeAll()
        simData.run3T4oralinputs.removeAll()
        simData.run3T4ivinputs.removeAll()
        simData.run3T4infusioninputs.removeAll()
    }
}
