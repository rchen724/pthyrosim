//  T3OralPopupView.swift
//  iosapp
//
//  Created by Rita Chen on 5/17/25.
//

import SwiftUI

struct T3OralPopupView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var isT3Disabled = false
    @State private var T3SingleDose = false

    
    @AppStorage("T3OralDoseInput") private var T3OralDoseInput = ""
    @AppStorage("T3OralDoseStart") private var T3OralDoseStart = ""
    @AppStorage("T3OralDoseEnd") private var T3OralDoseEnd  = ""
    @AppStorage("T3OralDoseInterval") private var T3OralDoseInterval = ""
    
    @State private var inputText = ""
    @State private var showErrorPopup = false
    @State private var errorMessage = ""
    
    var onSave: (T3OralDose) -> Void

    var body: some View {
        ZStack{
            NavigationView {
                Form {
                    HStack(alignment:.center, spacing: 10) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .center, spacing: 10)
                            {
                                Image("pill1")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Text("T3-ORAL DOSE")
                                    .font(.title3.bold())
                            }
                            VStack(alignment: .leading, spacing: 40) {
                                HStack(alignment: .center) {
                                    Text("Dose (µg)")
                                        .frame(width: 150, alignment: .leading)
                                    Spacer()
                                    Step2InputField(title: "", value: $T3OralDoseInput)
                                        .multilineTextAlignment(.leading)
                                        .frame(width: 100, alignment: .trailing)
                                        .keyboardType(.decimalPad)
                                    
                                }
                                
                                HStack(alignment: .center) {
                                    Text("Dose Start Day or Time")
                                        .frame(width: 150, alignment: .leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Spacer()
                                    Step2InputField(title: "", value: $T3OralDoseStart)
                                        .multilineTextAlignment(.leading)
                                        .frame(width: 100, alignment: .trailing)
                                        .keyboardType(.decimalPad)
                                    
                                }
                                
                                HStack(alignment: .center) {
                                    Text("Use Single Dose")
                                    
                                    Toggle("turn off", isOn: $T3SingleDose)
                                        .labelsHidden()
                                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                                        .frame(width: 100, alignment: .trailing)
                                }
                                
                                if !T3SingleDose {
                                    HStack(alignment: .firstTextBaseline) {
                                        VStack(alignment: .leading, spacing: 10) {
                                            Text("Dosing Interval (days)")
                                                .frame(width: 150, alignment: .leading)
                                                .fixedSize(horizontal: false, vertical: true)
                                            Text("E.g. 1, if daily dosing, 0.5 if twice-daily dosing, etc")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                                .frame(width: 150, alignment: .trailing)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                        Spacer()
                                        Step2InputField(title: "", value: $T3OralDoseInterval)
                                            .multilineTextAlignment(.leading)
                                            .frame(width: 100, alignment: .trailing)
                                            .keyboardType(.decimalPad)
                                    }
                                    HStack(alignment: .firstTextBaseline) {
                                        VStack(alignment: .leading, spacing: 10) {
                                            Text("Dose End Day or Time")
                                                .frame(width: 150, alignment: .leading)
                                            Text("E.g. Start (or End) dosing on Day 3, or Day 0.5 or Day 2.8 etc.")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                                .frame(width: 150, alignment: .trailing)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                        Spacer()
                                        Step2InputField(title: "", value: $T3OralDoseEnd)
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
                .navigationTitle("Add T3 Oral Dose")
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
                    ErrorPopup(message: errorMessage) {
                        showErrorPopup = false
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear) // Ensure it takes full space
                .edgesIgnoringSafeArea(.all)
                .zIndex(1) // Put it on top of everything
            }
        }
    }
    
    
    func inputValidation() {
        let trimmedt3oralinput = T3OralDoseInput.trimmingCharacters(in: .whitespaces)
        let trimmedt3oralstart = T3OralDoseStart.trimmingCharacters(in: .whitespaces)
        let trimmedt3oralend = T3OralDoseEnd.trimmingCharacters(in: .whitespaces)
        let trimmedt3oralinterval = T3OralDoseInterval.trimmingCharacters(in: .whitespaces)
        
        var singledose  = true
        var t3_end: Float = 0
        var t3_interval: Float = 0
        
        guard !trimmedt3oralinput.isEmpty else {
            showError("Dosage is required.")
            return
        }
        
        guard let t3oraldose = Float(trimmedt3oralinput), t3oraldose > 0 else {
            showError("Dosage must be a valid number greater than 0.")
            return
        }

        guard !trimmedt3oralstart.isEmpty else {
            showError("Start time is required.")
            return
        }
        
        guard let t3oralstart = Float(trimmedt3oralstart), t3oralstart > 0 else {
            showError("Start time must be a valid number greater than 0.")
            return
        }

        
        if !T3SingleDose {
            guard !trimmedt3oralend.isEmpty else {
                showError("End time is required if not using single dose.")
                return
            }
            
            guard let t3oralend = Float(trimmedt3oralend), t3oralend > 0 else {
                showError("End time must be a valid number greater than 0.")
                return
            }
            t3_end = t3oralend
            
            guard !trimmedt3oralinterval.isEmpty else {
                showError("Interval is required if not using single dose.")
                return
            }
            
            guard let t3oralinterval = Float(trimmedt3oralinterval), t3oralinterval > 0 else {
                showError("Interval must be a valid number greater than 0.")
                return
            }
            t3_interval = t3oralinterval
            singledose = false
            
        }

        let newT3OralInput = T3OralDose(T3OralDoseInput: t3oraldose, T3OralDoseStart: t3oralstart, T3OralDoseEnd: t3_end, T3OralDoseInterval: t3_interval, T3SingleDose: singledose)
        // validated
        onSave(newT3OralInput)
        dismiss()
        func showError(_ message: String) {
            errorMessage = message
            showErrorPopup = true
        }
    }
        
}




