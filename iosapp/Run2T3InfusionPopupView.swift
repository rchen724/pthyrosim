//  Run2T3InfusionPopupView.swift
//  iosapp
//
//  Created for Run3 dose input
//

import SwiftUI

struct Run2T3InfusionPopupView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("selectedMainTab") private var selectedTab: Int = 0
    
    @AppStorage("Run2T3InfusionDoseInput") private var T3InfusionDoseInput = ""
    @AppStorage("Run2T3InfusionDoseStart") private var T3InfusionDoseStart = ""
    @AppStorage("Run2T3InfusionDoseEnd") private var T3InfusionDoseEnd = ""
    
    @State private var showErrorPopup = false
    @State private var errorMessage = ""
    
    var onSave: (T3InfusionDose) -> Void

    var body: some View {
        ZStack{
            NavigationView {
                Form {
                    HStack(alignment:.center, spacing: 10) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .center, spacing: 10)
                            {
                                Image("infusion1")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Text("T3-INFUSION DOSE (Run 2)")
                                    .font(.title3.bold())
                            }
                            VStack(alignment: .leading, spacing: 30) {
                                HStack(alignment: .center) {
                                    Text("Dose (µg)")
                                        .frame(width: 150, alignment: .leading)
                                    Spacer()
                                    Step2InputField(title: "", value: $T3InfusionDoseInput)
                                        .multilineTextAlignment(.leading)
                                        .frame(width: 100, alignment: .trailing)
                                }
                                
                                HStack(alignment: .center) {
                                    Text("Dose Start Day or Time")
                                        .frame(width: 150, alignment: .leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Spacer()
                                    Step2InputField(title: "", value: $T3InfusionDoseStart)
                                        .multilineTextAlignment(.leading)
                                        .frame(width: 100, alignment: .trailing)
                                    
                                }
                                HStack(alignment: .firstTextBaseline) {
                                    Text("Dose End Day or Time")
                                        .frame(width: 150, alignment: .leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Spacer()
                                    Step2InputField(title: "", value: $T3InfusionDoseEnd)
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
                .navigationTitle("Add T3 Infusion Dose (Run 2)")
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
        guard let doseInput = Double(T3InfusionDoseInput), doseInput > 0 else {
            errorMessage = "Please enter a valid dose amount."
            showErrorPopup = true
            return
        }
        
        guard let doseStart = Double(T3InfusionDoseStart), doseStart >= 0 else {
            errorMessage = "Please enter a valid start time."
            showErrorPopup = true
            return
        }
        
        guard let doseEnd = Double(T3InfusionDoseEnd), doseEnd > doseStart else {
            errorMessage = "Please enter a valid end time greater than start time."
            showErrorPopup = true
            return
        }
        
        let dose = T3InfusionDose(
            T3InfusionDoseInput: Float(doseInput),
            T3InfusionDoseStart: Float(doseStart),
            T3InfusionDoseEnd: Float(doseEnd)
        )
        
        onSave(dose)
        dismiss()
    }
}
