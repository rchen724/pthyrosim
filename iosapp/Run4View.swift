import SwiftUI

struct Run4View: View {
    @EnvironmentObject var simulationData: SimulationData
    @State private var activePopup: ActivePopup? = nil
    
    // Scroll tracking state
    @State private var scrollOffset: CGFloat = 0
    @State private var contentHeight: CGFloat = 1
    @State private var scrollViewHeight: CGFloat = 1
    
    @State private var run4Result: ThyroidSimulationResult?
    @State private var isSimulating: Bool = false
    @State private var navigateToGraph: Bool = false
    
    // AppStorage variables
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
    
    // Enumerated input arrays for Run4
    var enumeratedRun4T3Oral: [(Int, T3OralDose)]         { Array(simulationData.run4T3oralinputs.enumerated()) }
    var enumeratedRun4T3IV: [(Int, T3IVDose)]             { Array(simulationData.run4T3ivinputs.enumerated()) }
    var enumeratedRun4T3Infusion: [(Int, T3InfusionDose)] { Array(simulationData.run4T3infusioninputs.enumerated()) }
    var enumeratedRun4T4Oral: [(Int, T4OralDose)]         { Array(simulationData.run4T4oralinputs.enumerated()) }
    var enumeratedRun4T4IV: [(Int, T4IVDose)]             { Array(simulationData.run4T4ivinputs.enumerated()) }
    var enumeratedRun4T4Infusion: [(Int, T4InfusionDose)] { Array(simulationData.run4T4infusioninputs.enumerated()) }

    var body: some View {
        NavigationStack {
            // Check if Run 3 exists before allowing Run 4
            if simulationData.run3Result != nil {
                ZStack(alignment: .topTrailing) {
                    ScrollViewWithScrollbar(showsIndicators: false) {
                        VStack(alignment: .center, spacing: 24) {
                            
                            // Title
                            Text("Run 4 Dosing Input")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                            
                            Toggle(isOn: $isInitialConditionsOn) {
                                Text("Recalculate Initial Conditions")
                                    .foregroundColor(.white)
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .red))
                            
                    

                            HStack(alignment: .top, spacing: 20) {
                                
                                VStack(spacing: 8) {
                                    Text("T3 Input:")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    VStack(spacing: 8) {
                                        compactDoseButton(image: "pill1", text: "Oral", action: { activePopup = .T3OralInputs })
                                        compactDoseButton(image: "syringe1", text: "IV Bolus", action: { activePopup = .T3IVInputs })
                                        compactDoseButton(image: "infusion1", text: "Infusion", action: { activePopup = .T3InfusionInputs })
                                    }
                                }
                                
                                // T4 Column
                                VStack(spacing: 8) {
                                    Text("T4 Input:")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    VStack(spacing: 8) {
                                        compactDoseButton(image: "pill2", text: "Oral", action: { activePopup = .T4OralInputs })
                                        compactDoseButton(image: "syringe2", text: "IV Bolus", action: { activePopup = .T4IVInputs })
                                        compactDoseButton(image: "infusion2", text: "Infusion", action: { activePopup = .T4InfusionInputs })
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                            
                            Button(action: { runSimulationAndNavigate() }) {
                                HStack {
                                    if isSimulating {
                                        ProgressView().tint(.white)
                                            .padding(.trailing, 5)
                                    }
                                    Text(isSimulating ? "SIMULATING..." : "START SIMULATION")
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
                            

                            // Dose Lists
                            if !simulationData.run4T3oralinputs.isEmpty { DoseDisplaySection(doses: enumeratedRun4T3Oral, title: "T3-ORAL DOSE (Run 4)", imageName: "pill1", onDelete: { simulationData.run4T3oralinputs.remove(at: $0) }) { i, d, del in DoseDetailsView(index: i, details: [("Dose (µg)", d.T3OralDoseInput), ("Start Day", d.T3OralDoseStart)], conditionalDetails: !d.T3SingleDose ? [("End Day", d.T3OralDoseEnd), ("Interval (days)", d.T3OralDoseInterval)] : nil, onDelete: del) } }
                            if !simulationData.run4T3ivinputs.isEmpty { DoseDisplaySection(doses: enumeratedRun4T3IV, title: "T3-IV DOSE (Run 4)", imageName: "syringe1", onDelete: { simulationData.run4T3ivinputs.remove(at: $0) }) { i, d, del in DoseDetailsView(index: i, details: [("Dose (µg)", d.T3IVDoseInput), ("Start Day", d.T3IVDoseStart)], onDelete: del) } }
                            if !simulationData.run4T3infusioninputs.isEmpty { DoseDisplaySection(doses: enumeratedRun4T3Infusion, title: "T3-INFUSION DOSE (Run 4)", imageName: "infusion1", onDelete: { simulationData.run4T3infusioninputs.remove(at: $0) }) { i, d, del in DoseDetailsView(index: i, details: [("Dose (µg)", d.T3InfusionDoseInput), ("Start Day", d.T3InfusionDoseStart), ("End Day", d.T3InfusionDoseEnd)], onDelete: del) } }
                            if !simulationData.run4T4oralinputs.isEmpty { DoseDisplaySection(doses: enumeratedRun4T4Oral, title: "T4-ORAL DOSE (Run 4)", imageName: "pill2", onDelete: { simulationData.run4T4oralinputs.remove(at: $0) }) { i, d, del in DoseDetailsView(index: i, details: [("Dose (µg)", d.T4OralDoseInput), ("Start Day", d.T4OralDoseStart)], conditionalDetails: !d.T4SingleDose ? [("End Day", d.T4OralDoseEnd), ("Interval (days)", d.T4OralDoseInterval)] : nil, onDelete: del) } }
                            if !simulationData.run4T4ivinputs.isEmpty { DoseDisplaySection(doses: enumeratedRun4T4IV, title: "T4-IV DOSE (Run 4)", imageName: "syringe2", onDelete: { simulationData.run4T4ivinputs.remove(at: $0) }) { i, d, del in DoseDetailsView(index: i, details: [("Dose (µg)", d.T4IVDoseInput), ("Start Day", d.T4IVDoseStart)], onDelete: del) } }
                            if !simulationData.run4T4infusioninputs.isEmpty { DoseDisplaySection(doses: enumeratedRun4T4Infusion, title: "T4-INFUSION DOSE (Run 4)", imageName: "infusion2", onDelete: { simulationData.run4T4infusioninputs.remove(at: $0) }) { i, d, del in DoseDetailsView(index: i, details: [("Dose (µg)", d.T4InfusionDoseInput), ("Start Day", d.T4InfusionDoseStart), ("End Day", d.T4InfusionDoseEnd)], onDelete: del) } }
                            Spacer().frame(height: 50)
                        }
                        .padding()
                    }
                    .background(Color.init(red: 0, green: 0, blue: 0).edgesIgnoringSafeArea(.all))
                    .navigationDestination(isPresented: $navigateToGraph) {
                        if let run4Result = run4Result, let days = Int(simulationDays) {
                            Run4GraphView(run4Result: run4Result, simulationDurationDays: days)
                        }
                    }
                }
                .onAppear { if self.run4Result != nil { self.run4Result = nil } }
                .onChange(of: simulationData.run3Result?.q_final?.count ?? -1) { _, _ in
                    self.run4Result = nil
                    self.navigateToGraph = false
                    simulationData.run4Result = nil
                }
            } else {
                VStack {
                    Text("Please run the 'Run 3' simulation first.")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .navigationTitle("START SIMULATION")
            }
        }
        .sheet(item: $activePopup) { popup in
            switch popup {
            case .T3OralInputs: T3OralPopupView { dose in simulationData.run4T3oralinputs.append(dose) }
            case .T3IVInputs: T3IVPopupView { dose in simulationData.run4T3ivinputs.append(dose) }
            case .T3InfusionInputs: T3InfusionPopupView { dose in simulationData.run4T3infusioninputs.append(dose) }
            case .T4OralInputs: T4OralPopupView { dose in simulationData.run4T4oralinputs.append(dose) }
            case .T4IVInputs: T4IVPopupView { dose in simulationData.run4T4ivinputs.append(dose) }
            case .T4InfusionInputs: T4InfusionPopupView { dose in simulationData.run4T4infusioninputs.append(dose) }
            }
        }
    }

    private func runSimulationAndNavigate() {
        guard let t4Sec = Double(t4Secretion), let t3Sec = Double(t3Secretion),
              let t4Abs = Double(t4Absorption), let t3Abs = Double(t3Absorption),
              let hVal = Double(heightString), let wVal = Double(weightString),
              var days = Int(simulationDays) else {
            print("Error: Invalid Run parameters from AppStorage.")
            return
        }

        // Calculate 3x the end of the last dosing
        let maxDosingEnd = calculateMaxDosingEndDay()
        if maxDosingEnd > 0 {
            let newMaxSimulationDays = Int(maxDosingEnd * 3)
            if newMaxSimulationDays > days {
                days = newMaxSimulationDays
                self.simulationDays = String(newMaxSimulationDays)
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
                t3OralDoses: simulationData.run4T3oralinputs, t4OralDoses: simulationData.run4T4oralinputs,
                t3IVDoses: simulationData.run4T3ivinputs, t4IVDoses: simulationData.run4T4ivinputs,
                t3InfusionDoses: simulationData.run4T3infusioninputs, t4InfusionDoses: simulationData.run4T4infusioninputs,
                isInitialConditionsOn: false
            )

            // CHAIN FROM RUN 3
            simulator.initialState = simulationData.run3Result?.q_final
            let result = simulator.runSimulation()

            await MainActor.run {
                self.run4Result = result
                self.isSimulating = false
                self.navigateToGraph = true
                self.simulationData.run4Result = result
                self.simulationData.previousRun4Results.append(result)
            }
        }
    }
    
    private func calculateMaxDosingEndDay() -> Double {
        var maxEndDay: Double = 0.0

        for dose in simulationData.run4T3oralinputs {
            if dose.T3SingleDose {
                maxEndDay = max(maxEndDay, Double(dose.T3OralDoseStart))
            } else {
                maxEndDay = max(maxEndDay, Double(dose.T3OralDoseEnd))
            }
        }
        for dose in simulationData.run4T3ivinputs {
            maxEndDay = max(maxEndDay, Double(dose.T3IVDoseStart))
        }
        for dose in simulationData.run4T3infusioninputs {
            maxEndDay = max(maxEndDay, Double(dose.T3InfusionDoseEnd))
        }

        for dose in simulationData.run4T4oralinputs {
            if dose.T4SingleDose {
                maxEndDay = max(maxEndDay, Double(dose.T4OralDoseStart))
            } else {
                maxEndDay = max(maxEndDay, Double(dose.T4OralDoseEnd))
            }
        }
        for dose in simulationData.run4T4ivinputs {
            maxEndDay = max(maxEndDay, Double(dose.T4IVDoseStart))
        }
        for dose in simulationData.run4T4infusioninputs {
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
