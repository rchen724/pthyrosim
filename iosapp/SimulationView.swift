import SwiftUI
import Charts

struct SimulationView: View {

    @AppStorage("t4Secretion") private var t4Secretion: String = "100"
    @AppStorage("t3Secretion") private var t3Secretion: String = "100"
    @AppStorage("height") private var height: String = "1.65"
    @AppStorage("weight") private var weight: String = "60"
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
                    Text("Run Simulation")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.top)

                    Image("thyrosim")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 350)
                        .padding(.horizontal)

                    // Toggle for Initial Conditions
                    Toggle(isOn: $isInitialConditionsOn) {
                        Text("Recalculate Initial Conditions")
                            .foregroundColor(.white)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .red))

                    // Simulation Button
                    Button(action: {
                        guard let t4Sec = Double(t4Secretion),
                              let t3Sec = Double(t3Secretion),
                              let h = Double(height),
                              let w = Double(weight),
                              let d = Int(simulationDays),
                              !gender.isEmpty else {
                            print("Invalid input values")
                            return
                        }
                        let simulator = ThyroidSimulator(
                            t4Secretion: t4Sec,
                            t3Secretion: t3Sec,
                            gender: gender,
                            height: h,
                            weight: w,
                            days: d
                        )
                        let result = simulator.runSimulation(
                            recalculateIC: isInitialConditionsOn,
                            logTSHOutput: false
                        )
                        simResult = result
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
                if let result = simResult {
                    SimulationGraphView(result: result, xZoom: 1.0, yZoom: 1.0)
                }
            }
        }
    }
}
