import SwiftUI

enum Run3StartScreen { case dosing, simulate }

struct Run3View: View {
    @EnvironmentObject var simulationData: SimulationData
    @State private var run3Result: ThyroidSimulationResult? = nil
    @State private var isSimulating = false
    @State private var navigateToGraph = false
    @State private var navigateToDosingInput = false   // <-- new
    
    // Scroll tracking state for custom scrollbar
    @State private var scrollOffset: CGFloat = 0
    @State private var contentHeight: CGFloat = 1
    @State private var scrollViewHeight: CGFloat = 1

    // AppStorage for Run 1 parameters (matching Step1View keys)
    @AppStorage("t4Secretion") private var t4Secretion = "100"
    @AppStorage("t3Secretion") private var t3Secretion = "100"
    @AppStorage("t4Absorption") private var t4Absorption = "88"
    @AppStorage("t3Absorption") private var t3Absorption = "88"
    @AppStorage("height") private var height = "170"
    @AppStorage("weight") private var weight = "70"
    @AppStorage("selectedHeightUnit") private var selectedHeightUnit = "cm"
    @AppStorage("selectedWeightUnit") private var selectedWeightUnit = "kg"
    @AppStorage("selectedGender") private var selectedGender = "FEMALE"
    @AppStorage("simulationDays") private var simulationDays = "5"
    @AppStorage("isInitialConditionsOn") private var isInitialConditionsOn = true

    // Where should Run3 open?
    private let startAt: Run3StartScreen
    init(startAt: Run3StartScreen = .simulate) {
        self.startAt = startAt
    }

    private var heightInMeters: Double? {
        guard let heightValue = Double(height) else { return nil }
        if selectedHeightUnit == "cm" {
            return heightValue / 100.0
        } else if selectedHeightUnit == "in" {
            return heightValue * 0.0254
        } else {
            return heightValue
        }
    }

    private var weightInKg: Double? {
        guard let weightValue = Double(weight) else { return nil }
        if selectedWeightUnit == "lb" {
            return weightValue * 0.453592
        } else {
            return weightValue
        }
    }

    var body: some View {
        NavigationStack {
            if simulationData.run2Result != nil {
                ZStack {
                    Form {
                        Section(header: Text("T4 Doses for Run 3 Dosing Simulation")) {
                            DoseDisplayView(doses: simulationData.run3T4oralinputs) { Text(format(dose: $0)) }
                            DoseDisplayView(doses: simulationData.run3T4ivinputs) { Text(format(dose: $0)) }
                            DoseDisplayView(doses: simulationData.run3T4infusioninputs) { Text(format(dose: $0)) }
                        }

                        Section(header: Text("T3 Doses for Run 3 Dosing Simulation")) {
                            DoseDisplayView(doses: simulationData.run3T3oralinputs) { Text(format(dose: $0)) }
                            DoseDisplayView(doses: simulationData.run3T3ivinputs) { Text(format(dose: $0)) }
                            DoseDisplayView(doses: simulationData.run3T3infusioninputs) { Text(format(dose: $0)) }
                        }

                        Section(header: Text("Configure Doses")) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Go to 'More' tab to add/edit doses")
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                        }

                        Button(action: { runSimulationAndNavigate() }) {
                            HStack {
                                Spacer()
                                if isSimulating {
                                    ProgressView()
                                } else {
                                    Text("Simulate Run 3")
                                        .fontWeight(.bold)
                                }
                                Spacer()
                            }
                        }
                        .disabled(isSimulating)
                        .padding()
                    }
                    .navigationTitle("Configure Run 3 Dosing Simulation")
                    .navigationBarTitleDisplayMode(.inline)
                    // Auto-push to dose-adding screen when asked to start at .dosing
                    .navigationDestination(isPresented: $navigateToDosingInput) {
                        Run3DosingInputView()
                    }
                    // Navigate to graphs after simulation
                    .navigationDestination(isPresented: $navigateToGraph) {
                        if let run3Result = run3Result, let days = Int(simulationDays) {
                            Run3GraphView(run3Result: run3Result, simulationDurationDays: days)
                        }
                    }
                }
                .onAppear {
                    // Clear previous result if any
                    if self.run3Result != nil {
                        self.run3Result = nil
                    }
                    // If caller wants to land on the dose-adding page, push it
                    if startAt == .dosing && !navigateToDosingInput {
                        navigateToDosingInput = true
                    }
                }
            } else {
                VStack {
                    Text("Please run the 'Simulate Dosing' (Run 2) simulation first.")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .navigationTitle("Simulate Run 3")
            }
        }
    }

    private func runSimulationAndNavigate() {
        guard let t4Sec = Double(t4Secretion), let t3Sec = Double(t3Secretion),
              let t4Abs = Double(t4Absorption), let t3Abs = Double(t3Absorption),
              let hVal = Double(height), let wVal = Double(weight),
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
                t3OralDoses: simulationData.run3T3oralinputs,
                t4OralDoses: simulationData.run3T4oralinputs,
                t3IVDoses: simulationData.run3T3ivinputs,
                t4IVDoses: simulationData.run3T4ivinputs,
                t3InfusionDoses: simulationData.run3T3infusioninputs,
                t4InfusionDoses: simulationData.run3T4infusioninputs,
                isInitialConditionsOn: isInitialConditionsOn
            )
            let result = simulator.runSimulation()

            await MainActor.run {
                self.run3Result = result
                self.simulationData.previousRun3Results.append(result)
                self.isSimulating = false
                self.navigateToGraph = true
            }
        }
    }

    // Format functions for dose display
    private func format(dose: T4OralDose) -> String {
        let formattedDose = String(format: "%.1f", dose.T4OralDoseInput)
        let formattedStart = String(format: "%.1f", dose.T4OralDoseStart)
        let formattedInterval = String(format: "%.1f", dose.T4OralDoseInterval)
        return "Oral T4: \(formattedDose)µg" + (dose.T4SingleDose ? " at day \(formattedStart)" : " every \(formattedInterval) days")
    }

    private func format(dose: T3OralDose) -> String {
        let formattedDose = String(format: "%.1f", dose.T3OralDoseInput)
        let formattedStart = String(format: "%.1f", dose.T3OralDoseStart)
        let formattedInterval = String(format: "%.1f", dose.T3OralDoseInterval)
        return "Oral T3: \(formattedDose)µg" + (dose.T3SingleDose ? " at day \(formattedStart)" : " every \(formattedInterval) days")
    }

    private func format(dose: T4IVDose) -> String {
        let formattedDose = String(format: "%.1f", dose.T4IVDoseInput)
        let formattedStart = String(format: "%.1f", dose.T4IVDoseStart)
        return "IV T4: \(formattedDose)µg at day \(formattedStart)"
    }

    private func format(dose: T3IVDose) -> String {
        let formattedDose = String(format: "%.1f", dose.T3IVDoseInput)
        let formattedStart = String(format: "%.1f", dose.T3IVDoseStart)
        return "IV T3: \(formattedDose)µg at day \(formattedStart)"
    }

    private func format(dose: T4InfusionDose) -> String {
        let formattedDose = String(format: "%.1f", dose.T4InfusionDoseInput)
        let formattedStart = String(format: "%.1f", dose.T4InfusionDoseStart)
        let formattedEnd = String(format: "%.1f", dose.T4InfusionDoseEnd)
        return "Infusion T4: \(formattedDose)µg from day \(formattedStart) to \(formattedEnd)"
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
