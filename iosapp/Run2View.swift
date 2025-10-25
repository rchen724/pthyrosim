import SwiftUI
struct Run2View: View {
    @EnvironmentObject var simulationData: SimulationData
    
    @State private var run2Result: ThyroidSimulationResult?
    @State private var isSimulating: Bool = false
    @State private var navigateToGraph: Bool = false
    @State private var navigateToDosingInput = false   // <-- new
    
    // Using AppStorage properties from SimulationView
    @AppStorage("t4Secretion") private var t4Secretion: String = "100"
    @AppStorage("t3Secretion") private var t3Secretion: String = "100"
    @AppStorage("t4Absorption") private var t4Absorption: String = "88"
    @AppStorage("t3Absorption") private var t3Absorption: String = "88"
    @AppStorage("height") private var heightString: String = "170"
    @AppStorage("weight") private var weightString: String = "70"
    @AppStorage("selectedHeightUnit") private var selectedHeightUnit: String = "cm"
    @AppStorage("selectedWeightUnit") private var selectedWeightUnit: String = "kg"
    @AppStorage("selectedGender") private var selectedGender: String = "Female"
    @AppStorage("simulationDays") private var simulationDays: String = "5"
    @AppStorage("isInitialConditionsOn") private var isInitialConditionsOn: Bool = true
    
    private var heightInMeters: Double? {
          // Use the correct variable name: heightString
          guard let heightValue = Double(heightString) else { return nil }
          
          // Compare against the correct string-based unit
          if selectedHeightUnit == "cm" {
              return heightValue / 100.0
          } else if selectedHeightUnit  == "in" {
              return heightValue * 0.0254
          } else { // Assumes meters by default
              return heightValue
          }
      }
      private var weightInKg: Double? {
          // Use the correct variable name: weightString
          guard let weightValue = Double(weightString) else { return nil }
          
          // Compare against the correct string-based unit
          if selectedWeightUnit == "lb" {
              return weightValue * 0.453592
          } else { // Assumes kg by default
              return weightValue
          }
      }
    
    
    
    var body: some View {
        NavigationStack {
            if simulationData.run1Result != nil {
                ZStack {
                    Form {
                        Section(header: Text("T4 Doses for Dosing Simulation (from Dosing tab)")) {
                            DoseDisplayView(doses: simulationData.run2T4oralinputs) { Text(format(dose: $0)) }
                            DoseDisplayView(doses: simulationData.run2T4ivinputs) { Text(format(dose: $0)) }
                            DoseDisplayView(doses: simulationData.run2T4infusioninputs) { Text(format(dose: $0)) }
                        }
                        
                        Section(header: Text("T3 Doses for Dosing Simulation (from Dosing tab)")) {
                            DoseDisplayView(doses: simulationData.run2T3oralinputs) { Text(format(dose: $0)) }
                            DoseDisplayView(doses: simulationData.run2T3ivinputs) { Text(format(dose: $0)) }
                            DoseDisplayView(doses: simulationData.run2T3infusioninputs) { Text(format(dose: $0)) }
                        }
                        Button(action: { runSimulationAndNavigate() }) {
                            HStack {
                                Spacer()
                                if isSimulating {
                                    ProgressView()
                                } else {
                                    Text("Simulate Dosing")
                                        .fontWeight(.bold)
                                }
                                Spacer()
                            }
                        }
                        .disabled(isSimulating)
                        .padding()
                    }
                    .navigationTitle("Configure Dosing Simulation")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationDestination(isPresented: $navigateToDosingInput) {
                        Run2DosingInputView()
                    }
                    .navigationDestination(isPresented: $navigateToGraph) {
                        if let run2Result = run2Result, let days = Int(simulationDays) {
                            Run2GraphView(run2Result: run2Result, simulationDurationDays: days)
                        }
                    }
                }
                .onAppear {
                    // Reset previous run 2 results when view appears
                    if self.run2Result != nil {
                        self.run2Result = nil
                    }
                }
            } else {
                VStack {
                    Text("Please run the 'Simulate Euthyroid' simulation first.")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .navigationTitle("Simulate Dosing")
            }
        }
    }
    private func runSimulationAndNavigate() {
        guard let t4Sec = Double(t4Secretion), let t3Sec = Double(t3Secretion),
              let t4Abs = Double(t4Absorption), let t3Abs = Double(t3Absorption),
              let hVal = Double(heightString), let wVal = Double(weightString),
              let days = Int(simulationDays) else {
            print("Error: Invalid Run 1 parameters from AppStorage.")
            return
        }

        guard !isSimulating else { return }
        isSimulating = true

        Task {
            let heightInMeters = (selectedHeightUnit == "cm") ? hVal / 100.0 : ((selectedHeightUnit == "in") ? hVal * 0.0254 : hVal)
            let weightInKg = (selectedWeightUnit == "lb") ? wVal * 0.453592 : wVal

            let simulator = ThyroidSimulator(
                t4Secretion: t4Sec,
                t3Secretion: t3Sec,
                t4Absorption: t4Abs,
                t3Absorption: t3Abs,
                gender: selectedGender,
                height: heightInMeters,
                weight: weightInKg,
                days: days,
                t3OralDoses: simulationData.run2T3oralinputs,
                t4OralDoses: simulationData.run2T4oralinputs,
                t3IVDoses: simulationData.run2T3ivinputs,
                t4IVDoses: simulationData.run2T4ivinputs,
                t3InfusionDoses: simulationData.run2T3infusioninputs,
                t4InfusionDoses: simulationData.run2T4infusioninputs,
                isInitialConditionsOn: isInitialConditionsOn
            )
            let result = simulator.runSimulation()

            await MainActor.run {
                self.run2Result = result
                self.simulationData.previousRun2Results.append(result)
                self.simulationData.run2Result = result   // <-- ADD THIS LINE

                self.isSimulating = false
                self.navigateToGraph = true
            }
        }
    }
    
    // Formatting functions remain the same
    private func format(dose: T4OralDose) -> String {
        let formattedDose = String(format: "%.1f", dose.T4OralDoseInput)
        let formattedStart = String(format: "%.1f", dose.T4OralDoseStart)
        let formattedInterval = String(format: "%.1f", dose.T4OralDoseInterval)
        return "Oral T4: \(formattedDose)µg" + (dose.T4SingleDose ? " at day \(formattedStart)" : " every \(formattedInterval) days")
    }
    private func format(dose: T4IVDose) -> String {
        let formattedDose = String(format: "%.1f", dose.T4IVDoseInput)
        let formattedStart = String(format: "%.1f", dose.T4IVDoseStart)
        return "IV T4: \(formattedDose)µg at day \(formattedStart)"
    }
    private func format(dose: T4InfusionDose) -> String {
        let formattedDose = String(format: "%.1f", dose.T4InfusionDoseInput)
        let formattedStart = String(format: "%.1f", dose.T4InfusionDoseStart)
        let formattedEnd = String(format: "%.1f", dose.T4InfusionDoseEnd)
        return "Infusion T4: \(formattedDose)µg from day \(formattedStart) to \(formattedEnd)"
    }
    private func format(dose: T3OralDose) -> String {
        let formattedDose = String(format: "%.1f", dose.T3OralDoseInput)
        let formattedStart = String(format: "%.1f", dose.T3OralDoseStart)
        let formattedInterval = String(format: "%.1f", dose.T3OralDoseInterval)
        return "Oral T3: \(formattedDose)µg" + (dose.T3SingleDose ? " at day \(formattedStart)" : " every \(formattedInterval) days")
    }
    private func format(dose: T3IVDose) -> String {
        let formattedDose = String(format: "%.1f", dose.T3IVDoseInput)
        let formattedStart = String(format: "%.1f", dose.T3IVDoseStart)
        return "IV T3: \(formattedDose)µg at day \(formattedStart)"
    }
    private func format(dose: T3InfusionDose) -> String {
        let formattedDose = String(format: "%.1f", dose.T3InfusionDoseInput)
        let formattedStart = String(format: "%.1f", dose.T3InfusionDoseStart)
        let formattedEnd = String(format: "%.1f", dose.T3InfusionDoseEnd)
        return "Infusion T3: \(formattedDose)µg from day \(formattedStart) to \(formattedEnd)"
    }
}
// --- Helper view for simply displaying lists of doses ---
fileprivate struct DoseDisplayView<T: Identifiable, Content: View>: View {
    let doses: [T]
    let content: (T) -> Content
    var body: some View {
        if doses.isEmpty {
            Text("No doses added.").foregroundColor(.gray)
        } else {
            ForEach(doses) { dose in
                content(dose)
            }
        }
    }
}

