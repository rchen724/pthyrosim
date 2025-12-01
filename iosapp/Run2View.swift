import SwiftUI

struct Run2View: View {
    @EnvironmentObject var simulationData: SimulationData
    @State private var activePopup: ActivePopup? = nil
    
    // Scroll tracking state for custom scrollbar (kept for future use)
    @State private var scrollOffset: CGFloat = 0
    @State private var contentHeight: CGFloat = 1
    @State private var scrollViewHeight: CGFloat = 1
    
    @State private var run2Result: ThyroidSimulationResult?
    @State private var isSimulating: Bool = false
    @State private var navigateToGraph: Bool = false
    
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
    // NOTE: We'll ignore this for Run 2 and always continue from Run 1:
    @AppStorage("isInitialConditionsOn") private var isInitialConditionsOn: Bool = true
    
    // Enumerated input arrays for Run2
    var enumeratedRun2T3Oral: [(Int, T3OralDose)]         { Array(simulationData.run2T3oralinputs.enumerated()) }
    var enumeratedRun2T3IV: [(Int, T3IVDose)]             { Array(simulationData.run2T3ivinputs.enumerated()) }
    var enumeratedRun2T3Infusion: [(Int, T3InfusionDose)] { Array(simulationData.run2T3infusioninputs.enumerated()) }
    var enumeratedRun2T4Oral: [(Int, T4OralDose)]         { Array(simulationData.run2T4oralinputs.enumerated()) }
    var enumeratedRun2T4IV: [(Int, T4IVDose)]             { Array(simulationData.run2T4ivinputs.enumerated()) }
    var enumeratedRun2T4Infusion: [(Int, T4InfusionDose)] { Array(simulationData.run2T4infusioninputs.enumerated()) }

    var body: some View {
        NavigationStack {
            if simulationData.run1Result != nil {
                ZStack(alignment: .topTrailing) {
                    ScrollViewWithScrollbar(showsIndicators: false) {
                        VStack(alignment: .center, spacing: 24) {
                            
                            Text("Run 2 Dosing Input")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                            Text("HOW TO DO IT:")
                                .foregroundColor(.white)
                                .font(.headline)

                            VStack(alignment: .leading, spacing: 10) {
                                    Text("• T3 and/or T4 input dosing can be chosen as oral; OR intravenous (IV) bolus; OR infusion doses.")

                                    Text("• Click the icons to add inputs")

                                    Text("• Click 'SIMULATE DOSING' to simulate and view results")

                            }
                            .foregroundColor(.white)
                            .font(.caption)
                            
                            Button(action: { runSimulationAndNavigate() }) {
                                HStack {
                                    if isSimulating {
                                        ProgressView().tint(.white)
                                            .padding(.trailing, 5)
                                    }
                                    Text(isSimulating ? "SIMULATING..." : "SIMULATE DOSING")
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                .padding(.vertical, 15)
                                .padding(.horizontal, 40)
                                .background(Color.blue)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.purple, style: StrokeStyle(lineWidth: 1, dash: [5]))
                                )
                            }
                            .disabled(isSimulating)

                            HStack(alignment: .top, spacing: 40) {
                                VStack(alignment: .center, spacing: 16) {
                                    Text("T3 Input:")
                                        .font(.title3.bold())
                                        .foregroundColor(.white)
                                    VStack(spacing: 12) {
                                        Button { activePopup = .T3OralInputs } label: { VStack { Image("pill1"); Text("Oral Dose").font(.headline).foregroundColor(.white) } }
                                        Button { activePopup = .T3IVInputs } label: { VStack { Image("syringe1"); Text("IV Bolus Dose").font(.headline).foregroundColor(.white) } }
                                        Button { activePopup = .T3InfusionInputs } label: { VStack { Image("infusion1"); Text("Infusion Dose").font(.headline).foregroundColor(.white) } }
                                    }
                                }

                                VStack(alignment: .center, spacing: 16) {
                                    Text("T4 Input:")
                                        .font(.title3.bold())
                                        .foregroundColor(.white)
                                    VStack(spacing: 12) {
                                        Button { activePopup = .T4OralInputs } label: { VStack { Image("pill2"); Text("Oral Dose").font(.headline).foregroundColor(.white) } }
                                        Button { activePopup = .T4IVInputs } label: { VStack { Image("syringe2"); Text("IV Bolus Dose").font(.headline).foregroundColor(.white) } }
                                        Button { activePopup = .T4InfusionInputs } label: { VStack { Image("infusion2"); Text("Infusion Dose").font(.headline).foregroundColor(.white) } }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()

                            if !simulationData.run2T3oralinputs.isEmpty { DoseDisplaySection(doses: enumeratedRun2T3Oral, title: "T3-ORAL DOSE (Run 2)", imageName: "pill1", onDelete: { simulationData.run2T3oralinputs.remove(at: $0) }) { i, d, del in DoseDetailsView(index: i, details: [("Dose (µg)", d.T3OralDoseInput), ("Start Day", d.T3OralDoseStart)], conditionalDetails: !d.T3SingleDose ? [("End Day", d.T3OralDoseEnd), ("Interval (days)", d.T3OralDoseInterval)] : nil, onDelete: del) } }
                            if !simulationData.run2T3ivinputs.isEmpty { DoseDisplaySection(doses: enumeratedRun2T3IV, title: "T3-IV DOSE (Run 2)", imageName: "syringe1", onDelete: { simulationData.run2T3ivinputs.remove(at: $0) }) { i, d, del in DoseDetailsView(index: i, details: [("Dose (µg)", d.T3IVDoseInput), ("Start Day", d.T3IVDoseStart)], onDelete: del) } }
                            if !simulationData.run2T3infusioninputs.isEmpty { DoseDisplaySection(doses: enumeratedRun2T3Infusion, title: "T3-INFUSION DOSE (Run 2)", imageName: "infusion1", onDelete: { simulationData.run2T3infusioninputs.remove(at: $0) }) { i, d, del in DoseDetailsView(index: i, details: [("Dose (µg)", d.T3InfusionDoseInput), ("Start Day", d.T3InfusionDoseStart), ("End Day", d.T3InfusionDoseEnd)], onDelete: del) } }
                            if !simulationData.run2T4oralinputs.isEmpty { DoseDisplaySection(doses: enumeratedRun2T4Oral, title: "T4-ORAL DOSE (Run 2)", imageName: "pill2", onDelete: { simulationData.run2T4oralinputs.remove(at: $0) }) { i, d, del in DoseDetailsView(index: i, details: [("Dose (µg)", d.T4OralDoseInput), ("Start Day", d.T4OralDoseStart)], conditionalDetails: !d.T4SingleDose ? [("End Day", d.T4OralDoseEnd), ("Interval (days)", d.T4OralDoseInterval)] : nil, onDelete: del) } }
                            if !simulationData.run2T4ivinputs.isEmpty { DoseDisplaySection(doses: enumeratedRun2T4IV, title: "T4-IV DOSE (Run 2)", imageName: "syringe2", onDelete: { simulationData.run2T4ivinputs.remove(at: $0) }) { i, d, del in DoseDetailsView(index: i, details: [("Dose (µg)", d.T4IVDoseInput), ("Start Day", d.T4IVDoseStart)], onDelete: del) } }
                            if !simulationData.run2T4infusioninputs.isEmpty { DoseDisplaySection(doses: enumeratedRun2T4Infusion, title: "T4-INFUSION DOSE (Run 2)", imageName: "infusion2", onDelete: { simulationData.run2T4infusioninputs.remove(at: $0) }) { i, d, del in DoseDetailsView(index: i, details: [("Dose (µg)", d.T4InfusionDoseInput), ("Start Day", d.T4InfusionDoseStart), ("End Day", d.T4InfusionDoseEnd)], onDelete: del) } }
                            
                            // Bottom spacer to ensure scrolling content doesn't get cut off
                            Spacer().frame(height: 50)
                        }
                        .padding()
                    }
                    .background(Color.init(red: 0, green: 0, blue: 0).edgesIgnoringSafeArea(.all))
                    .navigationDestination(isPresented: $navigateToGraph) {
                        if let run2Result = run2Result, let days = Int(simulationDays) {
                            Run2GraphView(run2Result: run2Result, simulationDurationDays: days)
                        }
                    }
                }
                .onAppear { if self.run2Result != nil { self.run2Result = nil } }
                .onChange(of: simulationData.run1Result?.q_final?.count ?? -1) { _, _ in
                    self.run2Result = nil
                    self.navigateToGraph = false
                    simulationData.run2Result = nil
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
        .sheet(item: $activePopup) { popup in
            switch popup {
            case .T3OralInputs: T3OralPopupView { dose in simulationData.run2T3oralinputs.append(dose) }
            case .T3IVInputs: T3IVPopupView { dose in simulationData.run2T3ivinputs.append(dose) }
            case .T3InfusionInputs: T3InfusionPopupView { dose in simulationData.run2T3infusioninputs.append(dose) }
            case .T4OralInputs: T4OralPopupView { dose in simulationData.run2T4oralinputs.append(dose) }
            case .T4IVInputs: T4IVPopupView { dose in simulationData.run2T4ivinputs.append(dose) }
            case .T4InfusionInputs: T4InfusionPopupView { dose in simulationData.run2T4infusioninputs.append(dose) }
            }
        }
    }

    private func runSimulationAndNavigate() {
        guard let t4Sec = Double(t4Secretion), let t3Sec = Double(t3Secretion),
              let t4Abs = Double(t4Absorption), let t3Abs = Double(t3Absorption),
              let hVal = Double(heightString), let wVal = Double(weightString),
              var days = Int(simulationDays) else { // Changed to var
            print("Error: Invalid Run 1 parameters from AppStorage.")
            return
        }

        // Calculate 3x the end of the last dosing
        let maxDosingEnd = calculateMaxDosingEndDay()
        if maxDosingEnd > 0 { // Only adjust if there are actual doses
            let newMaxSimulationDays = Int(maxDosingEnd * 3)
            if newMaxSimulationDays > days {
                days = newMaxSimulationDays // Update local 'days' variable
                self.simulationDays = String(newMaxSimulationDays) // Update @AppStorage
            }
        }
        
        guard !isSimulating else { return }
        isSimulating = true

        Task {
            let heightInMeters = (selectedHeightUnit == "cm") ? hVal / 100.0 : ((selectedHeightUnit == "in") ? hVal * 0.0254 : hVal)
            let weightInKg = (selectedWeightUnit == "lb") ? wVal * 0.453592 : wVal
            let normalizedGender = selectedGender.uppercased()

            var simulator = ThyroidSimulator(
                t4Secretion: t4Sec, t3Secretion: t3Sec, t4Absorption: t4Abs, t3Absorption: t3Abs,
                gender: normalizedGender, height: heightInMeters, weight: weightInKg, days: days,
                t3OralDoses: simulationData.run2T3oralinputs, t4OralDoses: simulationData.run2T4oralinputs,
                t3IVDoses: simulationData.run2T3ivinputs, t4IVDoses: simulationData.run2T4ivinputs,
                t3InfusionDoses: simulationData.run2T3infusioninputs, t4InfusionDoses: simulationData.run2T4infusioninputs,
                isInitialConditionsOn: false
            )

            simulator.initialState = simulationData.run1Result?.q_final
            let result = simulator.runSimulation()

            await MainActor.run {
                self.run2Result = result
                self.isSimulating = false
                self.navigateToGraph = true
                self.simulationData.run2Result = result
                self.simulationData.previousRun2Results.append(result)
            }
        }
    }
    
    private func format(dose: T4OralDose) -> String { "Oral T4: \(String(format: "%.1f", dose.T4OralDoseInput))µg" + (dose.T4SingleDose ? " at day \(String(format: "%.1f", dose.T4OralDoseStart))" : " every \(String(format: "%.1f", dose.T4OralDoseInterval)) days") }
    private func format(dose: T4IVDose) -> String { "IV T4: \(String(format: "%.1f", dose.T4IVDoseInput))µg at day \(String(format: "%.1f", dose.T4IVDoseStart))" }
    private func format(dose: T4InfusionDose) -> String { "Infusion T4: \(String(format: "%.1f", dose.T4InfusionDoseInput))µg from day \(String(format: "%.1f", dose.T4InfusionDoseStart)) to \(String(format: "%.1f", dose.T4InfusionDoseEnd))" }
    private func format(dose: T3OralDose) -> String { "Oral T3: \(String(format: "%.1f", dose.T3OralDoseInput))µg" + (dose.T3SingleDose ? " at day \(String(format: "%.1f", dose.T3OralDoseStart))" : " every \(String(format: "%.1f", dose.T3OralDoseInterval)) days") }
    private func format(dose: T3IVDose) -> String { "IV T3: \(String(format: "%.1f", dose.T3IVDoseInput))µg at day \(String(format: "%.1f", dose.T3IVDoseStart))" }
    private func format(dose: T3InfusionDose) -> String { "Infusion T3: \(String(format: "%.1f", dose.T3InfusionDoseInput))µg from day \(String(format: "%.1f", dose.T3InfusionDoseStart)) to \(String(format: "%.1f", dose.T3InfusionDoseEnd))" }

    private func calculateMaxDosingEndDay() -> Double {
        var maxEndDay: Double = 0.0

        // T3 Oral Doses
        for dose in simulationData.run2T3oralinputs {
            if dose.T3SingleDose {
                maxEndDay = max(maxEndDay, Double(dose.T3OralDoseStart))
            } else {
                maxEndDay = max(maxEndDay, Double(dose.T3OralDoseEnd))
            }
        }
        // T3 IV Doses
        for dose in simulationData.run2T3ivinputs {
            maxEndDay = max(maxEndDay, Double(dose.T3IVDoseStart))
        }
        // T3 Infusion Doses
        for dose in simulationData.run2T3infusioninputs {
            maxEndDay = max(maxEndDay, Double(dose.T3InfusionDoseEnd))
        }

        // T4 Oral Doses
        for dose in simulationData.run2T4oralinputs {
            if dose.T4SingleDose {
                maxEndDay = max(maxEndDay, Double(dose.T4OralDoseStart))
            } else {
                maxEndDay = max(maxEndDay, Double(dose.T4OralDoseEnd))
            }
        }
        // T4 IV Doses
        for dose in simulationData.run2T4ivinputs {
            maxEndDay = max(maxEndDay, Double(dose.T4IVDoseStart))
        }
        // T4 Infusion Doses
        for dose in simulationData.run2T4infusioninputs {
            maxEndDay = max(maxEndDay, Double(dose.T4InfusionDoseEnd))
        }

        return maxEndDay
    }
}

fileprivate struct DoseDisplaySection<T: Identifiable, Content: View>: View {
    let doses: [(Int, T)]
    let title: String
    let imageName: String
    let onDelete: (Int) -> Void
    let content: (Int, T, @escaping () -> Void) -> Content

    var body: some View {
        Section {
            ForEach(doses, id: \.1.id) { index, doseData in
                content(index, doseData) { onDelete(index) }
            }
        } header: {
            HStack(alignment: .center, spacing: 10) {
                Image(imageName).resizable().frame(width: 30, height: 30)
                Text(title).font(.title2.bold()).foregroundColor(.white)
            }
        }
    }
}

fileprivate struct DoseDetailsView: View {
    let index: Int
    let details: [(String, Float)]
    var conditionalDetails: [(String, Float)]? = nil
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Dose \(index + 1)").font(.headline).foregroundColor(.white)
                Spacer()
                Button("Delete") { onDelete() }.foregroundColor(.red)
            }
            ForEach(details, id: \.0) { item in HStack { Text(item.0).foregroundColor(.gray); Spacer(); Text(String(format: "%.1f", item.1)).foregroundColor(.white) } }
            if let conditionalDetails = conditionalDetails {
                ForEach(conditionalDetails, id: \.0) { item in HStack { Text(item.0).foregroundColor(.gray); Spacer(); Text(String(format: "%.1f", item.1)).foregroundColor(.white) } }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
    }
}
