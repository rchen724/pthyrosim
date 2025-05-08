import SwiftUI
import Charts

struct SimulationGraphView: View {
    let result: ThyroidSimulationResult

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 40) {
                
                Text("Simulation Results")
                    .font(.title)
                    .foregroundColor(.black)
                    .padding(.top)

                GraphSection(
                    title: "T4",
                    yLabel: "T4 (µg/L)",
                    xLabel: "Days",
                    values: result.time.indices.map { (result.time[$0], result.t4[$0]) },
                    color: .blue,
                    yAxisRange: 0...100
                )

                GraphSection(
                    title: "T3",
                    yLabel: "T3 (µg/L)",
                    xLabel: "Days",
                    values: result.time.indices.map { (result.time[$0], result.t3[$0]) },
                    color: .green,
                    yAxisRange: 0...1.5
                )

                GraphSection(
                    title: "TSH",
                    yLabel: "TSH (mU/L)",
                    xLabel: "Days",
                    values: result.time.indices.map { (result.time[$0], result.tsh[$0]) },
                    color: .red,
                    yAxisRange: 0...5
                )
            }
            
            Text("Home View")
                .navigationTitle("Simulation Graphs")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: Run2View()) {
                            Text("Run 2")
                        }
                    }
                }
            .padding()
        }
        
        
        .background(Color.white.ignoresSafeArea()) // <-- White background!
    }
}

struct GraphSection: View {
    let title: String
    let yLabel: String
    let xLabel: String
    let values: [(Double, Double)]
    let color: Color
    let yAxisRange: ClosedRange<Double>

    @State private var yZoom: CGFloat = 1.0

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .foregroundColor(.black)
                .font(.headline)

            Chart {
                ForEach(values, id: \.0) { time, value in
                    LineMark(
                        x: .value("Time", time),
                        y: .value("Value", value)
                    )
                    .foregroundStyle(color)
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartYScale(domain: scaledRange())
            .chartXAxisLabel(xLabel)
            .chartYAxisLabel(yLabel)
            .chartXAxis {
                AxisMarks(position: .bottom)
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 250)
            .background(Color.white) // <-- Graph background white too
            .cornerRadius(10)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        yZoom = value.magnitude
                    }
            )
            .shadow(color: Color.gray.opacity(0.3), radius: 4, x: 0, y: 2) // optional subtle shadow
        }
    }

    private func scaledRange() -> ClosedRange<Double> {
        let center = (yAxisRange.lowerBound + yAxisRange.upperBound) / 2
        let halfRange = (yAxisRange.upperBound - yAxisRange.lowerBound) / 2 / Double(yZoom)
        return (center - halfRange)...(center + halfRange)
    }
}

struct Run2View: View {
    @State private var isT3Disabled = false
    @State private var isT4Disabled = false
    
    //T3 Oral Dose Inputs
    @State private var showT3OralDose = false
    @AppStorage("T3OralDoseInput") private var T3OralDoseInput: String = ""
    @AppStorage("T3OralDoseStart") private var T3OralDoseStart: String = ""
    @AppStorage("T3OralDoseEnd") private var T3OralDoseEnd: String = ""
    @AppStorage("T3OralDoseInterval") private var T3OralDoseInterval: String = ""
    
    //T3 IV Dose Inputs
    @State private var showT3IVDose = false
    @AppStorage("T3IVDoseInput") private var T3IVDoseInput: String = ""
    @AppStorage("T3IVDoseStart") private var T3IVDoseStart: String = ""
    
    //T3 Infusion Dose Inputs
    @State private var showT3InfusionDose = false
    @AppStorage("T3InfusionDoseInput") private var T3InfusionDoseInput: String = ""
    @AppStorage("T3InfusionDoseStart") private var T3InfusionDoseStart: String = ""
    @AppStorage("T3InfusionDoseEnd") private var T3InfusionDoseEnd: String = ""
    
    //T4 Oral Dose Inputs
    @State private var showT4OralDose = false
    @AppStorage("T4OralDoseInput") private var T4OralDoseInput: String = ""
    @AppStorage("T4OralDoseStart") private var T4OralDoseStart: String = ""
    @AppStorage("T4OralDoseEnd") private var T4OralDoseEnd: String = ""
    @AppStorage("T4OralDoseInterval") private var T4OralDoseInterval: String = ""
    
    //T4 IV dose Inputs
    @State private var showT4IVDose = false
    @AppStorage("T4IVDoseInput") private var T4IVDoseInput: String = ""
    @AppStorage("T4IVDoseStart") private var T4IVDoseStart: String = ""
    
    //T4 Infusion Dose Inputs
    @State private var showT4InfusionDose = false
    @AppStorage("T4InfusionDoseInput") private var T4InfusionDoseInput: String = ""
    @AppStorage("T4InfusionDoseStart") private var T4InfusionDoseStart: String = ""
    @AppStorage("T4InfusionDoseEnd") private var T4InfusionDoseEnd: String = ""

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(edges: [.top, .horizontal]) // Respect bottom safe area

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Adjust Dose Quantity & Frequency for RUN 2")
                        .font(.title2.bold())

                    HStack(alignment: .top, spacing: 40) {
                        VStack(alignment: .center, spacing: 16) {
                            Text("T3 Input:")
                                .font(.headline)
                            VStack(spacing: 12) {
                                Button(action: {
                                    showT3OralDose.toggle()
                                  }) {
                                      VStack{
                                          Image("pill1")
                                          Text("Oral Dose")
                                      }
                                  }
                                Button(action: {
                                    showT3IVDose.toggle()
                                  }) {
                                      VStack{
                                          Image("syringe1")
                                          Text("IV Bolus Dose")
                                      }
                                  }
                                Button(action: {
                                    showT3InfusionDose.toggle()
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
                                    showT4OralDose.toggle()
                                  }) {
                                      VStack{
                                          Image("pill2")
                                          Text("Oral Dose")
                                      }
                                  }
                                Button(action: {
                                    showT4IVDose.toggle()
                                  }) {
                                      VStack{
                                          Image("syringe2")
                                          Text("IV Bolus Dose")
                                      }
                                  }
                                Button(action: {
                                    showT4InfusionDose.toggle()
                                  }) {
                                      VStack{
                                          Image("infusion2")
                                          Text("Infusion Dose")
                                      }
                                  }
  
                            }
                        }
                    }

                    Text("Click the above icons to add as input, which can be any combination of T3 and T4. Results will be superimposed on Run 1 Simulation. ")
                        .font(.body)
                        .foregroundColor(.gray)


                    
                    //Each input
                    
                    VStack(alignment: .trailing, spacing: 12){
                        //T3OralDose
                        if showT3OralDose {
                            HStack(alignment:.center, spacing: 10) {
                                VStack(alignment: .leading, spacing: 20) {
                                    HStack(alignment: .center, spacing: 10)
                                    {
                                        Image("pill1")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                        Text("T3-ORAL DOSE")
                                            .font(.title3.bold())
                                    }
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack(alignment: .center, spacing: nil) {
                                            Text("Dose (µg)")
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            Step2InputField(title: "", value: $T3OralDoseInput)
                                                .multilineTextAlignment(.trailing)
                                        }
                                        
                                        HStack(alignment: .center, spacing: 10) {
                                            Text("Dose Start Day or Time")
                                            Step2InputField(title: "", value: $T3OralDoseStart)
                                        }
                                       
                                        Spacer()
                                        HStack(alignment: .center, spacing: 10) {
                                            Text("Use Single Dose")
                                            Spacer()
                                            Toggle("turn off", isOn: $isT3Disabled)
                                                .labelsHidden()
                                                .toggleStyle(SwitchToggleStyle(tint: .white))
                                            Spacer()
                                        }
                                        

                                        if !isT3Disabled {
                                            HStack(alignment: .center, spacing: 10) {
                                                VStack(alignment: .leading, spacing: 10) {
                                                    Text("Dose End Day or Time")
                                                    Text("E.g. Start (or End) dosing on Day 3, or Day 0.5 or Day 2.8 etc.")
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                }
                                                Step2InputField(title: "", value: $T3OralDoseEnd)
                                            }
                                            HStack(alignment: .center, spacing: 10) {
                                                VStack(alignment: .leading, spacing: 10) {
                                                    Text("Dosing Interval (days)")
                                                    Text("E.g. 1, if daily dosing, 0.5 if twice-daily dosing, etc")
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                }
                                                Step2InputField(title: "", value: $T3OralDoseInterval)
                                        }
                                    }
                                    }
                                }
                                Button(action: {
                                    showT3OralDose.toggle()
                                  }) {
                                      VStack{
                                          Image("delete")
                                      }
                                  }
                                .padding(.bottom)
                            }
                            .padding()
                        }
                        
                        //T3IV Dose
                        if showT3IVDose {
                            HStack(alignment:.center, spacing: 10) {
                                VStack(alignment: .leading, spacing: 20) {
                                    HStack(alignment: .center, spacing: 10)
                                    {
                                        Image("syringe1")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                        Text("T3-IV DOSE")
                                            .font(.title3.bold())
                                    }
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack(alignment: .center, spacing: nil) {
                                            Text("Dose (µg)")
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            Step2InputField(title: "", value: $T3IVDoseInput)
                                                .multilineTextAlignment(.trailing)
                                        }
                                        
                                        HStack(alignment: .center, spacing: 10) {
                                            Text("Dose Start Day or Time")
                                            Step2InputField(title: "", value: $T3IVDoseStart)
                                        }
                                    }
                                }
                                Button(action: {
                                    showT3IVDose.toggle()
                                  }) {
                                      VStack{
                                          Image("delete")
                                      }
                                  }
                                .padding(.bottom)
                            }
                            .padding()
                        }
                        
                        //T3 Infusion Dose
                        if showT3InfusionDose {
                            HStack(alignment:.center, spacing: 10) {
                                VStack(alignment: .leading, spacing: 20) {
                                    HStack(alignment: .center, spacing: 10)
                                    {
                                        Image("infusion1")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                        Text("T3-INFUSION DOSE")
                                            .font(.title3.bold())
                                    }
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack(alignment: .center, spacing: nil) {
                                            Text("Dose (µg)")
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            Step2InputField(title: "", value: $T3InfusionDoseInput)
                                                .multilineTextAlignment(.trailing)
                                        }
                                        HStack(alignment: .center, spacing: 10) {
                                            Text("Dose Start Day or Time")
                                            Step2InputField(title: "", value: $T3InfusionDoseStart)
                                        }
                                        HStack(alignment: .center, spacing: 10) {
                                            VStack(alignment: .leading, spacing: 10) {
                                                Text("Dose End Day or Time")
                                                Text("E.g. Start (or End) dosing on Day 3, or Day 0.5 or Day 2.8 etc.")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                                Step2InputField(title: "", value: $T3InfusionDoseEnd)
                                        }
                                    }
                                }
                                Button(action: {
                                    showT3InfusionDose.toggle()
                                  }) {
                                      VStack{
                                          Image("delete")
                                      }
                                  }
                                .padding(.bottom)
                            }
                            .padding()
                        }
                        
                        //T4 Oral Dose
                        if showT4OralDose {
                            HStack(alignment:.center, spacing: 10) {
                                VStack(alignment: .leading, spacing: 20) {
                                    HStack(alignment: .center, spacing: 10)
                                    {
                                        Image("pill2")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                        Text("T4-ORAL DOSE")
                                            .font(.title3.bold())
                                    }
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack(alignment: .center, spacing: nil) {
                                            Text("Dose (µg)")
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            Step2InputField(title: "", value: $T4OralDoseInput)
                                                .multilineTextAlignment(.trailing)
                                        }
                                        
                                        HStack(alignment: .center, spacing: 10) {
                                            Text("Dose Start Day or Time")
                                            Step2InputField(title: "", value: $T4OralDoseStart)
                                        }
                                       
                                        Spacer()
                                        HStack(alignment: .center, spacing: 10) {
                                            Text("Use Single Dose")
                                            Spacer()
                                            Toggle("turn off", isOn: $isT4Disabled)
                                                .labelsHidden()
                                                .toggleStyle(SwitchToggleStyle(tint: .white))
                                            Spacer()
                                        }
                                        
                                        if !isT4Disabled {
                                            HStack(alignment: .center, spacing: 10) {
                                                VStack(alignment: .leading, spacing: 10) {
                                                    Text("Dose End Day or Time")
                                                    Text("E.g. Start (or End) dosing on Day 3, or Day 0.5 or Day 2.8 etc.")
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                }
                                                Step2InputField(title: "", value: $T4OralDoseEnd)
                                            }
                                            HStack(alignment: .center, spacing: 10) {
                                                VStack(alignment: .leading, spacing: 10) {
                                                    Text("Dosing Interval (days)")
                                                    Text("E.g. 1, if daily dosing, 0.5 if twice-daily dosing, etc")
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                }
                                                Step2InputField(title: "", value: $T4OralDoseInterval)
                                        }
                                    }
                                    }
                                }
                                Button(action: {
                                    showT4OralDose.toggle()
                                  }) {
                                      VStack{
                                          Image("delete")
                                      }
                                  }
                                .padding(.bottom)
                            }
                            .padding()
                        }
                        
                        //T4IV Dose
                        if showT4IVDose {
                            HStack(alignment:.center, spacing: 10) {
                                VStack(alignment: .leading, spacing: 20) {
                                    HStack(alignment: .center, spacing: 10)
                                    {
                                        Image("syringe2")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                        Text("T4-IV DOSE")
                                            .font(.title3.bold())
                                    }
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack(alignment: .center, spacing: nil) {
                                            Text("Dose (µg)")
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            Step2InputField(title: "", value: $T4IVDoseInput)
                                                .multilineTextAlignment(.trailing)
                                        }
                                        
                                        HStack(alignment: .center, spacing: 10) {
                                            Text("Dose Start Day or Time")
                                            Step2InputField(title: "", value: $T4IVDoseStart)
                                        }
                                    }
                                }
                                Button(action: {
                                    showT4IVDose.toggle()
                                  }) {
                                      VStack{
                                          Image("delete")
                                      }
                                  }
                                .padding(.bottom)
                            }
                            .padding()
                        }
                        
                        //T4 Infusion Dose
                        if showT4InfusionDose {
                            HStack(alignment:.center, spacing: 10) {
                                VStack(alignment: .leading, spacing: 20) {
                                    HStack(alignment: .center, spacing: 10)
                                    {
                                        Image("infusion2")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                        Text("T4-INFUSION DOSE")
                                            .font(.title3.bold())
                                    }
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack(alignment: .center, spacing: nil) {
                                            Text("Dose (µg)")
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            Step2InputField(title: "", value: $T4InfusionDoseInput)
                                                .multilineTextAlignment(.trailing)
                                        }
                                        
                                        HStack(alignment: .center, spacing: 10) {
                                            Text("Dose Start Day or Time")
                                            Step2InputField(title: "", value: $T4InfusionDoseStart)
                                        }
                                        
                                        HStack(alignment: .center, spacing: 10) {
                                            VStack(alignment: .leading, spacing: 10) {
                                                Text("Dose End Day or Time")
                                                Text("E.g. Start (or End) dosing on Day 3, or Day 0.5 or Day 2.8 etc.")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                                Step2InputField(title: "", value: $T4InfusionDoseEnd)
                                        }
                                    }
                                }
                                Button(action: {
                                    showT4InfusionDose.toggle()
                                  }) {
                                      VStack{
                                          Image("delete")
                                      }
                                  }
                                .padding(.bottom)
                            }
                            .padding()
                        }
                        Button(action: {
                            showT4InfusionDose.toggle()
                          }) {
                              VStack{
                                  Text("Run 2")
                              }
                          }
                    }
                    Spacer().frame(height: 80) // Leave space for navigation bar
                }
                .padding()
                .foregroundColor(.white)
            }
        }
    }
}


struct Run2InputField: View {
    var title: String
    @Binding var value: String

    var body: some View {
        VStack(alignment: .trailing, spacing: 5) {
            Text(title)
                .font(.callout)
                .foregroundColor(.white)
            TextField("", text: $value)
                .frame(width: 100)
                .padding(10)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                .foregroundColor(.white)
                .fixedSize(horizontal:true, vertical: true)
        }
        .padding(.horizontal)
    }

}






