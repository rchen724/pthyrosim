import SwiftUI
import Foundation

struct Step2View: View {
    @EnvironmentObject var simulationData: SimulationData
    @State private var activePopup: ActivePopup? = nil

    // Scroll tracking state for custom scrollbar
    @State private var scrollOffset: CGFloat = 0
    @State private var contentHeight: CGFloat = 1
    @State private var scrollViewHeight: CGFloat = 1

    // Enumerated input arrays
    var enumeratedT3Oral: [(Int, T3OralDose)] {
        Array(simulationData.t3oralinputs.enumerated())
    }
    var enumeratedT3IV: [(Int, T3IVDose)] {
        Array(simulationData.t3ivinputs.enumerated())
    }
    var enumeratedT3Infusion: [(Int, T3InfusionDose)] {
        Array(simulationData.t3infusioninputs.enumerated())
    }
    var enumeratedT4Oral: [(Int, T4OralDose)] {
        Array(simulationData.t4oralinputs.enumerated())
    }
    var enumeratedT4IV: [(Int, T4IVDose)] {
        Array(simulationData.t4ivinputs.enumerated())
    }
    var enumeratedT4Infusion: [(Int, T4InfusionDose)] {
        Array(simulationData.t4infusioninputs.enumerated())
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: 24) {
                    // Invisible GeometryReader to track scroll offset
                    GeometryReader { geo -> Color in
                        DispatchQueue.main.async {
                            self.scrollOffset = -geo.frame(in: .named("scroll")).origin.y
                        }
                        return Color.clear
                    }
                    .frame(height: 0)

                    Text("Simulated Dosing Experiments")
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    VStack(alignment: .center, spacing: 12) {
                        Text("HOW TO DO IT...")
                            .font(.headline)
                            .foregroundColor(.white)

                        VStack(alignment: .leading, spacing: 6) {
                            HStack(alignment: .firstTextBaseline) {
                                Text("• ")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                VStack(alignment: .center){
                                    Text("T3 and/or T4 input dosing can be chosen as oral;")
                                    Text("OR intravenous (IV) bolus;")
                                    Text("OR infusion doses.")
                                }
                                .font(.subheadline)
                                .foregroundColor(.white)
                                
                            }

                            HStack(alignment: .firstTextBaseline) {
                                Text("• ")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                VStack(alignment: .center) {
                                    Text("Click one or more icons to add as many inputs")
                                    Text("and/or as many times as desired")
                                }
                                .font(.subheadline)
                                .foregroundColor(.white)
                            }
                            HStack(alignment: .firstTextBaseline) {
                                Text("• ")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                VStack(alignment: .center) {
                                    Text("A second dosing experiment can be run by")
                                    Text("clicking on next to last icon below")
                                    
                                }
                                .font(.subheadline)
                                .foregroundColor(.white)
                            }
                        }
                        .font(.footnote)
                    }

                    HStack(alignment: .top, spacing: 40) {
                        VStack(alignment: .center, spacing: 16) {
                            Text("T3 Input:")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                            VStack(spacing: 12) {
                                Button(action: { activePopup = .T3OralInputs }) {
                                    VStack {
                                        Image("pill1")
                                        Text("Oral Dose")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                }
                                Button(action: { activePopup = .T3IVInputs }) {
                                    VStack {
                                        Image("syringe1")
                                        Text("IV Bolus Dose")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                }
                                Button(action: { activePopup = .T3InfusionInputs }) {
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
                                Button(action: { activePopup = .T4OralInputs }) {
                                    VStack {
                                        Image("pill2")
                                        Text("Oral Dose")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                }
                                Button(action: { activePopup = .T4IVInputs }) {
                                    VStack {
                                        Image("syringe2")
                                        Text("IV Bolus Dose")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                }
                                Button(action: { activePopup = .T4InfusionInputs }) {
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
                    if !simulationData.t3oralinputs.isEmpty {
                        DoseDisplaySection(
                            doses: enumeratedT3Oral,
                            title: "T3-ORAL DOSE",
                            imageName: "pill1",
                            onDelete: { simulationData.t3oralinputs.remove(at: $0) }
                        ) { index, t3oral, delete in
                            DoseDetailsView(
                                index: index,
                                details: [
                                    ("Dose (µg)", t3oral.T3OralDoseInput),
                                    ("Dose Start Day or Time", t3oral.T3OralDoseStart)
                                ],
                                conditionalDetails: !t3oral.T3SingleDose ? [
                                    ("Dose End Day or Time", t3oral.T3OralDoseEnd),
                                    ("Dosing Interval (days)", t3oral.T3OralDoseInterval)
                                ] : nil,
                                onDelete: delete
                            )
                        }
                    }

                    if !simulationData.t3ivinputs.isEmpty {
                        DoseDisplaySection(
                            doses: enumeratedT3IV,
                            title: "T3-IV DOSE",
                            imageName: "syringe1",
                            onDelete: { simulationData.t3ivinputs.remove(at: $0) }
                        ) { index, t3iv, delete in
                            DoseDetailsView(
                                index: index,
                                details: [
                                    ("Dose (µg)", t3iv.T3IVDoseInput),
                                    ("Dose Start Day or Time", t3iv.T3IVDoseStart)
                                ],
                                onDelete: delete
                            )
                        }
                    }

                    if !simulationData.t3infusioninputs.isEmpty {
                        DoseDisplaySection(
                            doses: enumeratedT3Infusion,
                            title: "T3-INFUSION DOSE",
                            imageName: "infusion1",
                            onDelete: { simulationData.t3infusioninputs.remove(at: $0) }
                        ) { index, t3infusion, delete in
                            DoseDetailsView(
                                index: index,
                                details: [
                                    ("Dose (µg)", t3infusion.T3InfusionDoseInput),
                                    ("Dose Start Day or Time", t3infusion.T3InfusionDoseStart),
                                    ("Dose End Day or Time", t3infusion.T3InfusionDoseEnd)
                                ],
                                onDelete: delete
                            )
                        }
                    }

                    if !simulationData.t4oralinputs.isEmpty {
                        DoseDisplaySection(
                            doses: enumeratedT4Oral,
                            title: "T4-ORAL DOSE",
                            imageName: "pill2",
                            onDelete: { simulationData.t4oralinputs.remove(at: $0) }
                        ) { index, t4oral, delete in
                            DoseDetailsView(
                                index: index,
                                details: [
                                    ("Dose (µg)", t4oral.T4OralDoseInput),
                                    ("Dose Start Day or Time", t4oral.T4OralDoseStart)
                                ],
                                conditionalDetails: !t4oral.T4SingleDose ? [
                                    ("Dose End Day or Time", t4oral.T4OralDoseEnd),
                                    ("Dosing Interval (days)", t4oral.T4OralDoseInterval)
                                ] : nil,
                                onDelete: delete
                            )
                        }
                    }

                    if !simulationData.t4ivinputs.isEmpty {
                        DoseDisplaySection(
                            doses: enumeratedT4IV,
                            title: "T4-IV DOSE",
                            imageName: "syringe2",
                            onDelete: { simulationData.t4ivinputs.remove(at: $0) }
                        ) { index, t4iv, delete in
                            DoseDetailsView(
                                index: index,
                                details: [
                                    ("Dose (µg)", t4iv.T4IVDoseInput),
                                    ("Dose Start Day or Time", t4iv.T4IVDoseStart)
                                ],
                                onDelete: delete
                            )
                        }
                    }

                    if !simulationData.t4infusioninputs.isEmpty {
                        DoseDisplaySection(
                            doses: enumeratedT4Infusion,
                            title: "T4-INFUSION DOSE",
                            imageName: "infusion2",
                            onDelete: { simulationData.t4infusioninputs.remove(at: $0) }
                        ) { index, t4infusion, delete in
                            DoseDetailsView(
                                index: index,
                                details: [
                                    ("Dose (µg)", t4infusion.T4InfusionDoseInput),
                                    ("Dose Start Day or Time", t4infusion.T4InfusionDoseStart),
                                    ("Dose End Day or Time", t4infusion.T4InfusionDoseEnd)
                                ],
                                onDelete: delete
                            )
                        }
                    }

                    Spacer().frame(height: 80)
                }
                .background(
                    GeometryReader { geo -> Color in
                        DispatchQueue.main.async {
                            self.contentHeight = geo.size.height
                        }
                        return Color.clear
                    }
                )
            }
            .coordinateSpace(name: "scroll")
            .background(
                GeometryReader { geo -> Color in
                    DispatchQueue.main.async {
                        self.scrollViewHeight = geo.size.height
                    }
                    return Color.clear
                }
            )

            // Custom scrollbar (only show if content taller than scrollView)
            if contentHeight > scrollViewHeight {
                let maxScroll = max(contentHeight - scrollViewHeight, 1)
                let clampedOffset = min(max(scrollOffset, 0), maxScroll)
                let scrollProgress = clampedOffset / maxScroll
                let visibleRatio = scrollViewHeight / contentHeight
                let thumbHeight = max(scrollViewHeight * visibleRatio * 0.25, 30) // min height 30
                let thumbTop = scrollProgress * (scrollViewHeight - thumbHeight)

                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.gray.opacity(0.8))
                    .frame(width: 8, height: thumbHeight)
                    .padding(.trailing, 4)
                    .offset(y: thumbTop)
                    .animation(.easeInOut(duration: 0.15), value: thumbTop)
            }
        }
        .background(Color.black.ignoresSafeArea())
        .sheet(item: $activePopup) { popup in
            switch popup {
            case .T3OralInputs:
                T3OralPopupView { newDose in
                    self.simulationData.t3oralinputs.append(newDose)
                }
            case .T3IVInputs:
                T3IVPopupView { newDose in
                    self.simulationData.t3ivinputs.append(newDose)
                }
            case .T3InfusionInputs:
                T3InfusionPopupView { newDose in
                    self.simulationData.t3infusioninputs.append(newDose)
                }
            case .T4OralInputs:
                T4OralPopupView { newDose in
                    self.simulationData.t4oralinputs.append(newDose)
                }
            case .T4IVInputs:
                T4IVPopupView { newDose in
                    self.simulationData.t4ivinputs.append(newDose)
                }
            case .T4InfusionInputs:
                T4InfusionPopupView { newDose in
                    self.simulationData.t4infusioninputs.append(newDose)
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

// MARK: - DoseDetailsView

fileprivate struct DoseDetailsView: View {
    let index: Int
    let details: [(String, Float)]
    var conditionalDetails: [(String, Float)]? = nil
    var onDelete: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text("Input \(index + 1):")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                ForEach(details, id: \.0) { label, value in
                    Text("\(label): \(String(format: "%.2f", value))")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                if let conditionalDetails = conditionalDetails {
                    ForEach(conditionalDetails, id: \.0) { label, value in
                        Text("\(label): \(String(format: "%.2f", value))")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
            }
            Spacer()
            if let onDelete = onDelete {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}
