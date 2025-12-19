import SwiftUI

struct Step1PopupView: View {
    @Binding var t4Secretion: String
    @Binding var t4Absorption: String
    @Binding var t3Secretion: String
    @Binding var t3Absorption: String
    @Binding var simulationDays: String
    @Binding var heightCm: Double
    @Binding var weightKg: Double
    @Binding var selectedGender: String
    @Binding var isInitialConditionsOn: Bool
    @Binding var selectedHeightUnit: String
    @Binding var selectedWeightUnit: String

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

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color.black.ignoresSafeArea()
                VStack(spacing: 15) {
                    Text("Enter Simulation Conditions")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.top)

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
                        
                        
                        HStack(alignment: .top, spacing: 15) {
                            
                            // 1. Gender Section
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Gender")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Picker("Gender", selection: $selectedGender) {
                                    Text("M").tag("MALE")
                                    Text("F").tag("FEMALE")
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .frame(width: 80)
                            }
                            
                            // 2. Height Section
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Height")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                HStack(spacing: 5) {
                                    TextField("0", text: Binding(
                                        get: {
                                            if selectedHeightUnit == "in" {
                                                return String(format: "%.1f", heightCm / 2.54)
                                            } else {
                                                return String(format: "%.1f", heightCm)
                                            }
                                        },
                                        set: { newValue in
                                            if let doubleValue = Double(newValue.replacingOccurrences(of: ",", with: ".")) {
                                                if selectedHeightUnit == "in" {
                                                    heightCm = doubleValue * 2.54
                                                } else {
                                                    heightCm = doubleValue
                                                }
                                            }
                                            _ = validate(value: String(heightCm), in: 0...300, errorState: $heightError, fieldName: "Height")
                                        }
                                    ))
                                    .foregroundColor(Color.white)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.center)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(5)
                                    
                                    Picker("Height", selection: $selectedHeightUnit) {
                                        Text("cm").tag("cm")
                                        Text("in").tag("in")
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                    .onChange(of: selectedHeightUnit) { _ in
                                        _ = validate(value: String(heightCm), in: 0...300, errorState: $heightError, fieldName: "Height")
                                    }
                                }
                                if let error = heightError {
                                    Text(error).font(.system(size: 8)).foregroundColor(.red).fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            
                            // 3. Weight Section
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Weight")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                HStack(spacing: 5) {
                                    TextField("0", text: Binding(
                                        get: {
                                            if selectedWeightUnit == "lb" {
                                                return String(format: "%.1f", weightKg * 2.20462)
                                            } else {
                                                return String(format: "%.1f", weightKg)
                                            }
                                        },
                                        set: { newValue in
                                            if let doubleValue = Double(newValue.replacingOccurrences(of: ",", with: ".")) {
                                                if selectedWeightUnit == "lb" {
                                                    weightKg = doubleValue / 2.20462
                                                } else {
                                                    weightKg = doubleValue
                                                }
                                            }
                                            _ = validate(value: String(weightKg), in: 0...1000, errorState: $weightError, fieldName: "Weight")
                                        }
                                    ))
                                    .foregroundColor(Color.white)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.center)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(5)
                                    
                                    Picker("Weight", selection: $selectedWeightUnit) {
                                        Text("kg").tag("kg")
                                        Text("lb").tag("lb")
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                    .onChange(of: selectedWeightUnit) { _ in
                                        _ = validate(value: String(weightKg), in: 0...1000, errorState: $weightError, fieldName: "Weight")
                                    }
                                }
                                if let error = weightError {
                                    Text(error).font(.system(size: 8)).foregroundColor(.red).fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Simulation Interval (days <= 100)")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            TextField("5", text: $simulationDays)
                                .keyboardType(.numberPad)
                                .padding(10)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .onChange(of: simulationDays) { newValue in
                                    _ = validate(value: newValue, in: 1...100, errorState: $simulationDaysError, fieldName: "Simulation Interval")
                                }
                            
                            if let error = simulationDaysError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Toggle(isOn: $isInitialConditionsOn) {
                            Text("Recalculate Initial Conditions")
                                .foregroundColor(.white)
                                .font(.subheadline)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .red))
                    }

                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top)
            }
            .navigationBarHidden(true)
        }
        .onAppear(perform: validateAllFields)
    }

    private func validate(value: String, in range: ClosedRange<Double>, errorState: Binding<String?>, fieldName: String) -> Bool {
        guard !value.isEmpty else {
            errorState.wrappedValue = "Cannot be empty."
            return false
        }
        guard let doubleValue = Double(value) else {
            errorState.wrappedValue = "Must be a valid number."
            return false
        }
        if !range.contains(doubleValue) {
            errorState.wrappedValue = "Must be between \(Int(range.lowerBound)) and \(Int(range.upperBound))."
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
        _ = validate(value: String(heightCm), in: 0...300, errorState: $heightError, fieldName: "Height")
        _ = validate(value: String(weightKg), in: 0...1000, errorState: $weightError, fieldName: "Weight")
    }
}
