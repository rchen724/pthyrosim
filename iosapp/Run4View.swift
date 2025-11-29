import SwiftUI

struct Run4View: View {
    @EnvironmentObject var simulationData: SimulationData
    @State private var activePopup: ActivePopup? = nil
    @State private var scrollOffset: CGFloat = 0
    @State private var contentHeight: CGFloat = 1
    @State private var scrollViewHeight: CGFloat = 1
    @State private var run4Result: ThyroidSimulationResult? = nil
    @State private var isSimulating = false
    @State private var navigateToGraph = false
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

    var enumeratedRun4T3Oral: [(Int, T3OralDose)] { Array(simulationData.run4T3oralinputs.enumerated()) }
    var enumeratedrun44T3IV: [(Int, T3IVDose)] { Array(simulationData.run4T3ivinputs.enumerated()) }
    var enumeratedRun4T3Infusion: [(Int, T3InfusionDose)] { Array(simulationData.run4T3infusioninputs.enumerated()) }
    var enumeratedRun4T4Oral: [(Int, T4OralDose)] { Array(simulationData.run4T4oralinputs.enumerated()) }
    var enumeratedRun4T4IV: [(Int, T4IVDose)] { Array(simulationData.run4T4ivinputs.enumerated()) }
    var enumeratedRun4T4Infusion: [(Int, T4InfusionDose)] { Array(simulationData.run4T4infusioninputs.enumerated()) }

    var body: some View {
        NavigationStack {
            if simulationData.run3Result != nil {
                run4MainContent
            } else {
                VStack {
                    Text("Please run the 'Simulate Dosing' (Run 2) simulation first.")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .navigationTitle("Simulate Dosing")
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

    private var run4MainContent: some View {
        ZStack(alignment: .topTrailing) {
            ScrollViewWithScrollbar(showsIndicators: false) {
                VStack(alignment: .center, spacing: 24) {
                    headerText
                    doseInputSection
                    doseDisplaySections
                    simulateButton
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
        .onChange(of: simulationData.run2Result?.q_final?.count ?? -1) { _, _ in
            self.run4Result = nil
            self.navigateToGraph = false
            simulationData.run4Result = nil
        }
    }

    private var headerText: some View {
        Text("Run 4 Dosing Input")
            .font(.title2.bold())
            .foregroundColor(.white)
    }

    private var doseInputSection: some View {
        HStack(alignment: .top, spacing: 40) {
            doseInputColumn(title: "T3 Input:", buttons: [
                ("pill1", "Oral Dose", .T3OralInputs),
                ("syringe1", "IV Bolus Dose", .T3IVInputs),
                ("infusion1", "Infusion Dose", .T3InfusionInputs)
            ])
            doseInputColumn(title: "T4 Input:", buttons: [
                ("pill2", "Oral Dose", .T4OralInputs),
                ("syringe2", "IV Bolus Dose", .T4IVInputs),
                ("infusion2", "Infusion Dose", .T4InfusionInputs)
            ])
        }
        .frame(maxWidth: .infinity)
        .padding()
    }

    private func doseInputColumn(title: String, buttons: [(String, String, ActivePopup)]) -> some View {
        VStack(alignment: .center, spacing: 16) {
            Text(title)
                .font(.title3.bold())
                .foregroundColor(.white)
            VStack(spacing: 12) {
                ForEach(buttons, id: \.1) { image, label, popup in
                    Button { activePopup = popup } label: {
                        VStack {
                            Image(image)
                            Text(label).font(.headline).foregroundColor(.white)
                        }
                    }
                }
            }
        }
    }

    private var doseDisplaySections: some View {
        VStack(spacing: 12) {
            if !simulationData.run4T3oralinputs.isEmpty {
                DoseDisplaySection(doses: enumeratedRun4T3Oral, title: "T3-ORAL DOSE (Run 3)", imageName: "pill1", onDelete: { simulationData.run4T3oralinputs.remove(at: $0) }) { i, d, del in
                    DoseDetailsView(index: i, details: [("Dose (µg)", d.T3OralDoseInput), ("Start Day", d.T3OralDoseStart)], conditionalDetails: !d.T3SingleDose ? [("End Day", d.T3OralDoseEnd), ("Interval (days)", d.T3OralDoseInterval)] : nil, onDelete: del)
                }
            }
            if !simulationData.run4T3ivinputs.isEmpty {
                DoseDisplaySection(doses: enumeratedrun44T3IV, title: "T3-IV DOSE (Run 3)", imageName: "syringe1", onDelete: { simulationData.run4T3ivinputs.remove(at: $0) }) { i, d, del in
                    DoseDetailsView(index: i, details: [("Dose (µg)", d.T3IVDoseInput), ("Start Day", d.T3IVDoseStart)], onDelete: del)
                }
            }
            if !simulationData.run4T3infusioninputs.isEmpty {
                DoseDisplaySection(doses: enumeratedRun4T3Infusion, title: "T3-INFUSION DOSE (Run 3)", imageName: "infusion1", onDelete: { simulationData.run4T3infusioninputs.remove(at: $0) }) { i, d, del in
                    DoseDetailsView(index: i, details: [("Dose (µg)", d.T3InfusionDoseInput), ("Start Day", d.T3InfusionDoseStart), ("End Day", d.T3InfusionDoseEnd)], onDelete: del)
                }
            }
            if !simulationData.run4T4oralinputs.isEmpty {
                DoseDisplaySection(doses: enumeratedRun4T4Oral, title: "T4-ORAL DOSE (Run 3)", imageName: "pill2", onDelete: { simulationData.run4T4oralinputs.remove(at: $0) }) { i, d, del in
                    DoseDetailsView(index: i, details: [("Dose (µg)", d.T4OralDoseInput), ("Start Day", d.T4OralDoseStart)], conditionalDetails: !d.T4SingleDose ? [("End Day", d.T4OralDoseEnd), ("Interval (days)", d.T4OralDoseInterval)] : nil, onDelete: del)
                }
            }
            if !simulationData.run4T4ivinputs.isEmpty {
                DoseDisplaySection(doses: enumeratedRun4T4IV, title: "T4-IV DOSE (Run 3)", imageName: "syringe2", onDelete: { simulationData.run4T4ivinputs.remove(at: $0) }) { i, d, del in
                    DoseDetailsView(index: i, details: [("Dose (µg)", d.T4IVDoseInput), ("Start Day", d.T4IVDoseStart)], onDelete: del)
                }
            }
            if !simulationData.run4T4infusioninputs.isEmpty {
                DoseDisplaySection(doses: enumeratedRun4T4Infusion, title: "T4-INFUSION DOSE (Run 3)", imageName: "infusion2", onDelete: { simulationData.run4T4infusioninputs.remove(at: $0) }) { i, d, del in
                    DoseDetailsView(index: i, details: [("Dose (µg)", d.T4InfusionDoseInput), ("Start Day", d.T4InfusionDoseStart), ("End Day", d.T4InfusionDoseEnd)], onDelete: del)
                }
            }
        }
    }

    private var simulateButton: some View {
        Button(action: { runSimulationAndNavigate() }) {
            HStack {
                Spacer()
                if isSimulating { ProgressView() } else { Text("Simulate Dosing").fontWeight(.bold) }
                Spacer()
            }
        }
        .disabled(isSimulating)
        .padding()
    }

    private func runSimulationAndNavigate() {
        guard let t4Sec = Double(t4Secretion), let t3Sec = Double(t3Secretion),
              let t4Abs = Double(t4Absorption), let t3Abs = Double(t3Absorption),
              let hVal = Double(height), let wVal = Double(weight),
              let days = Int(simulationDays) else { return }

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

            simulator.initialState = simulationData.run2Result?.q_final
            let result = simulator.runSimulation()

            await MainActor.run {
                self.run4Result = result
                self.isSimulating = false
                self.navigateToGraph = true
                self.simulationData.run4Result = result
                simulationData.previousRun4Results.append(result)
            }
        }
    }

    private func format(dose: T4OralDose) -> String { "Oral T4: \(String(format: "%.1f", dose.T4OralDoseInput))µg" + (dose.T4SingleDose ? " at day \(String(format: "%.1f", dose.T4OralDoseStart))" : " every \(String(format: "%.1f", dose.T4OralDoseInterval)) days") }
    private func format(dose: T4IVDose) -> String { "IV T4: \(String(format: "%.1f", dose.T4IVDoseInput))µg at day \(String(format: "%.1f", dose.T4IVDoseStart))" }
    private func format(dose: T4InfusionDose) -> String { "Infusion T4: \(String(format: "%.1f", dose.T4InfusionDoseInput))µg from day \(String(format: "%.1f", dose.T4InfusionDoseStart)) to \(String(format: "%.1f", dose.T4InfusionDoseEnd))" }
    private func format(dose: T3OralDose) -> String { "Oral T3: \(String(format: "%.1f", dose.T3OralDoseInput))µg" + (dose.T3SingleDose ? " at day \(String(format: "%.1f", dose.T3OralDoseStart))" : " every \(String(format: "%.1f", dose.T3OralDoseInterval)) days") }
    private func format(dose: T3IVDose) -> String { "IV T3: \(String(format: "%.1f", dose.T3IVDoseInput))µg at day \(String(format: "%.1f", dose.T3IVDoseStart))" }
    private func format(dose: T3InfusionDose) -> String { "Infusion T3: \(String(format: "%.1f", dose.T3InfusionDoseInput))µg from day \(String(format: "%.1f", dose.T3InfusionDoseStart)) to \(String(format: "%.1f", dose.T3InfusionDoseEnd))" }
}

fileprivate struct BulletRows<Content: View>: View {
    private let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•").font(.subheadline).foregroundColor(.white).frame(width: 14, alignment: .leading)
            VStack(alignment: .center, spacing: 2) {
                content.font(.subheadline).foregroundColor(.white).multilineTextAlignment(.center).frame(maxWidth: .infinity, alignment: .center)
            }.frame(maxWidth: .infinity, alignment: .center)
        }
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
