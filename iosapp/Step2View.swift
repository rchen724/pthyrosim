//
//  Step2.swift
//  iosapp
//
//  Created by Rita Chen on 5/17/25.
//

import Foundation
import SwiftUI

struct T3OralDose: Identifiable {
    let id = UUID()
    let T3OralDoseInput: Float
    let T3OralDoseStart: Float
    let T3OralDoseEnd: Float
    let T3OralDoseInterval: Float
    let T3SingleDose: Bool
}

struct T3IVDose: Identifiable {
    let id = UUID()
    let T3IVDoseInput: Float
    let T3IVDoseStart: Float
}

struct T3InfusionDose: Identifiable {
    let id = UUID()
    let T3InfusionDoseInput: Float
    let T3InfusionDoseStart: Float
    let T3InfusionDoseEnd: Float
}

struct T4OralDose: Identifiable {
    let id = UUID()
    let T4OralDoseInput: Float
    let T4OralDoseStart: Float
    let T4OralDoseEnd: Float
    let T4OralDoseInterval: Float
    let T4SingleDose: Bool
}

struct T4IVDose: Identifiable {
    let id = UUID()
    let T4IVDoseInput: Float
    let T4IVDoseStart: Float
}

struct T4InfusionDose: Identifiable {
    let id = UUID()
    let T4InfusionDoseInput: Float
    let T4InfusionDoseStart: Float
    let T4InfusionDoseEnd: Float
}

enum ActivePopup: Identifiable {
    case T3OralInputs
    case T3IVInputs
    case T3InfusionInputs
    case T4OralInputs
    case T4IVInputs
    case T4InfusionInputs
    
    var id: Int {
        hashValue
    }
}

struct Step2View: View {
    @State private var activePopup: ActivePopup? = nil
    @State private var selectedT3input: T3OralDose? = nil
    
    @State private var t3oralinputs: [T3OralDose] = []
    @State private var t3ivinputs: [T3IVDose] = []
    @State private var t3infusioninputs: [T3InfusionDose] = []
    
    @State private var t4oralinputs: [T4OralDose] = []
    @State private var t4ivinputs: [T4IVDose] = []
    @State private var t4infusioninputs: [T4InfusionDose] = []
    
    var enumeratedT3Oral: [(Int, T3OralDose)] {
        Array(t3oralinputs.enumerated())
    }
    
    var enumeratedT3IV: [(Int, T3IVDose)] {
        Array(t3ivinputs.enumerated())
    }
    
    var enumeratedT3Infusion: [(Int, T3InfusionDose)] {
        Array(t3infusioninputs.enumerated())
    }
    
    var enumeratedT4Oral: [(Int, T4OralDose)] {
        Array(t4oralinputs.enumerated())
    }
    
    var enumeratedT4IV: [(Int, T4IVDose)] {
        Array(t4ivinputs.enumerated())
    }
    
    var enumeratedT4Infusion: [(Int, T4InfusionDose)] {
        Array(t4infusioninputs.enumerated())
    }
    
    var body: some View {
        ZStack{
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Do Simulated Dosing Experiment")
                        .font(.title2.bold())
                    
                    Text("How: T3 and/or T4 input dosing can be chosen as oral doses; OR intravenous (IV) bolus doses; OR infusion doses.")
                        .font(.body)
                        .foregroundColor(.gray)
                    
                    HStack(alignment: .top, spacing: 40) {
                        VStack(alignment: .center, spacing: 16) {
                            Text("T3 Input:")
                                .font(.headline)
                            VStack(spacing: 12) {
                                Button(action: {
                                    activePopup = .T3OralInputs
                                  }) {
                                      VStack{
                                          Image("pill1")
                                          Text("Oral Dose")
                                      }
                                  }
                                Button(action: {
                                    activePopup = .T3IVInputs
                                  }) {
                                      VStack{
                                          Image("syringe1")
                                          Text("IV Bolus Dose")
                                      }
                                  }
                                Button(action: {
                                    activePopup = .T3InfusionInputs
                                  }) {
                                      VStack{
                                          Image("infusion1")
                                          Text("Infusion Dose")
                                      }
                                  }
                             }
                        }
                        
                        VStack(alignment: .center, spacing: 16) {
                            Text("T4 Input:")
                                .font(.headline)
                            VStack(spacing: 12) {
                                Button(action: {
                                    activePopup = .T4OralInputs
                                  }) {
                                      VStack{
                                          Image("pill2")
                                          Text("Oral Dose")
                                      }
                                  }
                                Button(action: {
                                    activePopup = .T4IVInputs
                                  }) {
                                      VStack{
                                          Image("syringe2")
                                          Text("IV Bolus Dose")
                                      }
                                  }
                                Button(action: {
                                    activePopup = .T4InfusionInputs
                                  }) {
                                      VStack{
                                          Image("infusion2")
                                          Text("Infusion Dose")
                                      }
                                  }
  
                            }
                        }
                    }
                    
                    Text("What: Combinations of T3 and T4 can be added as dosage inputs at different times and types.")
                        .font(.body)
                        .foregroundColor(.gray)

                    // Instruction box
                    VStack(alignment: .leading, spacing: 12) {
                        Text("HOW TO CONDUCT DOSING EXPERIMENT?")
                            .font(.headline)
                            .padding()
                            .background(Color.yellow)
                            .cornerRadius(8)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("• Click on an icon to add as input")
                            Text("• Click one or more icons to add as many inputs and/or at as many times as desired")
                            Text("• Euthyroid - Normal hormone responses are simulated, shown can be plotted and saved in Step 3 and results can be plotted and saved")
                        }
                        .font(.footnote)
                    }
                    .padding()
                    
                
                    if !t3oralinputs.isEmpty {
                        
                        Section(header:                                     HStack(alignment: .center, spacing: 10)
                                {
                            Image("pill1")
                                .resizable()
                                .frame(width: 30, height: 30)
                            Text("T3-ORAL DOSE")
                                .font(.title2.bold())
                        }) {
                            ForEach(enumeratedT3Oral, id: \.1.id) { index, t3oral in
                                HStack(alignment: .center){
                                    VStack(alignment: .leading){
                                        Text("Input \(index + 1):")
                                            .font(.title3.bold())
                                        Text("Dose (µg): \(String(format: "%.2f", t3oral.T3OralDoseInput))")
                                        Text("Dose Start Day or Time: \(String(format: "%.2f", t3oral.T3OralDoseStart))")
                                        if !t3oral.T3SingleDose {
                                            Text("Dose End Day or Time: \(String(format: "%.2f", t3oral.T3OralDoseEnd))")
                                            Text("Dosing Interval (days): \(String(format: "%.2f", t3oral.T3OralDoseInterval))")
                                        }
                                    }
                                    Spacer()
                                    Button(action: {
                                        if let index = t3oralinputs.firstIndex(where: { $0.id == t3oral.id }) {
                                            t3oralinputs.remove(at: index)
                                        }
                                    }) {
                                        Image("delete")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                    }
                                    
                                }
                            }
                        }
                    }
                    
                    if !t3ivinputs.isEmpty {
                        Section(header:                                     HStack(alignment: .center, spacing: 10)
                                {
                            Image("syringe1")
                                .resizable()
                                .frame(width: 30, height: 30)
                            Text("T3-IV DOSE")
                                .font(.title2.bold())
                        }) {
                            ForEach(enumeratedT3IV, id: \.1.id) { index, t3iv in
                                HStack(alignment: .center){
                                    VStack(alignment: .leading){
                                        Text("Input \(index + 1):")
                                            .font(.title3.bold())
                                        Text("Dose (µg): \(String(format: "%.2f", t3iv.T3IVDoseInput))")
                                        Text("Dose Start Day or Time: \(String(format: "%.2f", t3iv.T3IVDoseStart))")
                                    }
                                    Spacer()
                                    Button(action: {
                                        if let index = t3ivinputs.firstIndex(where: { $0.id == t3iv.id }) {
                                            t3ivinputs.remove(at: index)
                                        }
                                    }) {
                                        Image("delete")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                    }
                                    
                                }
                                
                            }
                        }
                    }
                    
                    if !t3infusioninputs.isEmpty {
                        Section(header:                                     HStack(alignment: .center, spacing: 10)
                                {
                                    Image("infusion1")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                    Text("T3-INFUSION DOSE")
                                        .font(.title3.bold())
                                }) {
                            ForEach(enumeratedT3Infusion, id: \.1.id) { index, t3infusion in
                                HStack(alignment: .center){
                                    VStack(alignment: .leading){
                                        Text("Input \(index + 1):")
                                            .font(.title3.bold())
                                        Text("Dose (µg): \(String(format: "%.2f", t3infusion.T3InfusionDoseInput))")
                                        Text("Dose Start Day or Time: \(String(format: "%.2f", t3infusion.T3InfusionDoseStart))")
                                        Text("Dose End Day or Time: \(String(format: "%.2f", t3infusion.T3InfusionDoseEnd))")
                                    }
                                    Spacer()
                                    Button(action: {
                                        if let index = t3infusioninputs.firstIndex(where: { $0.id == t3infusion.id }) {
                                            t3infusioninputs.remove(at: index)
                                        }
                                    }) {
                                        Image("delete")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                        
                                    }
                                    
                                }
                            }
                        }
                    }
                    
                    //T4
                    if !t4oralinputs.isEmpty {
                        
                        Section(header:                                     HStack(alignment: .center, spacing: 10)
                                {
                            Image("pill2")
                                .resizable()
                                .frame(width: 30, height: 30)
                            Text("T4-ORAL DOSE")
                                .font(.title2.bold())
                        }) {
                            ForEach(enumeratedT4Oral, id: \.1.id) { index, t4oral in
                                HStack(alignment: .center){
                                    VStack(alignment: .leading){
                                        Text("Input \(index + 1):")
                                            .font(.title3.bold())
                                        Text("Dose (µg): \(String(format: "%.2f", t4oral.T4OralDoseInput))")
                                        Text("Dose Start Day or Time: \(String(format: "%.2f", t4oral.T4OralDoseStart))")
                                        if !t4oral.T4SingleDose {
                                            Text("Dose End Day or Time: \(String(format: "%.2f", t4oral.T4OralDoseEnd))")
                                            Text("Dosing Interval (days): \(String(format: "%.2f", t4oral.T4OralDoseInterval))")
                                        }
                                    }
                                    Spacer()
                                    Button(action: {
                                        if let index = t4oralinputs.firstIndex(where: { $0.id == t4oral.id }) {
                                            t4oralinputs.remove(at: index)
                                        }
                                    }) {
                                        Image("delete")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                    }
                                    
                                }
                            }
                        }
                    }
                    
                    if !t4ivinputs.isEmpty {
                        Section(header:                                     HStack(alignment: .center, spacing: 10)
                                {
                            Image("syringe2")
                                .resizable()
                                .frame(width: 30, height: 30)
                            Text("T4-IV DOSE")
                                .font(.title2.bold())
                        }) {
                            ForEach(enumeratedT4IV, id: \.1.id) { index, t4iv in
                                HStack(alignment: .center){
                                    VStack(alignment: .leading){
                                        Text("Input \(index + 1):")
                                            .font(.title3.bold())
                                        Text("Dose (µg): \(String(format: "%.2f", t4iv.T4IVDoseInput))")
                                        Text("Dose Start Day or Time: \(String(format: "%.2f", t4iv.T4IVDoseStart))")
                                    }
                                    Spacer()
                                    Button(action: {
                                        if let index = t4ivinputs.firstIndex(where: { $0.id == t4iv.id }) {
                                            t4ivinputs.remove(at: index)
                                        }
                                    }) {
                                        Image("delete")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                    }
                                    
                                }
                                
                            }
                        }
                    }
                    
                    if !t4infusioninputs.isEmpty {
                        Section(header:                                     HStack(alignment: .center, spacing: 10)
                                {
                                    Image("infusion2")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                    Text("T4-INFUSION DOSE")
                                        .font(.title3.bold())
                                }) {
                            ForEach(enumeratedT4Infusion, id: \.1.id) { index, t4infusion in
                                HStack(alignment: .center){
                                    VStack(alignment: .leading){
                                        Text("Input \(index + 1):")
                                            .font(.title3.bold())
                                        Text("Dose (µg): \(String(format: "%.2f", t4infusion.T4InfusionDoseInput))")
                                        Text("Dose Start Day or Time: \(String(format: "%.2f", t4infusion.T4InfusionDoseStart))")
                                        Text("Dose End Day or Time: \(String(format: "%.2f", t4infusion.T4InfusionDoseEnd))")
                                    }
                                    Spacer()
                                    Button(action: {
                                        if let index = t4infusioninputs.firstIndex(where: { $0.id == t4infusion.id }) {
                                            t4infusioninputs.remove(at: index)
                                        }
                                    }) {
                                        Image("delete")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                        
                                    }
                                    
                                }
                            }
                        }
                    }
                    Spacer().frame(height: 80)
                }
                .padding()
                .foregroundColor(.white)
            }

        }
        .background(Color.black.ignoresSafeArea())
        .padding()
        .sheet(item: $activePopup) { popup in
            switch popup {
            case .T3OralInputs:
                T3OralPopupView { newT3Oral in
                    t3oralinputs.append(newT3Oral)
                    activePopup = nil
                }
            case .T3IVInputs:
                T3IVPopupView { newT3IV in
                    t3ivinputs.append(newT3IV)
                    activePopup = nil
                }
            case .T3InfusionInputs:
                T3InfusionPopupView { newT3Infusion in
                    t3infusioninputs.append(newT3Infusion)
                    activePopup = nil
                }
                
            case .T4OralInputs:
                T4OralPopupView { newT4Oral in
                    t4oralinputs.append(newT4Oral)
                    activePopup = nil
                }
            case .T4IVInputs:
                T4IVPopupView { newT4IV in
                    t4ivinputs.append(newT4IV)
                    activePopup = nil
                }
            case .T4InfusionInputs:
                T4InfusionPopupView { newT4Infusion in
                    t4infusioninputs.append(newT4Infusion)
                    activePopup = nil
                }
                
            }
            
        }
        .background(Color.black.ignoresSafeArea())
    
    }
}

struct Step2InputField: View {
    var title: String
    @Binding var value: String
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .trailing, spacing: 5) {
            Text(title)
                .font(.callout)
                .foregroundColor(.white)
            TextField("", text: $value)
                .frame(width: 100, alignment: .trailing)
                .padding(10)
                .background(Color.black.opacity(0.1))
                .cornerRadius(8)
                .foregroundColor(.black)
                .fixedSize(horizontal:true, vertical: true)
        }
        .padding(.horizontal)
    }
}

