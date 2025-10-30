//  Run2T4InfusionPopupView.swift
//  iosapp
//
//  Created for Run2 dose input
//

import SwiftUI

struct Run2T4InfusionPopupView: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("Run2T4InfusionDoseInput") private var T4InfusionDoseInput = ""
    @AppStorage("Run2T4InfusionDoseStart") private var T4InfusionDoseStart = ""
    @AppStorage("Run2T4InfusionDoseEnd") private var T4InfusionDoseEnd = ""
    
    @State private var showErrorPopup = false
    @State private var errorMessage = ""
    
    var onSave: (T4InfusionDose) -> Void

    var body: some View {
        ZStack{
            NavigationView {
                Form {
                    HStack(alignment:.center, spacing: 10) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .center, spacing: 10)
                            {
                                Image("infusion2")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Text("T4-INFUSION DOSE (Run 2)")
                                    .font(.title3.bold())
                            }
                            VStack(alignment: .leading, spacing: 30) {
                                HStack(alignment: .center) {
                                    Text("Dose (µg)")
                                        .frame(width: 150, alignment: .leading)
                                    Spacer()
                                    Step2InputField(title: "", value: $T4InfusionDoseInput)
                                        .multilineTextAlignment(.leading)
                                        .frame(width: 100, alignment: .trailing)
                                }
                                
                                HStack(alignment: .center) {
                                    Text("Dose Start Day or Time")
                                        .frame(width: 150, alignment: .leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Spacer()
                                    Step2InputField(title: "", value: $T4InfusionDoseStart)
                                        .multilineTextAlignment(.leading)
                                        .frame(width: 100, alignment: .trailing)
                                    
                                }
                                HStack(alignment: .firstTextBaseline) {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("Dose End Day or Time")
                                            .frame(width: 150, alignment: .leading)

                                        Text("e.g. Start (or End) dosing on Day 3, or Day 0.5 or Day 2.8 etc.")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .frame(width: 150, alignment: .trailing)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    Spacer()
                                    Step2InputField(title: "", value: $T4InfusionDoseEnd)
                                        .multilineTextAlignment(.leading)
                                        .frame(width: 100, alignment: .trailing)
                                    
                                }
                                
                            }
                        }

                    }
                    .padding()
                }
                .scrollContentBackground(.hidden)
                .background(Color.black.edgesIgnoringSafeArea(.all))
                .navigationTitle("Add T4 Infusion Dose (Run 2)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.white)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            saveDose()
                        }
                        .foregroundColor(.white)
                    }
                }
            }
        }
        .alert("Error", isPresented: $showErrorPopup) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func saveDose() {
        guard let doseInput = Double(T4InfusionDoseInput), doseInput > 0 else {
            errorMessage = "Please enter a valid dose amount."
            showErrorPopup = true
            return
        }
        
        guard let doseStart = Double(T4InfusionDoseStart), doseStart >= 0 else {
            errorMessage = "Please enter a valid start time."
            showErrorPopup = true
            return
        }
        
        guard let doseEnd = Double(T4InfusionDoseEnd), doseEnd > doseStart else {
            errorMessage = "Please enter a valid end time greater than start time."
            showErrorPopup = true
            return
        }
        
        let dose = T4InfusionDose(
            T4InfusionDoseInput: Float(doseInput),
            T4InfusionDoseStart: Float(doseStart),
            T4InfusionDoseEnd: Float(doseEnd)
        )
        
        onSave(dose)
        dismiss()
    }
}
