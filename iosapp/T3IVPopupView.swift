//
//  T3IVPopupView.swift
//  iosapp
//
//  Created by Rita Chen on 5/17/25.
//

import SwiftUI

struct T3IVPopupView: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("T3IVDoseInput") private var T3IVDoseInput: String = ""
    @AppStorage("T3IVDoseStart") private var T3IVDoseStart: String = ""
    
    @State private var inputText = ""
    @State private var showErrorPopup = false
    @State private var errorMessage = ""
    
    var onSave: (T3IVDose)-> Void
    
    var body: some View {
        ZStack {
            NavigationView {
                Form {
                    HStack(alignment: .center, spacing: 10) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .center)
                            {
                                Image("syringe1")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Text("T3-IV DOSE")
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
                .navigationTitle("Add T3 IV Dose")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            inputValidation()
                        }
                    }
                }
                .toolbarBackground(Color.black, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
            }
            if showErrorPopup {
                ZStack {
                    // Dimmed background that covers entire screen
                    Color.black.opacity(0.8)
                        .ignoresSafeArea()
                    
                    // Popup itself
                    ErrorPopup(message: errorMessage, onDismiss: {
                        showErrorPopup = false
                    })
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear) // Ensure it takes full space
                .edgesIgnoringSafeArea(.all)
                .zIndex(1) // Put it on top of everything
            }
        }
    }
    func inputValidation() {
        let trimmedt3ivinput = T3IVDoseInput.trimmingCharacters(in: .whitespaces)
        let trimmedt3ivstart = T3IVDoseStart.trimmingCharacters(in: .whitespaces)
        
        guard !trimmedt3ivinput.isEmpty else {
            showError("Dosage is required.")
            return
        }
        
        guard let t3ivdose = Float(trimmedt3ivinput), t3ivdose > 0 else {
            showError("Dosage must be a valid number greater than 0.")
            return
        }

        guard !trimmedt3ivstart.isEmpty else {
            showError("Start time is required.")
            return
        }
        
        guard let t3ivstart = Float(trimmedt3ivstart), t3ivstart > 0 else {
            showError("Start time must be a valid number greater than 0.")
            return
        }

        let newT3IVInput = T3IVDose(T3IVDoseInput: t3ivdose, T3IVDoseStart: t3ivstart)
        // validated
        onSave(newT3IVInput)
        dismiss()
    }
    
    func showError(_ message: String) {
        errorMessage = message
        showErrorPopup = true
    }
}


