import SwiftUI

struct Step1View: View {
    // AppStorage variables to store user input
    @AppStorage("t4Secretion") private var t4Secretion: String = "100"
    @AppStorage("t4Absorption") private var t4Absorption: String = "88"
    @AppStorage("t3Secretion") private var t3Secretion: String = "100"
    @AppStorage("t3Absorption") private var t3Absorption: String = "88"
    @AppStorage("simulationDays") private var simulationDays: String = "5"
    @AppStorage("height") private var height: String = "170" // Default height
    @AppStorage("weight") private var weight: String = "70"   // Default weight
    @AppStorage("selectedGender") private var selectedGender: String = "Female"
    @AppStorage("isInitialConditionsOn") private var isInitialConditionsOn: Bool = false

    // New AppStorage for units
    @AppStorage("selectedHeightUnit") private var selectedHeightUnit: String = "cm"
    @AppStorage("selectedWeightUnit") private var selectedWeightUnit: String = "kg"

    let genders = ["Male", "Female"]
    let heightUnits = ["cm", "in"]
    let weightUnits = ["kg", "lb"]

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
                        Step1InputField(title: "Change T4 Secretion (0–125%)*", value: $t4Secretion, keyboardType: .decimalPad)
                        Step1InputField(title: "Change T4 Absorption (0–100%)", value: $t4Absorption, keyboardType: .decimalPad)
                        Step1InputField(title: "Change T3 Secretion (0–125%)*", value: $t3Secretion, keyboardType: .decimalPad)
                        Step1InputField(title: "Change T3 Absorption (0–100%)", value: $t3Absorption, keyboardType: .decimalPad)

                        VStack(alignment: .leading, spacing: 5) {
                            Text("Gender")
                                .font(.callout)
                                .foregroundColor(.white)
                            Picker("Gender", selection: $selectedGender) {
                                ForEach(genders, id: \.self) { gender in
                                    Text(gender).tag(gender)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal)

                        // Height Input with Unit Picker
                        HStack {
                            Step1InputField(title: "Height", value: $height, keyboardType: .decimalPad)
                            Picker("Height Unit", selection: $selectedHeightUnit) {
                                ForEach(heightUnits, id: \.self) { unit in
                                    Text(unit)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(width: 150)
                            .background(Color.gray.opacity(0.3)) // <-- Added for visibility
                            .cornerRadius(8)                   // <-- Added for visibility
                        }.padding(.horizontal)

                        // Weight Input with Unit Picker
                        HStack {
                            Step1InputField(title: "Weight", value: $weight, keyboardType: .decimalPad)
                            Picker("Weight Unit", selection: $selectedWeightUnit) {
                                ForEach(weightUnits, id: \.self) { unit in
                                    Text(unit)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(width: 150)
                            .background(Color.gray.opacity(0.3)) // <-- Added for visibility
                            .cornerRadius(8)                   // <-- Added for visibility
                        }.padding(.horizontal)
                        
                        Step1InputField(title: "Simulation Interval (days <= 100)", value: $simulationDays, keyboardType: .numberPad)
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
            .background(Color.black.ignoresSafeArea())
            .onAppear {
                if selectedGender.isEmpty || !genders.contains(selectedGender) {
                    selectedGender = "Female"
                }
            }
        }
    }
}

struct Step1InputField: View {
    var title: String
    @Binding var value: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.callout)
                .foregroundColor(.white)
            TextField("Enter value", text: $value)
                .keyboardType(keyboardType)
                .padding(10)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                .foregroundColor(.white) // <-- This is the change you requested
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
        }
        .padding(.horizontal)
    }
}

