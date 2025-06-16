import SwiftUI
import Charts

struct SimulationView: View {

    @AppStorage("t4Secretion") private var t4Secretion: String = "100"
    @AppStorage("t3Secretion") private var t3Secretion: String = "100"
    @AppStorage("height") private var height: String = "1.65" // Raw string value
    @AppStorage("weight") private var weight: String = "60"   // Raw string value
    @AppStorage("selectedGender") private var gender: String = "Female" // Default from your Step1View was ""
                                                                    // but PatientParams needs Male/Female.
                                                                    // SimulationView used "Female" as its own default.
    @AppStorage("simulationDays") private var simulationDays: String = "5" // User input for days
    @AppStorage("isInitialConditionsOn") private var isInitialConditionsOn: Bool = false

    @State private var simResult: ThyroidSimulationResult? = nil
    @State private var navigateToGraph: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea(edges: [.top, .horizontal])
                VStack(spacing: 30) {
                    Text("Run Simulation")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.top)

                    Image("thyrosim") // Ensure this image is in your Assets.xcassets
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 350)
                        .padding(.horizontal)

                    Toggle(isOn: $isInitialConditionsOn) {
                        Text("Recalculate Initial Conditions")
                            .foregroundColor(.white)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .red)) // Or your original tint

                    Button(action: {
                        // Basic validation for conversion to Double/Int
                        guard let t4Sec = Double(t4Secretion),
                              let t3Sec = Double(t3Secretion),
                              let h = Double(height), // Uses raw height string
                              let w = Double(weight), // Uses raw weight string
                              let d = Int(simulationDays), d > 0, // Ensure days is positive
                              !gender.isEmpty else { // Ensure gender is not empty
                            print("Invalid input values - check Step 1 settings.")
                            // You might want to show an alert to the user here
                            return
                        }
                        
                        // NO UNIT CONVERSION IS PERFORMED HERE IN THIS REVERTED VERSION.
                        // 'h' and 'w' are the direct numerical inputs.
                        // For ThyroidPatientParams to work correctly, these would need to be
                        // implicitly in meters and kilograms respectively when the user types them.
                        
                        let simulator = ThyroidSimulator(
                            t4Secretion: t4Sec,
                            t3Secretion: t3Sec,
                            gender: gender, // Passed directly
                            height: h,      // Passed directly
                            weight: w,      // Passed directly
                            days: d
                            // Assuming your ThyroidSimulator init does not require dose arrays
                            // or has default empty ones. If it does, you'd pass:
                            // t4OralInputs: [], t3OralInputs: []
                        )
                        let result = simulator.runSimulation(
                            recalculateIC: isInitialConditionsOn,
                            logTSHOutput: false
                        )
                        
                        if result.time.isEmpty {
                            print("Simulation produced no results. Check parameters.")
                            // Optionally show an error to the user
                            return
                        }
                        
                        simResult = result
                        navigateToGraph = true
                    }) {
                        Text("START SIMULATION")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.vertical, 15)
                            .padding(.horizontal, 40)
                            .background(Color.blue) // Your original styling
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.purple, style: StrokeStyle(lineWidth: 1, dash: [5])) // Your original
                            )
                    }

                    Spacer().frame(height: 80) // Your original spacer
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
