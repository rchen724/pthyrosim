//
//  T4IVPopupView.swift
//  iosapp
//
//  Created by Rita Chen on 5/17/25.
//

import SwiftUI

struct T4IVPopupView: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("T4IVDoseInput") private var T4IVDoseInput: String = ""
    @AppStorage("T4IVDoseStart") private var T4IVDoseStart: String = ""
    
    @State private var inputText = ""
    @State private var showErrorPopup = false
    @State private var errorMessage = ""
    
    var doseToEdit: T4IVDose?
        var onSave: (T4IVDose)-> Void
        
        init(doseToEdit: T4IVDose? = nil, onSave: @escaping (T4IVDose)-> Void) {
            self.doseToEdit = doseToEdit
            self.onSave = onSave
            
            if let dose = doseToEdit {
                _T4IVDoseInput = AppStorage(wrappedValue: String(format: "%.1f", dose.T4IVDoseInput), "T4IVDoseInput")
                _T4IVDoseStart = AppStorage(wrappedValue: String(format: "%.1f", dose.T4IVDoseStart), "T4IVDoseStart")
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
                                Image("syringe2")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Text("T4-IV DOSE")
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
                .navigationTitle("Add T4 IV Dose")
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
        let trimmedt4ivinput = T4IVDoseInput.trimmingCharacters(in: .whitespaces)
        let trimmedt4ivstart = T4IVDoseStart.trimmingCharacters(in: .whitespaces)
        
        guard !trimmedt4ivinput.isEmpty else {
            showError("Dosage is required.")
            return
        }
        
        guard let t4ivdose = Float(trimmedt4ivinput), t4ivdose > 0 else {
            showError("Dosage must be a valid number greater than 0.")
            return
        }

        guard !trimmedt4ivstart.isEmpty else {
            showError("Start time is required.")
            return
        }
        
        guard let t4ivstart = Float(trimmedt4ivstart), t4ivstart > 0 else {
            showError("Start time must be a valid number greater than 0.")
            return
        }

        let newT4IVInput = T4IVDose(T4IVDoseInput: t4ivdose, T4IVDoseStart: t4ivstart)
        // validated
        onSave(newT4IVInput)
        dismiss()
    }
    
    func showError(_ message: String) {
        errorMessage = message
        showErrorPopup = true
    }
}
