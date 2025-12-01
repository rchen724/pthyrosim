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
    @AppStorage("selectedGender") private var selectedGender: String = "FEMALE"
    @AppStorage("isInitialConditionsOn") private var isInitialConditionsOn: Bool = true

    // New AppStorage for units
    @AppStorage("selectedHeightUnit") private var selectedHeightUnit: String = "cm"
    @AppStorage("selectedWeightUnit") private var selectedWeightUnit: String = "kg"
    
    @State private var scrollOffset: CGFloat = 0
    @State private var contentHeight: CGFloat = 1
    @State private var scrollViewHeight: CGFloat = 1

    // Input validation state
    @State private var t4SecretionError: String?
    @State private var t4AbsorptionError: String?
    @State private var t3SecretionError: String?
    @State private var t3AbsorptionError: String?
    @State private var simulationDaysError: String?
    @State private var heightError: String?
    @State private var weightError: String?
    @State private var isSyncing = false

    let genders = ["MALE", "FEMALE"]
    let heightUnits = ["cm", "in"]
    let weightUnits = ["lb", "kg"]

    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 15) {
                        Text("Enter Simulation Conditions")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.top)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Normal euthyroid defaults shown")
                            Text("To simulate hypothyroidism or malabsorption conditions:")
                            Text("• Change T3/T4 secretion rate SR3/4 of normal)")
                            Text("• Modify T3/T4 oral absorption from 88%")
                        }
                        .font(.subheadline)
                        .foregroundColor(.white)

                        Group {
                            HStack(spacing: 6){
                                Step1InputField(title: "T4 Secretion (0–125%)*", value: $t4Secretion, errorMessage: t4SecretionError, keyboardType: .decimalPad)
                                    .onChange(of: t4Secretion) { newValue in
                                        let isValid = validate(value: newValue, in: 0...125, errorState: $t4SecretionError, fieldName: "T4 Secretion")
                                        if isValid && !isSyncing {
                                            isSyncing = true
                                            t3Secretion = newValue
                                            isSyncing = false
                                        }
                                    }
                                
                                Step1InputField(title: "T4 Absorption (0–100%)", value: $t4Absorption, errorMessage: t4AbsorptionError, keyboardType: .decimalPad)
                                    .onChange(of: t4Absorption) { newValue in
                                        _ = validate(value: newValue, in: 0...100, errorState: $t4AbsorptionError, fieldName: "T4 Absorption")
                                    }
                            }
                            HStack(spacing: 6){
                                Step1InputField(title: "T3 Secretion (0–125%)*", value: $t3Secretion, errorMessage: t3SecretionError, keyboardType: .decimalPad)
                                    .onChange(of: t3Secretion) { newValue in
                                        let isValid = validate(value: newValue, in: 0...125, errorState: $t3SecretionError, fieldName: "T3 Secretion")
                                        if isValid && !isSyncing {
                                            isSyncing = true
                                            t4Secretion = newValue
                                            isSyncing = false
                                        }
                                    }
                                
                                Step1InputField(title: "T3 Absorption (0–100%)", value: $t3Absorption, errorMessage: t3AbsorptionError, keyboardType: .decimalPad)
                                    .onChange(of: t3Absorption) { newValue in
                                        _ = validate(value: newValue, in: 0...100, errorState: $t3AbsorptionError, fieldName: "T3 Absorption")
                                    }
                            }
                            
                                }


                            HStack(alignment: .top, spacing: 15) {
                                
                                // 1. Gender Section
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Sex")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                    Picker("Gender", selection: $selectedGender) {
                                        Text("M").tag("MALE")
                                        Text("F").tag("FEMALE")
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                    .frame(width: 80) // Fixed width to save space
                                }
                                
                                // 2. Height Section
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Height")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    HStack(spacing: 5) {
                                        TextField("0", text: $height)
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.center)
                                            .padding(.vertical, 8)
                                            .background(Color.white.opacity(0.1))
                                            .cornerRadius(5)
                                            .onChange(of: height) { newValue in
                                                _ = validate(value: newValue, in: 0...300, errorState: $heightError, fieldName: "Height")
                                            }
                                        
                                        // Tappable Unit Toggle
                                        Button(action: {
                                            selectedHeightUnit = (selectedHeightUnit == "cm") ? "in" : "cm"
                                        }) {
                                            Text(selectedHeightUnit)
                                                .font(.caption).bold()
                                                .frame(width: 30)
                                                .padding(.vertical, 8)
                                                .background(Color.blue.opacity(0.6))
                                                .foregroundColor(.white)
                                                .cornerRadius(5)
                                        }
                                    }
                                    if let error = heightError { // Error Message display
                                        Text(error).font(.system(size: 8)).foregroundColor(.red).fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                                
                                // 3. Weight Section
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Weight")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    HStack(spacing: 5) {
                                        TextField("0", text: $weight)
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.center)
                                            .padding(.vertical, 8)
                                            .background(Color.white.opacity(0.1))
                                            .cornerRadius(5)
                                            .onChange(of: weight) { newValue in
                                                _ = validate(value: newValue, in: 0...1000, errorState: $weightError, fieldName: "Weight")
                                            }
                                        
                                        // Tappable Unit Toggle
                                        Button(action: {
                                            selectedWeightUnit = (selectedWeightUnit == "kg") ? "lb" : "kg"
                                        }) {
                                            Text(selectedWeightUnit)
                                                .font(.caption).bold()
                                                .frame(width: 30)
                                                .padding(.vertical, 8)
                                                .background(Color.blue.opacity(0.6))
                                                .foregroundColor(.white)
                                                .cornerRadius(5)
                                        }
                                    }
                                    if let error = weightError { // Error Message display
                                        Text(error).font(.system(size: 8)).foregroundColor(.red).fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                            Step1InputField(title: "Simulation Interval (days <= 100)", value: $simulationDays, errorMessage: simulationDaysError, keyboardType: .numberPad)
                                .onChange(of: simulationDays) { newValue in
                                    _ = validate(value: newValue, in: 1...100, errorState: $simulationDaysError, fieldName: "Simulation Interval")
                                }                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Toggle(isOn: $isInitialConditionsOn) {
                                Text("Recalculate Initial Conditions")
                                    .foregroundColor(.white)
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .red))
                            Text("When this switch is ON, SR3 & SR4 initial conditions (IC) are recalculated to match new inputs. When this switch is OFF, initial conditions are set to euthyroid.")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        .padding()

                        Text("*Note: SR3 & SR4 change together & are capped at 125% because model is not validated for hyperthyroid conditions. ")
                            .font(.footnote)
                            .foregroundColor(.white)
                            .padding(.bottom, 30)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top)
                }
                .background(Color.black.ignoresSafeArea())
                .navigationTitle("Step 1")
                .navigationBarHidden(true)
            }
            .onAppear(perform: validateAllFields)
        }
    }

    private func validate(value: String, in range: ClosedRange<Double>, errorState: Binding<String?>, fieldName: String) -> Bool {
        guard !value.isEmpty else {
            errorState.wrappedValue = "\(fieldName) cannot be empty."
            return false
        }
        guard let doubleValue = Double(value) else {
            errorState.wrappedValue = "\(fieldName) must be a valid number."
            return false
        }
        if !range.contains(doubleValue) {
            errorState.wrappedValue = "\(fieldName) must be between \(Int(range.lowerBound)) and \(Int(range.upperBound))."
            return false
        } else {
            errorState.wrappedValue = nil
            return true
        }
    }

    private func validateAllFields() {
        _ = validate(value: t4Secretion, in: 0...125, errorState: $t4SecretionError, fieldName: "T4 Secretion")
        _ = validate(value: t4Absorption, in: 0...100, errorState: $t4AbsorptionError, fieldName: "T4 Absorption")
        _ = validate(value: t3Secretion, in: 0...125, errorState: $t3SecretionError, fieldName: "T3 Secretion")
        _ = validate(value: t3Absorption, in: 0...100, errorState: $t3AbsorptionError, fieldName: "T3 Absorption")
        _ = validate(value: simulationDays, in: 1...100, errorState: $simulationDaysError, fieldName: "Simulation Interval")
        _ = validate(value: height, in: 0...300, errorState: $heightError, fieldName: "Height")
        _ = validate(value: weight, in: 0...1000, errorState: $weightError, fieldName: "Weight")
    }
}

struct Step1InputField: View {
    var title: String
    @Binding var value: String
    var errorMessage: String?
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
            TextField("Enter value", text: $value)
                .keyboardType(keyboardType)
                .padding(10)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                .foregroundColor(errorMessage == nil ? .white : .red)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.leading, 5)
            }
        }
    }
}

struct CustomSegmentedPicker: View {
    @Binding var selection: String
    let options: [String]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    selection = option
                }) {
                    Text(option)
                        .font(.system(size: 18, weight: .bold)) // 👈 Bigger font
                        .foregroundColor(selection == option ? .white : .gray)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(selection == option ? Color.blue : Color.gray.opacity(0.4))
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle()) // Prevents system styling
            }
        }
    }
}
