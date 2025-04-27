//
//  Step1View.swift
//  biocyberneticsapp
//
//  Created by Shruthi Sathya on 4/15/25.
//

import SwiftUI

struct Step1View: View {
    @AppStorage("t4Secretion") private var t4Secretion: String = "100"
    @AppStorage("t4Absorption") private var t4Absorption: String = "88"
    @AppStorage("t3Secretion") private var t3Secretion: String = "100"
    @AppStorage("t3Absorption") private var t3Absorption: String = "88"
    @AppStorage("simulationDays") private var simulationDays: String = "5"
    @AppStorage("height") private var height: String = "1.68"
    @AppStorage("weight") private var weight: String = "70"
    @AppStorage("selectedGender") private var selectedGender: String = ""
    @AppStorage("isInitialConditionsOn") private var isInitialConditionsOn: Bool = false

    let genders = ["Male", "Female"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Enter Simulation Conditions")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.top)

                    VStack(alignment: .leading, spacing: 5) {
                        Text("• To simulate hypothyroidism or malabsorption conditions")
                        Text("• To Change T3/T4 secretion rate SR (% of normal)")
                        Text("• To modify oral absorption from 88%: change T3/T4 absorption")
                        Text("(Normal Defaults Shown)")
                            .padding(.top, 5)
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)

                    Group {
                        Step1InputField(title: "Change T4 Secretion (0–125%)*", value: $t4Secretion)
                        Step1InputField(title: "Change T4 Absorption (0–100%)", value: $t4Absorption)
                        Step1InputField(title: "Change T3 Secretion (0–125%)*", value: $t3Secretion)
                        Step1InputField(title: "Change T3 Absorption (0–100%)", value: $t3Absorption)

                        // Gender Dropdown
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Gender")
                                .font(.callout)
                                .foregroundColor(.white)

                            Picker("", selection: $selectedGender) {
                                ForEach(genders, id: \.self) { gender in
                                    Text(gender)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                        }
                        .padding(.horizontal)

                        Step1InputField(title: "Height", value: $height)
                        Step1InputField(title: "Weight", value: $weight)
                        Step1InputField(title: "Simulation Interval (days <= 100)", value: $simulationDays)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("CLICK ON (to RED) to change starting hormone values if secretion/absorption rates are changed from the defaults.")
                            .font(.footnote)
                            .foregroundColor(.white)

                        Toggle(isOn: $isInitialConditionsOn) {
                            Text("Recalculate Initial Conditions")
                                .foregroundColor(.white)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .red))

                        Text("When this switch is ON, initial conditions (IC) are recalculated. When this switch is OFF, initial conditions are set to euthyroid.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    .padding()

                    Text("*Note: SR is capped at 125% because model is not validated for hyperthyroid conditions.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.bottom, 30)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .background(Color.black.ignoresSafeArea()) // Full black background
        }
    }
}

struct Step1InputField: View {
    var title: String
    @Binding var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.callout)
                .foregroundColor(.white)
            TextField("", text: $value)
                .padding(10)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                .foregroundColor(.white)
        }
        .padding(.horizontal)
    }
}
