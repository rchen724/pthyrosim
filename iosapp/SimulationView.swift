import SwiftUI
import Charts

struct SimulationView: View {
    @EnvironmentObject var simulationData: SimulationData

    @AppStorage("t4Secretion") private var t4Secretion: String = "100"
    @AppStorage("t3Secretion") private var t3Secretion: String = "100"
    @AppStorage("height") private var heightString: String = "170"
    @AppStorage("weight") private var weightString: String = "70"
    @AppStorage("selectedHeightUnit") private var heightUnit: String = "cm"
    @AppStorage("selectedWeightUnit") private var weightUnit: String = "kg"
    @AppStorage("selectedGender") private var gender: String = "Female"
    @AppStorage("simulationDays") private var simulationDays: String = "5"
    @AppStorage("isInitialConditionsOn") private var isInitialConditionsOn: Bool = false

    @State private var simResult: ThyroidSimulationResult? = nil
    @State private var navigateToGraph: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea(edges: [.top, .horizontal])
                VStack(spacing: 30) {
                    Text("Run Euthyroid Simulation")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.top)

                    Image("thyrosim")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 350)
                        .padding(.horizontal)

                    Toggle(isOn: $isInitialConditionsOn) {
                        Text("Recalculate Initial Conditions")
                            .foregroundColor(.white)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .red))

                    Button(action: {
                       guard let t4Sec = Double(t4Secretion),
                             let t3Sec = Double(t3Secretion),
                             let h_val = Double(heightString),
                             let w_val = Double(weightString),
                             let d = Int(simulationDays), d > 0,
                             !gender.isEmpty else {
                           print("Invalid input values - check Step 1 settings.")
                           return
                       }
                        
                        // Convert height to meters
                        var heightInMeters: Double
                        switch heightUnit {
                        case "cm":
                            heightInMeters = h_val / 100.0
                        case "in":
                            heightInMeters = h_val * 0.0254
                        default: // "m"
                            heightInMeters = h_val
                        }

                        // Convert weight to kilograms
                        var weightInKg: Double
                        switch weightUnit {
                        case "lb":
                            weightInKg = w_val * 0.453592
                        default: // "kg"
                            weightInKg = w_val
                        }

                        // Initialize the simulator with medication doses set to 0 for the euthyroid graph
                        let simulator = ThyroidSimulator(
                                t4Secretion: t4Sec,
                                t3Secretion: t3Sec,
                                gender: gender,
                                height: heightInMeters,
                                weight: weightInKg,
                                days: d,
                                t3OralDoses: [],
                                t4OralDoses: [],
                                t3IVDoses: [],
                                t4IVDoses: [],
                                t3InfusionDoses: [], // Add this
                                t4InfusionDoses: []  // Add this
                            )
                            let result = simulator.runSimulation(recalculateIC: isInitialConditionsOn)
                        
                        if result.time.isEmpty {
                            print("Simulation produced no results. Check parameters.")
                            return
                        }
                        
                        simResult = result
                        simulationData.run1Result = result // Store result in shared data
                        navigateToGraph = true
                    }) {
                        Text("START SIMULATION")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.vertical, 15)
                            .padding(.horizontal, 40)
                            .background(Color.blue)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.purple, style: StrokeStyle(lineWidth: 1, dash: [5]))
                            )
                    }

                    Spacer().frame(height: 80)
                }
                .padding()
            }
            .navigationDestination(isPresented: $navigateToGraph) {
                if let result = simResult, let days = Int(simulationDays) {
                    SimulationGraphView(result: result, simulationDurationDays: days)
                }
            }
        }
    }
}
