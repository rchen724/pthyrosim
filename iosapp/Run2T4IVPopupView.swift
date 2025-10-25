//  Run2T4IVPopupView.swift
//  iosapp
//
//  Created for Run2 dose input
//

import SwiftUI

struct Run2T4IVPopupView: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("Run2T4IVDoseInput") private var T4IVDoseInput = ""
    @AppStorage("Run2T4IVDoseStart") private var T4IVDoseStart = ""
    
    @State private var showErrorPopup = false
    @State private var errorMessage = ""
    
    var onSave: (T4IVDose) -> Void

    var body: some View {
        ZStack{
            NavigationView {
                Form {
                    HStack(alignment:.center, spacing: 10) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .center, spacing: 10)
                            {
                                Image("syringe2")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Text("T4-IV DOSE (Run 2)")
                                    .font(.title3.bold())
                            }
                            VStack(alignment: .leading, spacing: 30) {
                                HStack(alignment: .center) {
                                    Text("Dose (µg)")
                                        .frame(width: 150, alignment: .leading)
                                    Spacer()
                                    Step2InputField(title: "", value: $T4IVDoseInput)
                                        .multilineTextAlignment(.leading)
                                        .frame(width: 100, alignment: .trailing)
                                }
                                
                                HStack(alignment: .center) {
                                    Text("Dose Start Day or Time")
                                        .frame(width: 150, alignment: .leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Spacer()
                                    Step2InputField(title: "", value: $T4IVDoseStart)
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
                .navigationTitle("Add T4 IV Dose (Run 2)")
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
        guard let doseInput = Double(T4IVDoseInput), doseInput > 0 else {
            errorMessage = "Please enter a valid dose amount."
            showErrorPopup = true
            return
        }
        
        guard let doseStart = Double(T4IVDoseStart), doseStart >= 0 else {
            errorMessage = "Please enter a valid start time."
            showErrorPopup = true
            return
        }
        
        let dose = T4IVDose(
            T4IVDoseInput: Float(doseInput),
            T4IVDoseStart: Float(doseStart)
        )
        
        onSave(dose)
        dismiss()
    }
}
