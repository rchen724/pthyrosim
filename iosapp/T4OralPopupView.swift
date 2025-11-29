//
//  T4OralPopupView.swift
//  iosapp
//
//  Created by Rita Chen on 5/17/25.
//

import SwiftUI

struct T4OralPopupView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var isT4Disabled = false
    @State private var T4SingleDose = false

    
    @AppStorage("T4OralDoseInput") private var T4OralDoseInput = ""
    @AppStorage("T4OralDoseStart") private var T4OralDoseStart = ""
    @AppStorage("T4OralDoseEnd") private var T4OralDoseEnd  = ""
    @AppStorage("T4OralDoseInterval") private var T4OralDoseInterval = ""
    
    @State private var inputText = ""
    @State private var showErrorPopup = false
    @State private var errorMessage = ""
    
    var onSave: (T4OralDose) -> Void

    var body: some View {
        ZStack{
            NavigationView {
                Form {
                    HStack(alignment:.center, spacing: 10) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .center, spacing: 10)
                            {
                                Image("pill2")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Text("T4-ORAL DOSE")
                                    .font(.title3.bold())
                            }
                            VStack(alignment: .leading, spacing: 40) {
                                HStack(alignment: .center) {
                                    Text("Dose (µg)")
                                        .frame(width: 150, alignment: .leading)
                                    Spacer()
                                    Step2InputField(title: "", value: $T4OralDoseInput)
                                        .multilineTextAlignment(.leading)
                                        .frame(width: 100, alignment: .trailing)
                                        .keyboardType(.decimalPad)
                                    
                                }
                                
                                HStack(alignment: .center) {
                                    Text("Dose Start Day or Time")
                                        .frame(width: 150, alignment: .leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Spacer()
                                    Step2InputField(title: "", value: $T4OralDoseStart)
                                        .multilineTextAlignment(.leading)
                                        .frame(width: 100, alignment: .trailing)
                                        .keyboardType(.decimalPad)
                                    
                                }
                                
                                HStack(alignment: .center) {
                                    
                                    Toggle("Single Dose", isOn: $T4SingleDose)
                                        .frame(width: 150, alignment: .leading)
                                    
                                }
                                
                                if !T4SingleDose {
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
                                        Step2InputField(title: "", value: $T4OralDoseEnd)
                                            .multilineTextAlignment(.leading)
                                            .frame(width: 100, alignment: .trailing)
                                            .keyboardType(.decimalPad)
                                    }
                                    HStack(alignment: .firstTextBaseline) {
                                        VStack(alignment: .leading, spacing: 10) {
                                            Text("Dosing Interval (days)")
                                                .frame(width: 150, alignment: .leading)
                                                .fixedSize(horizontal: false, vertical: true)
                                            Text("e.g. 1, if daily dosing, 0.5 if twice-daily dosing, etc")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                                .frame(width: 150, alignment: .trailing)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                        Spacer()
                                        Step2InputField(title: "", value: $T4OralDoseInterval)
                                            .multilineTextAlignment(.leading)
                                            .frame(width: 100, alignment: .trailing)
                                            .keyboardType(.decimalPad)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
                .scrollContentBackground(.hidden)
                .background(Color.black.edgesIgnoringSafeArea(.all))
                .navigationTitle("Add T4 Oral Dose")
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
        let trimmedt4oralinput = T4OralDoseInput.trimmingCharacters(in: .whitespaces)
        let trimmedt4oralstart = T4OralDoseStart.trimmingCharacters(in: .whitespaces)
        let trimmedt4oralend = T4OralDoseEnd.trimmingCharacters(in: .whitespaces)
        let trimmedt4oralinterval = T4OralDoseInterval.trimmingCharacters(in: .whitespaces)
        
        var singledose = true
        var t4_end: Float = 0
        var t4_interval: Float = 0
        
        guard !trimmedt4oralinput.isEmpty else {
            showError("Dosage is required.")
            return
        }
        
        guard let t4oraldose = Float(trimmedt4oralinput), t4oraldose > 0 else {
            showError("Dosage must be a valid number greater than 0.")
            return
        }

        guard !trimmedt4oralstart.isEmpty else {
            showError("Start time is required.")
            return
        }
        
        guard let t4oralstart = Float(trimmedt4oralstart), t4oralstart > 0 else {
            showError("Start time must be a valid number greater than 0.")
            return
        }

        
        if !T4SingleDose {
            guard !trimmedt4oralend.isEmpty else {
                showError("End time is required if not using single dose.")
                return
            }
            
            guard let t4oralend = Float(trimmedt4oralend), t4oralend > 0 else {
                showError("End time must be a valid number greater than 0.")
                return
            }
            t4_end = t4oralend
            
            guard !trimmedt4oralinterval.isEmpty else {
                showError("Interval is required if not using single dose.")
                return
            }
            
            guard let t4oralinterval = Float(trimmedt4oralinterval), t4oralinterval > 0 else {
                showError("Interval must be a valid number greater than 0.")
                return
            }
            
            t4_interval = t4oralinterval
            singledose = false
            
        }

        let newT4OralInput = T4OralDose(T4OralDoseInput: t4oraldose, T4OralDoseStart: t4oralstart, T4OralDoseEnd: t4_end, T4OralDoseInterval: t4_interval, T4SingleDose: singledose)
        // validated
        onSave(newT4OralInput)
        dismiss()
    }
    
    func showError(_ message: String) {
        errorMessage = message
        showErrorPopup = true
    }
        
}


