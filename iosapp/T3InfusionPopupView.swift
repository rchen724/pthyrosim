//
//  T3InfusionPopupView.swift
//  iosapp
//
//  Created by Rita Chen on 5/17/25.
//

import SwiftUI

struct T3InfusionPopupView: View {
    @Environment(\.dismiss) var dismiss
    
        @State private var T3InfusionDoseInput: String = ""
        @State private var T3InfusionDoseStart: String = ""
        @State private var T3InfusionDoseEnd: String = ""
        
        @State private var inputText = ""
        @State private var showErrorPopup = false
        @State private var errorMessage = ""
        
            var doseToEdit: T3InfusionDose?
            var onSave: (T3InfusionDose)-> Void
        
            init(doseToEdit: T3InfusionDose? = nil, onSave: @escaping (T3InfusionDose) -> Void) {
                self.doseToEdit = doseToEdit
                self.onSave = onSave
            }
            
            var body: some View {            ZStack {
                NavigationView {
                    Form {
                        HStack(alignment: .center, spacing: 10) {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(alignment: .center)
                                {
                                    Image("infusion1")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                    Text("T3-INFUSION DOSE")
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
                                        Step2InputField(title: "", value: $T3InfusionDoseEnd)
                                            .multilineTextAlignment(.leading)
                                            .frame(width: 100, alignment: .trailing)
                                    }
        
                                    Text("Save Before Running")
                                        .font(.headline)
    
                                    
                                }
                            }
    
                        }
                        .padding()
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.black.edgesIgnoringSafeArea(.all))
                    .navigationTitle(doseToEdit != nil ? "Edit T3 Infusion Dose" : "Add T3 Infusion Dose")
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
            .onAppear(perform: setupInitialValues)
        }
        
        private func setupInitialValues() {
            if let dose = doseToEdit {
                T3InfusionDoseInput = String(format: "%.1f", dose.T3InfusionDoseInput)
                T3InfusionDoseStart = String(format: "%.1f", dose.T3InfusionDoseStart)
                T3InfusionDoseEnd = String(format: "%.1f", dose.T3InfusionDoseEnd)
            }
        }    
    func inputValidation() {
        let trimmedt3infusioninput = T3InfusionDoseInput.trimmingCharacters(in: .whitespaces)
        let trimmedt3infusionstart = T3InfusionDoseStart.trimmingCharacters(in: .whitespaces)
        let trimmedt3infusionend = T3InfusionDoseEnd.trimmingCharacters(in: .whitespaces)

        
        guard !trimmedt3infusioninput.isEmpty else {
            showError("Dosage is required.")
            return
        }
        
        guard let t3infusiondose = Float(trimmedt3infusioninput), t3infusiondose > 0 else {
            showError("Dosage must be a valid number greater than 0.")
            return
        }

        guard !trimmedt3infusionstart.isEmpty else {
            showError("Start time is required.")
            return
        }
        
        guard let t3infusionstart = Float(trimmedt3infusionstart), t3infusionstart > 0 else {
            showError("Start time must be a valid number greater than 0.")
            return
        }
        guard !trimmedt3infusionend.isEmpty else {
            showError("End time is required if not using single dose.")
            return
        }
        guard let t3infusionend = Float(trimmedt3infusionend), t3infusionend > 0 else {
            showError("End time must be a valid number greater than 0.")
            return
        }

        let newT3InfusionInput = T3InfusionDose(T3InfusionDoseInput: t3infusiondose, T3InfusionDoseStart: t3infusionstart, T3InfusionDoseEnd: t3infusionend)
        // validated
        onSave(newT3InfusionInput)
        dismiss()
    }
    
    func showError(_ message: String) {
        errorMessage = message
        showErrorPopup = true
    }
}
