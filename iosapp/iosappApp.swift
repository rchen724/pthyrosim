import SwiftUI

@main
struct iosappApp: App {
    // Create an instance of our new data model.
    // This will be the single source of truth for dosing data.
    
    @StateObject private var simulationData = SimulationData()
    
    init() {
        let defaults = UserDefaults.standard

        // Only run this block once (change the version tag if you ever need to re-bootstrap)
        if defaults.bool(forKey: "didBootstrapDefaults_v1") == false {
            // Force the initial conditions toggle ON by default
            defaults.set(true, forKey: "isInitialConditionsOn")

            // Mark bootstrap complete
            defaults.set(true, forKey: "didBootstrapDefaults_v1")
            defaults.synchronize()
        }

        // Also register defaults for fresh installs (won't override existing keys)
        defaults.register(defaults: [
            "isInitialConditionsOn": true
        ])
    }


    var body: some Scene {
        WindowGroup {
            
            MainView()
                // Inject the data model into the environment for all child views to access.
                .environmentObject(simulationData)
        }
    }
}
