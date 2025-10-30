//  Run2T3OralPopupView.swift
//  iosapp
//
//  Created for Run2 dose input
//

import SwiftUI

struct Run2T3OralPopupView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var isT3Disabled = false
    @State private var T3SingleDose = false

    
    @AppStorage("Run2T3OralDoseInput") private var T3OralDoseInput = ""
    @AppStorage("Run2T3OralDoseStart") private var T3OralDoseStart = ""
    @AppStorage("Run2T3OralDoseEnd") private var T3OralDoseEnd  = ""
    @AppStorage("Run2T3OralDoseInterval") private var T3OralDoseInterval = ""
    
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
                                Text("T3-ORAL DOSE (Run 2)")
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
                                    
                                    Toggle("Single Dose", isOn: $T3SingleDose)
                                        .frame(width: 150, alignment: .leading)
                                    
                                }
                                
                                if !T3SingleDose {
                                    HStack(alignment: .center) {
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
                                        Step2InputField(title: "", value: $T3OralDoseEnd)
                                            .multilineTextAlignment(.leading)
                                            .frame(width: 100, alignment: .trailing)
                                            .keyboardType(.decimalPad)
                                        
                                    }
                                    
                                    HStack(alignment: .center) {
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
                                        Step2InputField(title: "", value: $T3OralDoseInterval)
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
                .navigationTitle("Add T3 Oral Dose (Run 2)")
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
        guard let doseInput = Double(T3OralDoseInput), doseInput > 0 else {
            errorMessage = "Please enter a valid dose amount."
            showErrorPopup = true
            return
        }
        
        guard let doseStart = Double(T3OralDoseStart), doseStart >= 0 else {
            errorMessage = "Please enter a valid start time."
            showErrorPopup = true
            return
        }
        
        if !T3SingleDose {
            guard let doseEnd = Double(T3OralDoseEnd), doseEnd > doseStart else {
                errorMessage = "Please enter a valid end time greater than start time."
                showErrorPopup = true
                return
            }
            
            guard let doseInterval = Double(T3OralDoseInterval), doseInterval > 0 else {
                errorMessage = "Please enter a valid dosing interval."
                showErrorPopup = true
                return
            }
        }
        
        let dose = T3OralDose(
            T3OralDoseInput: Float(doseInput),
            T3OralDoseStart: Float(doseStart),
            T3OralDoseEnd: T3SingleDose ? 0 : Float(T3OralDoseEnd) ?? 0,
            T3OralDoseInterval: T3SingleDose ? 0 : Float(T3OralDoseInterval) ?? 0,
            T3SingleDose: T3SingleDose
        )
        
        onSave(dose)
        dismiss()
    }
}
