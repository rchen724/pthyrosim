//
//  T4InfusionPopupView.swift
//  iosapp
//
//  Created by Rita Chen on 5/17/25.
//

import SwiftUI

struct T4InfusionPopupView: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("T4InfusionDoseInput") private var T4InfusionDoseInput: String = ""
    @AppStorage("T4InfusionDoseStart") private var T4InfusionDoseStart: String = ""
    @AppStorage("T4InfusionDoseEnd") private var T4InfusionDoseEnd: String = ""
    
    @State private var inputText = ""
    @State private var showErrorPopup = false
    @State private var errorMessage = ""
    
    var doseToEdit: T4InfusionDose?
    var onSave: (T4InfusionDose)-> Void
    
    init(doseToEdit: T4InfusionDose? = nil, onSave: @escaping (T4InfusionDose)-> Void) {
        self.doseToEdit = doseToEdit
        self.onSave = onSave
        
        if let dose = doseToEdit {
            _T4InfusionDoseInput = AppStorage(wrappedValue: String(format: "%.1f", dose.T4InfusionDoseInput), "T4InfusionDoseInput")
            _T4InfusionDoseStart = AppStorage(wrappedValue: String(format: "%.1f", dose.T4InfusionDoseStart), "T4InfusionDoseStart")
            _T4InfusionDoseEnd = AppStorage(wrappedValue: String(format: "%.1f", dose.T4InfusionDoseEnd), "T4InfusionDoseEnd")
        }
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                Form {
                    HStack(alignment: .center, spacing: 10) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .center)
                            {
                                Image("infusion2")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Text("T4-INFUSION DOSE")
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
                                Text("Save Before Running")
                                    .font(.headline)
                                
                            }
                        }

                    }
                    .padding()
                }
                .scrollContentBackground(.hidden)
                .background(Color.black.edgesIgnoringSafeArea(.all))
                .navigationTitle("Add T4 Infusion Dose")
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
        let trimmedt4infusioninput = T4InfusionDoseInput.trimmingCharacters(in: .whitespaces)
        let trimmedt4infusionstart = T4InfusionDoseStart.trimmingCharacters(in: .whitespaces)
        let trimmedt4infusionend = T4InfusionDoseEnd.trimmingCharacters(in: .whitespaces)

        
        guard !trimmedt4infusioninput.isEmpty else {
            showError("Dosage is required.")
            return
        }
        
        guard let t4infusiondose = Float(trimmedt4infusioninput), t4infusiondose > 0 else {
            showError("Dosage must be a valid number greater than 0.")
            return
        }

        guard !trimmedt4infusionstart.isEmpty else {
            showError("Start time is required.")
            return
        }
        
        guard let t4infusionstart = Float(trimmedt4infusionstart), t4infusionstart > 0 else {
            showError("Start time must be a valid number greater than 0.")
            return
        }
        guard !trimmedt4infusionend.isEmpty else {
            showError("End time is required if not using single dose.")
            return
        }
        guard let t4infusionend = Float(trimmedt4infusionend), t4infusionend > 0 else {
            showError("End time must be a valid number greater than 0.")
            return
        }

        let newT4InfusionInput = T4InfusionDose(T4InfusionDoseInput: t4infusiondose, T4InfusionDoseStart: t4infusionstart, T4InfusionDoseEnd: t4infusionend)
        // validated
        onSave(newT4InfusionInput)
        dismiss()
    }
    
    func showError(_ message: String) {
        errorMessage = message
        showErrorPopup = true
    }
}



