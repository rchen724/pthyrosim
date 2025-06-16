import SwiftUI

struct Step1View: View {
    // AppStorage variables remain, though unit selection ones won't be used for Pickers anymore
    @AppStorage("t4Secretion") private var t4Secretion: String = "100"
    @AppStorage("t4Absorption") private var t4Absorption: String = "88" // Assuming this is still used elsewhere
    @AppStorage("t3Secretion") private var t3Secretion: String = "100"
    @AppStorage("t3Absorption") private var t3Absorption: String = "88" // Assuming this is still used elsewhere
    @AppStorage("simulationDays") private var simulationDays: String = "5"
    @AppStorage("height") private var height: String = "1.65" // User will input this as meters
    @AppStorage("weight") private var weight: String = "91"   // User will input this as kilograms
    @AppStorage("selectedGender") private var selectedGender: String = "Female" // Default to Female
    // @AppStorage("selectedHeightUnit") private var selectedHeightUnit: String = "m" // No longer needed for a Picker
    // @AppStorage("selectedWeightUnit") private var selectedWeightUnit: String = "kg" // No longer needed for a Picker
    @AppStorage("isInitialConditionsOn") private var isInitialConditionsOn: Bool = false

    let genders = ["Male", "Female"]
    // Removed heightUnits and weightUnits as they are no longer used for Pickers

    var body: some View {
        NavigationView { // Consider if NavigationView is needed here or if it's part of MainView
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
                            Picker("Gender", selection: $selectedGender) { // Added label to Picker for clarity
                                ForEach(genders, id: \.self) { gender in
                                    Text(gender).tag(gender) // Ensure tags are set
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle()) // Using SegmentedPickerStyle for Gender
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(8)
                            // .foregroundColor(.white) // Segmented style handles text color
                        }
                        .padding(.horizontal)
                        
                        // Updated Height Input Field
                        Step1InputField(title: "Height (in m)", value: $height, keyboardType: .decimalPad)
                        
                        // Updated Weight Input Field
                        Step1InputField(title: "Weight (in kg)", value: $weight, keyboardType: .decimalPad)
                        
                        // Removed the duplicate "Weight" input field that was here.
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
                .frame(maxWidth: .infinity, alignment: .top) // This keeps content at the top if ScrollView is too tall
            }
            .background(Color.black.ignoresSafeArea())
            .onAppear { // Defensive check for gender picker default
                if selectedGender.isEmpty || !genders.contains(selectedGender) {
                    selectedGender = "Female"
                }
            }
        }
        // .navigationViewStyle(.stack) // Apply to NavigationView if you want stack behavior explicitly.
    }
}

// Step1InputField struct remains the same, but we'll pass keyboardType to it
struct Step1InputField: View {
    var title: String
    @Binding var value: String
    var keyboardType: UIKeyboardType = .default // Added keyboardType parameter

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.callout)
                .foregroundColor(.white)
            TextField("Enter value", text: $value) // Added a generic placeholder
                .keyboardType(keyboardType) // Apply the passed keyboardType
                .padding(10)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                .foregroundColor(.white)
                .autocorrectionDisabled(true) // Often useful for numerical/code-like inputs
                .textInputAutocapitalization(.never) // Useful for certain types of input
        }
        .padding(.horizontal) // Apply horizontal padding to the whole input field group
    }
}

struct Step1View_Previews: PreviewProvider {
    static var previews: some View {
        Step1View()
            // .environmentObject(AppState()) // If your preview needs it
    }
}
