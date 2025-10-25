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

    let genders = ["MALE", "FEMALE"]
    let heightUnits = ["cm", "in"]
    let weightUnits = ["lb", "kg"]

    // Scroll tracking state

    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Track scroll offset using GeometryReader
                        GeometryReader { geo -> Color in
                            DispatchQueue.main.async {
                                self.scrollOffset = -geo.frame(in: .named("scroll")).origin.y
                            }
                            return Color.clear
                        }
                        .frame(height: 0) // invisible spacer to track scroll position

                        Text("Enter Simulation Conditions")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.top)
                        
                    
                        VStack(spacing: 6) {
                            BulletRow(text: "Normal euthyroid defaults shown")
                            BulletRow(text: "To simulate hypothyroidism or malabsorption conditions:")
                            BulletRow(text: "Change T3/T4 secretion rate SR (% of normal)")
                            BulletRow(text: "Modify T3/T4 oral absorption from 88%")
                        }


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
                                        Text(gender)
                                            .tag(gender)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .background(Color.gray.opacity(0.6))
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
                                .background(Color.gray.opacity(0.6))
                                .cornerRadius(8)
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
                                .background(Color.gray.opacity(0.6))
                                .cornerRadius(8)
                            }.padding(.horizontal)

                            Step1InputField(title: "Simulation Interval (days <= 100)", value: $simulationDays, keyboardType: .numberPad)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Toggle(isOn: $isInitialConditionsOn) {
                                Text("Recalculate Initial Conditions")
                                    .foregroundColor(.white)
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .red))

                            Text("When this switch is ON, initial conditions (IC) are recalculated. When this switch is OFF, initial conditions are set to euthyroid.")
                                .font(.footnote)
                                .foregroundColor(.white)
                        }
                        
                        .padding()
                        

                        Text("*Note: SR is capped at 125% because model is not validated for hyperthyroid conditions.")
                            .font(.footnote)
                            .foregroundColor(.white)
                            .padding(.bottom, 30)
                    }
                    .background(
                        GeometryReader { geo -> Color in
                            DispatchQueue.main.async {
                                self.contentHeight = geo.size.height
                            }
                            return Color.clear
                        }
                    )
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .top)
                }
                .coordinateSpace(name: "scroll")
                .background(
                    GeometryReader { geo -> Color in
                        DispatchQueue.main.async {
                            self.scrollViewHeight = geo.size.height
                        }
                        return Color.clear
                    }
                )
                .background(Color.black.ignoresSafeArea())

                // Custom scrollbar
                if contentHeight > scrollViewHeight {
                    let maxScroll = max(contentHeight - scrollViewHeight, 1)
                    let clampedScrollOffset = min(max(scrollOffset, 0), maxScroll)
                    let scrollProgress = clampedScrollOffset / maxScroll
                    let visibleRatio = scrollViewHeight / contentHeight
                    let thumbHeight = max(scrollViewHeight * visibleRatio * 0.25, 10)
                    let thumbTop = scrollProgress * (scrollViewHeight - thumbHeight)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.8))
                        .frame(width: 8, height: thumbHeight)
                        .padding(.trailing, 4)
                        .offset(y: thumbTop)
                        .animation(.easeInOut(duration: 0.15), value: thumbTop)
                }
            }
            .navigationTitle("Step 1")
            .onAppear {
                if selectedGender.isEmpty || !genders.contains(selectedGender) {
                    selectedGender = "FEMALE"
                }
            }
            .navigationBarHidden(true)

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
                .foregroundColor(.white)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
        }
        .padding(.horizontal)
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
