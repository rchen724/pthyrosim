//  Run3T3IVPopupView.swift
//  iosapp
//
//  Created for Run3 dose input
//

import SwiftUI

struct Run3T3IVPopupView: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("Run3T3IVDoseInput") private var T3IVDoseInput = ""
    @AppStorage("Run3T3IVDoseStart") private var T3IVDoseStart = ""
    
    @State private var showErrorPopup = false
    @State private var errorMessage = ""
    
    var onSave: (T3IVDose) -> Void

    var body: some View {
        ZStack{
            NavigationView {
                Form {
                    HStack(alignment:.center, spacing: 10) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .center, spacing: 10)
                            {
                                Image("syringe1")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Text("T3-IV DOSE (Run 3)")
                                    .font(.title3.bold())
                            }
                            VStack(alignment: .leading, spacing: 30) {
                                HStack(alignment: .center) {
                                    Text("Dose (µg)")
                                        .frame(width: 150, alignment: .leading)
                                    Spacer()
                                    Step2InputField(title: "", value: $T3IVDoseInput)
                                        .multilineTextAlignment(.leading)
                                        .frame(width: 100, alignment: .trailing)
                                }
                                
                                HStack(alignment: .center) {
                                    Text("Dose Start Day or Time")
                                        .frame(width: 150, alignment: .leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Spacer()
                                    Step2InputField(title: "", value: $T3IVDoseStart)
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
                .navigationTitle("Add T3 IV Dose (Run 3)")
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
        guard let doseInput = Double(T3IVDoseInput), doseInput > 0 else {
            errorMessage = "Please enter a valid dose amount."
            showErrorPopup = true
            return
        }
        
        guard let doseStart = Double(T3IVDoseStart), doseStart >= 0 else {
            errorMessage = "Please enter a valid start time."
            showErrorPopup = true
            return
        }
        
        let dose = T3IVDose(
            T3IVDoseInput: Float(doseInput),
            T3IVDoseStart: Float(doseStart)
        )
        
        onSave(dose)
        dismiss()
    }
}
