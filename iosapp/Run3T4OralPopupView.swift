//  Run3T4OralPopupView.swift
//  iosapp
//
//  Created for Run3 dose input
//

import SwiftUI

struct Run3T4OralPopupView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var isT4Disabled = false
    @State private var T4SingleDose = false

    
    @AppStorage("Run3T4OralDoseInput") private var T4OralDoseInput = ""
    @AppStorage("Run3T4OralDoseStart") private var T4OralDoseStart = ""
    @AppStorage("Run3T4OralDoseEnd") private var T4OralDoseEnd  = ""
    @AppStorage("Run3T4OralDoseInterval") private var T4OralDoseInterval = ""
    
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
                                Text("T4-ORAL DOSE (Run 3)")
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
                                        Step2InputField(title: "", value: $T4OralDoseEnd)
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
                .navigationTitle("Add T4 Oral Dose (Run 3)")
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
        guard let doseInput = Double(T4OralDoseInput), doseInput > 0 else {
            errorMessage = "Please enter a valid dose amount."
            showErrorPopup = true
            return
        }
        
        guard let doseStart = Double(T4OralDoseStart), doseStart >= 0 else {
            errorMessage = "Please enter a valid start time."
            showErrorPopup = true
            return
        }
        
        if !T4SingleDose {
            guard let doseEnd = Double(T4OralDoseEnd), doseEnd > doseStart else {
                errorMessage = "Please enter a valid end time greater than start time."
                showErrorPopup = true
                return
            }
            
            guard let doseInterval = Double(T4OralDoseInterval), doseInterval > 0 else {
                errorMessage = "Please enter a valid dosing interval."
                showErrorPopup = true
                return
            }
        }
        
        let dose = T4OralDose(
            T4OralDoseInput: Float(doseInput),
            T4OralDoseStart: Float(doseStart),
            T4OralDoseEnd: T4SingleDose ? 0 : Float(T4OralDoseEnd) ?? 0,
            T4OralDoseInterval: T4SingleDose ? 0 : Float(T4OralDoseInterval) ?? 0,
            T4SingleDose: T4SingleDose
        )
        
        onSave(dose)
        dismiss()
    }
}
