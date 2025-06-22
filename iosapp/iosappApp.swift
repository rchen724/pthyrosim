import SwiftUI

@main
struct iosappApp: App {
    // Create an instance of our new data model.
    // This will be the single source of truth for dosing data.
    @StateObject private var simulationData = SimulationData()

    var body: some Scene {
        WindowGroup {
            MainView()
                // Inject the data model into the environment for all child views to access.
                .environmentObject(simulationData)
        }
    }
}
