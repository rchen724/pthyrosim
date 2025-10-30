import SwiftUI

struct Run3DosingInputView: View {
    @EnvironmentObject var simulationData: SimulationData
    @State private var activePopup: Run3ActivePopup? = nil
    
    // Scroll tracking state for custom scrollbar
    @State private var scrollOffset: CGFloat = 0
    @State private var contentHeight: CGFloat = 1
    @State private var scrollViewHeight: CGFloat = 1
    
    // Enumerated input arrays for Run3
    var enumeratedRun3T3Oral: [(Int, T3OralDose)] {
        Array(simulationData.run3T3oralinputs.enumerated())
    }
    var enumeratedRun3T3IV: [(Int, T3IVDose)] {
        Array(simulationData.run3T3ivinputs.enumerated())
    }
    var enumeratedRun3T3Infusion: [(Int, T3InfusionDose)] {
        Array(simulationData.run3T3infusioninputs.enumerated())
    }
    var enumeratedRun3T4Oral: [(Int, T4OralDose)] {
        Array(simulationData.run3T4oralinputs.enumerated())
    }
    var enumeratedRun3T4IV: [(Int, T4IVDose)] {
        Array(simulationData.run3T4ivinputs.enumerated())
    }
    var enumeratedRun3T4Infusion: [(Int, T4InfusionDose)] {
        Array(simulationData.run3T4infusioninputs.enumerated())
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
            ScrollViewWithScrollbar(showsIndicators: false) {
                VStack(alignment: .center, spacing: 24) {
                    // Invisible GeometryReader to track scroll offset
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                self.scrollOffset = -geo.frame(in: .named("scroll")).origin.y
                            }
                    }
                    .frame(height: 0)

                    Text("Run 3 Dosing Input")
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    // HOW TO DO IT… — now using BulletRow
                    VStack(alignment: .center, spacing: 10) {
                        Text("HOW TO DO IT...")
                            .font(.headline)
                            .foregroundColor(.white)

                        BulletRows {
                            Text("T3 and/or T4 input dosing can be chosen as oral;")
                            Text("OR intravenous (IV) bolus;")
                            Text("OR infusion doses.")
                        }

                        BulletRows {
                            Text("Click one or more icons to add as many inputs")
                            Text("and/or as many times as desired")
                        }

                        BulletRows{
                            Text("Click 'More' tab to review doses, simulate, or reset all options and restore defaults")
                       
                        }
                    }

                    HStack(alignment: .top, spacing: 40) {
                        VStack(alignment: .center, spacing: 16) {
                            Text("T3 Input:")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                            VStack(spacing: 12) {
                                Button(action: { activePopup = .Run3T3OralInputs }) {
                                    VStack {
                                        Image("pill1")
                                        Text("Oral Dose")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                }
                                Button(action: { activePopup = .Run3T3IVInputs }) {
                                    VStack {
                                        Image("syringe1")
                                        Text("IV Bolus Dose")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                }
                                Button(action: { activePopup = .Run3T3InfusionInputs }) {
                                    VStack {
                                        Image("infusion1")
                                        Text("Infusion Dose")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }

                        VStack(alignment: .center, spacing: 16) {
                            Text("T4 Input:")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                            VStack(spacing: 12) {
                                Button(action: { activePopup = .Run3T4OralInputs }) {
                                    VStack {
                                        Image("pill2")
                                        Text("Oral Dose")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                }
                                Button(action: { activePopup = .Run3T4IVInputs }) {
                                    VStack {
                                        Image("syringe2")
                                        Text("IV Bolus Dose")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                }
                                Button(action: { activePopup = .Run3T4InfusionInputs }) {
                                    VStack {
                                        Image("infusion2")
                                        Text("Infusion Dose")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()

                    // Display Sections
                    if !simulationData.run3T3oralinputs.isEmpty {
                        DoseDisplaySection(
                            doses: enumeratedRun3T3Oral,
                            title: "T3-ORAL DOSE (Run 3)",
                            imageName: "pill1",
                            onDelete: { simulationData.run3T3oralinputs.remove(at: $0) }
                        ) { index, t3oral, delete in
                            DoseDetailsView(
                                index: index,
                                details: [
                                    ("Dose (µg)", t3oral.T3OralDoseInput),
                                    ("Dose Start Day or Time", t3oral.T3OralDoseStart)
                                ],
                                conditionalDetails: !t3oral.T3SingleDose ? [
                                    ("Dose End Day or Time", t3oral.T3OralDoseEnd),
                                    ("Dose Interval (days)", t3oral.T3OralDoseInterval)
                                ] : nil,
                                onDelete: delete
                            )
                        }
                    }

                    if !simulationData.run3T3ivinputs.isEmpty {
                        DoseDisplaySection(
                            doses: enumeratedRun3T3IV,
                            title: "T3-IV DOSE (Run 3)",
                            imageName: "syringe1",
                            onDelete: { simulationData.run3T3ivinputs.remove(at: $0) }
                        ) { index, t3iv, delete in
                            DoseDetailsView(
                                index: index,
                                details: [
                                    ("Dose (µg)", t3iv.T3IVDoseInput),
                                    ("Dose Start Day or Time", t3iv.T3IVDoseStart)
                                ],
                                conditionalDetails: nil,
                                onDelete: delete
                            )
                        }
                    }

                    if !simulationData.run3T3infusioninputs.isEmpty {
                        DoseDisplaySection(
                            doses: enumeratedRun3T3Infusion,
                            title: "T3-INFUSION DOSE (Run 3)",
                            imageName: "infusion1",
                            onDelete: { simulationData.run3T3infusioninputs.remove(at: $0) }
                        ) { index, t3infusion, delete in
                            DoseDetailsView(
                                index: index,
                                details: [
                                    ("Dose (µg)", t3infusion.T3InfusionDoseInput),
                                    ("Dose Start Day or Time", t3infusion.T3InfusionDoseStart),
                                    ("Dose End Day or Time", t3infusion.T3InfusionDoseEnd)
                                ],
                                conditionalDetails: nil,
                                onDelete: delete
                            )
                        }
                    }

                    if !simulationData.run3T4oralinputs.isEmpty {
                        DoseDisplaySection(
                            doses: enumeratedRun3T4Oral,
                            title: "T4-ORAL DOSE (Run 3)",
                            imageName: "pill2",
                            onDelete: { simulationData.run3T4oralinputs.remove(at: $0) }
                        ) { index, t4oral, delete in
                            DoseDetailsView(
                                index: index,
                                details: [
                                    ("Dose (µg)", t4oral.T4OralDoseInput),
                                    ("Dose Start Day or Time", t4oral.T4OralDoseStart)
                                ],
                                conditionalDetails: !t4oral.T4SingleDose ? [
                                    ("Dose End Day or Time", t4oral.T4OralDoseEnd),
                                    ("Dose Interval (days)", t4oral.T4OralDoseInterval)
                                ] : nil,
                                onDelete: delete
                            )
                        }
                    }

                    if !simulationData.run3T4ivinputs.isEmpty {
                        DoseDisplaySection(
                            doses: enumeratedRun3T4IV,
                            title: "T4-IV DOSE (Run 3)",
                            imageName: "syringe2",
                            onDelete: { simulationData.run3T4ivinputs.remove(at: $0) }
                        ) { index, t4iv, delete in
                            DoseDetailsView(
                                index: index,
                                details: [
                                    ("Dose (µg)", t4iv.T4IVDoseInput),
                                    ("Dose Start Day or Time", t4iv.T4IVDoseStart)
                                ],
                                conditionalDetails: nil,
                                onDelete: delete
                            )
                        }
                    }

                    if !simulationData.run3T4infusioninputs.isEmpty {
                        DoseDisplaySection(
                            doses: enumeratedRun3T4Infusion,
                            title: "T4-INFUSION DOSE (Run 3)",
                            imageName: "infusion2",
                            onDelete: { simulationData.run3T4infusioninputs.remove(at: $0) }
                        ) { index, t4infusion, delete in
                            DoseDetailsView(
                                index: index,
                                details: [
                                    ("Dose (µg)", t4infusion.T4InfusionDoseInput),
                                    ("Dose Start Day or Time", t4infusion.T4InfusionDoseStart),
                                    ("Dose End Day or Time", t4infusion.T4InfusionDoseEnd)
                                ],
                                conditionalDetails: nil,
                                onDelete: delete
                            )
                        }
                    }
                }

                .padding()
            }
            .coordinateSpace(name: "scroll")


            }
            
        }
        .background(Color.black.ignoresSafeArea())
        .sheet(item: $activePopup) { popup in
            switch popup {
            case .Run3T3OralInputs:
                Run3T3OralPopupView { dose in
                    simulationData.run3T3oralinputs.append(dose)
                }
            case .Run3T3IVInputs:
                Run3T3IVPopupView { dose in
                    simulationData.run3T3ivinputs.append(dose)
                }
            case .Run3T3InfusionInputs:
                Run3T3InfusionPopupView { dose in
                    simulationData.run3T3infusioninputs.append(dose)
                }
            case .Run3T4OralInputs:
                Run3T4OralPopupView { dose in
                    simulationData.run3T4oralinputs.append(dose)
                }
            case .Run3T4IVInputs:
                Run3T4IVPopupView { dose in
                    simulationData.run3T4ivinputs.append(dose)
                }
            case .Run3T4InfusionInputs:
                Run3T4InfusionPopupView { dose in
                    simulationData.run3T4infusioninputs.append(dose)
                }
            }
        }
    }
}

// MARK: - DoseDisplaySection

fileprivate struct DoseDisplaySection<T: Identifiable, Content: View>: View {
    let doses: [(Int, T)]
    let title: String
    let imageName: String
    let onDelete: (Int) -> Void
    let content: (Int, T, @escaping () -> Void) -> Content

    var body: some View {
        Section {
            ForEach(doses, id: \.1.id) { index, doseData in
                content(index, doseData) {
                    onDelete(index)
                }
            }
        } header: {
            HStack(alignment: .center, spacing: 10) {
                Image(imageName)
                    .resizable()
                    .frame(width: 30, height: 30)
                Text(title)
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }
        }
    }
}

fileprivate struct BulletRows<Content: View>: View {
    private let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Fixed-width bullet area to align all bullets vertically
            Text("•")
                .font(.subheadline)
                .foregroundColor(.white)
                .frame(width: 14, alignment: .leading)

            // Center the provided content within the remaining width
            VStack(alignment: .center, spacing: 2) {
                content
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

// MARK: - DoseDetailsView

fileprivate struct DoseDetailsView: View {
    let index: Int
    let details: [(String, Float)]
    let conditionalDetails: [(String, Float)]?
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Dose \(index + 1)")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button("Delete") {
                    onDelete()
                }
                .foregroundColor(.red)
            }
            
            ForEach(details, id: \.0) { detail in
                HStack {
                    Text(detail.0)
                        .foregroundColor(.gray)
                    Spacer()
                    Text(String(format: "%.1f", detail.1))
                        .foregroundColor(.white)
                }
            }
            
            if let conditionalDetails = conditionalDetails {
                ForEach(conditionalDetails, id: \.0) { detail in
                    HStack {
                        Text(detail.0)
                            .foregroundColor(.gray)
                        Spacer()
                        Text(String(format: "%.1f", detail.1))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
    }
}
