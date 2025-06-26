import Foundation
import SwiftUI

struct Step2View: View {
    // Connect to the shared data model instead of using local state
    @EnvironmentObject var simulationData: SimulationData
    
    @State private var activePopup: ActivePopup? = nil
    
    // The enumerated properties now read from the shared simulationData object
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
    
    // Your original UI is preserved here
    var body: some View {
        ZStack{
            ScrollView {
                VStack(alignment: .center, spacing: 24) {
                    Text("Simulated Dosing Experiment")
                        .font(.title2.bold())
                    
                    VStack(alignment: .center, spacing: 12) {
                        Text("HOW TO DO IT...")
                            .font(.headline)
                            .foregroundColor(.white)

                        VStack(alignment: .leading, spacing: 6) {
                            HStack(alignment: .firstTextBaseline) {
                                Text("• ")
                                    .font(.subheadline)
                                VStack(alignment: .center){
                                    Text("T3 and/or T4 input dosing can be chosen as oral;")
                                        .font(.subheadline)
                                    Text("OR intravenous (IV) bolus;")
                                        .font(.subheadline)
                                    Text("OR infusion doses.")
                                        .font(.subheadline)
                                }
                            }

                            HStack(alignment: .firstTextBaseline) {
                                Text("• ")
                                    .font(.subheadline)
                                VStack(alignment: .center) {
                                    Text("Click one or more icons to add as many inputs")
                                        .font(.subheadline)
                                    Text("and/or as many times as desired")
                                        .font(.subheadline)
                                }
                                
                            }
                        }
                        .font(.footnote)
                    }
                    
                    HStack(alignment: .top, spacing: 40) {
                        VStack(alignment: .center, spacing: 16) {
                            Text("T3 Input:")
                                .font(.headline)
                            VStack(spacing: 12) {
                                Button(action: { activePopup = .T3OralInputs }) {
                                    VStack{
                                        Image("pill1")
                                        Text("Oral Dose")
                                    }
                                }
                                Button(action: { activePopup = .T3IVInputs }) {
                                    VStack{
                                        Image("syringe1")
                                        Text("IV Bolus Dose")
                                    }
                                }
                                Button(action: { activePopup = .T3InfusionInputs }) {
                                    VStack{
                                        Image("infusion1")
                                        Text("Infusion Dose")
                                    }
                                }
                            }
                        }
                        
                        VStack(alignment: .center, spacing: 16) {
                            Text("T4 Input:")
                                .font(.headline)
                            VStack(spacing: 12) {
                                Button(action: { activePopup = .T4OralInputs }) {
                                    VStack{
                                        Image("pill2")
                                        Text("Oral Dose")
                                    }
                                }
                                Button(action: { activePopup = .T4IVInputs }) {
                                    VStack{
                                        Image("syringe2")
                                        Text("IV Bolus Dose")
                                    }
                                }
                                Button(action: { activePopup = .T4InfusionInputs }) {
                                    VStack{
                                        Image("infusion2")
                                        Text("Infusion Dose")
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                
                    .padding()
                    
                    // Display sections for added doses, reading from simulationData
                    if !simulationData.t3oralinputs.isEmpty {
                        DoseDisplaySection(
                            doses: enumeratedT3Oral,
                            title: "T3-ORAL DOSE",
                            imageName: "pill1",
                            onDelete: { indexSet in simulationData.t3oralinputs.remove(atOffsets: indexSet) }
                        ) { index, t3oral in
                            DoseDetailsView(index: index, details: [
                                ("Dose (µg)", t3oral.T3OralDoseInput),
                                ("Dose Start Day or Time", t3oral.T3OralDoseStart)
                            ], conditionalDetails: !t3oral.T3SingleDose ? [
                                ("Dose End Day or Time", t3oral.T3OralDoseEnd),
                                ("Dosing Interval (days)", t3oral.T3OralDoseInterval)
                            ] : nil)
                        }
                    }

                    if !simulationData.t3ivinputs.isEmpty {
                        DoseDisplaySection(
                            doses: enumeratedT3IV,
                            title: "T3-IV DOSE",
                            imageName: "syringe1",
                            onDelete: { indexSet in simulationData.t3ivinputs.remove(atOffsets: indexSet) }
                        ) { index, t3iv in
                            DoseDetailsView(index: index, details: [
                                ("Dose (µg)", t3iv.T3IVDoseInput),
                                ("Dose Start Day or Time", t3iv.T3IVDoseStart)
                            ])
                        }
                    }

                    if !simulationData.t3infusioninputs.isEmpty {
                        DoseDisplaySection(
                            doses: enumeratedT3Infusion,
                            title: "T3-INFUSION DOSE",
                            imageName: "infusion1",
                            onDelete: { indexSet in simulationData.t3infusioninputs.remove(atOffsets: indexSet) }
                        ) { index, t3infusion in
                            DoseDetailsView(index: index, details: [
                                ("Dose (µg)", t3infusion.T3InfusionDoseInput),
                                ("Dose Start Day or Time", t3infusion.T3InfusionDoseStart),
                                ("Dose End Day or Time", t3infusion.T3InfusionDoseEnd)
                            ])
                        }
                    }

                    if !simulationData.t4oralinputs.isEmpty {
                        DoseDisplaySection(
                            doses: enumeratedT4Oral,
                            title: "T4-ORAL DOSE",
                            imageName: "pill2",
                            onDelete: { indexSet in simulationData.t4oralinputs.remove(atOffsets: indexSet) }
                        ) { index, t4oral in
                            DoseDetailsView(index: index, details: [
                                ("Dose (µg)", t4oral.T4OralDoseInput),
                                ("Dose Start Day or Time", t4oral.T4OralDoseStart)
                            ], conditionalDetails: !t4oral.T4SingleDose ? [
                                ("Dose End Day or Time", t4oral.T4OralDoseEnd),
                                ("Dosing Interval (days)", t4oral.T4OralDoseInterval)
                            ] : nil)
                        }
                    }

                    if !simulationData.t4ivinputs.isEmpty {
                        DoseDisplaySection(
                            doses: enumeratedT4IV,
                            title: "T4-IV DOSE",
                            imageName: "syringe2",
                            onDelete: { indexSet in simulationData.t4ivinputs.remove(atOffsets: indexSet) }
                        ) { index, t4iv in
                            DoseDetailsView(index: index, details: [
                                ("Dose (µg)", t4iv.T4IVDoseInput),
                                ("Dose Start Day or Time", t4iv.T4IVDoseStart)
                            ])
                        }
                    }

                    if !simulationData.t4infusioninputs.isEmpty {
                        DoseDisplaySection(
                            doses: enumeratedT4Infusion,
                            title: "T4-INFUSION DOSE",
                            imageName: "infusion2",
                            onDelete: { indexSet in simulationData.t4infusioninputs.remove(atOffsets: indexSet) }
                        ) { index, t4infusion in
                            DoseDetailsView(index: index, details: [
                                ("Dose (µg)", t4infusion.T4InfusionDoseInput),
                                ("Dose Start Day or Time", t4infusion.T4InfusionDoseStart),
                                ("Dose End Day or Time", t4infusion.T4InfusionDoseEnd)
                            ])
                        }
                    }
                    
                    Spacer().frame(height: 80)
                }
                .padding()
                .foregroundColor(.white)
            }
        }
        .background(Color.black.ignoresSafeArea())
        .sheet(item: $activePopup) { popup in
            // The sheet modifier handles showing the popups and saving the data to the shared model
            switch popup {
            case .T3OralInputs:
                T3OralPopupView { newT3Oral in simulationData.t3oralinputs.append(newT3Oral) }
            case .T3IVInputs:
                T3IVPopupView { newT3IV in simulationData.t3ivinputs.append(newT3IV) }
            case .T3InfusionInputs:
                T3InfusionPopupView { newT3Infusion in simulationData.t3infusioninputs.append(newT3Infusion) }
            case .T4OralInputs:
                T4OralPopupView { newT4Oral in simulationData.t4oralinputs.append(newT4Oral) }
            case .T4IVInputs:
                T4IVPopupView { newT4IV in simulationData.t4ivinputs.append(newT4IV) }
            case .T4InfusionInputs:
                T4InfusionPopupView { newT4Infusion in simulationData.t4infusioninputs.append(newT4Infusion) }
            }
        }
    }
}

// Helper View for displaying a section of doses
fileprivate struct DoseDisplaySection<T: Identifiable, Content: View>: View {
    let doses: [(Int, T)]
    let title: String
    let imageName: String
    let onDelete: (IndexSet) -> Void
    let content: (Int, T) -> Content

    var body: some View {
        Section {
            ForEach(doses, id: \.1.id) { index, doseData in
                content(index, doseData)
            }
            .onDelete(perform: onDelete)
        } header: {
            HStack(alignment: .center, spacing: 10) {
                Image(imageName)
                    .resizable()
                    .frame(width: 30, height: 30)
                Text(title)
                    .font(.title2.bold())
            }
        }
    }
}

// Helper View for displaying the details of a single dose
fileprivate struct DoseDetailsView: View {
    let index: Int
    let details: [(String, Float)]
    var conditionalDetails: [(String, Float)]? = nil

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Input \(index + 1):")
                    .font(.title3.bold())
                ForEach(details, id: \.0) { label, value in
                    Text("\(label): \(String(format: "%.2f", value))")
                }
                if let conditionalDetails = conditionalDetails {
                    ForEach(conditionalDetails, id: \.0) { label, value in
                        Text("\(label): \(String(format: "%.2f", value))")
                    }
                }
            }
            Spacer()
            // The trash can for deletion is now handled by the .onDelete modifier in the list
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}
