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
    @State private var activePopup: ActivePopup? = nil
    @State private var selectedT3input: T3OralDose? = nil
    
    @State private var run2t3oralinputs: [T3OralDose] = []
    @State private var run2t3ivinputs: [T3IVDose] = []
    @State private var run2t3infusioninputs: [T3InfusionDose] = []
    
    @State private var run2t4oralinputs: [T4OralDose] = []
    @State private var run2t4ivinputs: [T4IVDose] = []
    @State private var run2t4infusioninputs: [T4InfusionDose] = []
    
    var enumeratedT3Oral: [(Int, T3OralDose)] {
        Array(run2t3oralinputs.enumerated())
    }
    
    var enumeratedT3IV: [(Int, T3IVDose)] {
        Array(run2t3ivinputs.enumerated())
    }
    
    var enumeratedT3Infusion: [(Int, T3InfusionDose)] {
        Array(run2t3infusioninputs.enumerated())
    }
    
    var enumeratedT4Oral: [(Int, T4OralDose)] {
        Array(run2t4oralinputs.enumerated())
    }
    
    var enumeratedT4IV: [(Int, T4IVDose)] {
        Array(run2t4ivinputs.enumerated())
    }
    
    var enumeratedT4Infusion: [(Int, T4InfusionDose)] {
        Array(run2t4infusioninputs.enumerated())
    }
    
    var body: some View {
        ZStack{
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Adjust Simulated Dosing Experiment for RUN 2")
                        .font(.title2.bold())
                    
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
                    
                    Text("Click the above icons to add as input, which can be any combination of T3 and T4. Results will be superimposed on Run 1 Simulation")
                        .font(.body)
                        .foregroundColor(.gray)

    
                    if !run2t3oralinputs.isEmpty {
                        
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
                                        if let index = run2t3oralinputs.firstIndex(where: { $0.id == t3oral.id }) {
                                            run2t3oralinputs.remove(at: index)
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
                    
                    if !run2t3ivinputs.isEmpty {
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
                                        if let index = run2t3ivinputs.firstIndex(where: { $0.id == t3iv.id }) {
                                            run2t3ivinputs.remove(at: index)
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
                    
                    if !run2t3infusioninputs.isEmpty {
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
                                        if let index = run2t3infusioninputs.firstIndex(where: { $0.id == t3infusion.id }) {
                                            run2t3infusioninputs.remove(at: index)
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
                    if !run2t4oralinputs.isEmpty {
                        
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
                                        if let index = run2t4oralinputs.firstIndex(where: { $0.id == t4oral.id }) {
                                            run2t4oralinputs.remove(at: index)
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
                    
                    if !run2t4ivinputs.isEmpty {
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
                                        if let index = run2t4ivinputs.firstIndex(where: { $0.id == t4iv.id }) {
                                            run2t4ivinputs.remove(at: index)
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
                    
                    if !run2t4infusioninputs.isEmpty {
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
                                        if let index = run2t4infusioninputs.firstIndex(where: { $0.id == t4infusion.id }) {
                                            run2t4infusioninputs.remove(at: index)
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
                    run2t3oralinputs.append(newT3Oral)
                    activePopup = nil
                }
            case .T3IVInputs:
                T3IVPopupView { newT3IV in
                    run2t3ivinputs.append(newT3IV)
                    activePopup = nil
                }
            case .T3InfusionInputs:
                T3InfusionPopupView { newT3Infusion in
                    run2t3infusioninputs.append(newT3Infusion)
                    activePopup = nil
                }
                
            case .T4OralInputs:
                T4OralPopupView { newT4Oral in
                    run2t4oralinputs.append(newT4Oral)
                    activePopup = nil
                }
            case .T4IVInputs:
                T4IVPopupView { newT4IV in
                    run2t4ivinputs.append(newT4IV)
                    activePopup = nil
                }
            case .T4InfusionInputs:
                T4InfusionPopupView { newT4Infusion in
                    run2t4infusioninputs.append(newT4Infusion)
                    activePopup = nil
                }
                
            }
            
        }
        .background(Color.black.ignoresSafeArea())
    
    }
}

struct Run2InputField: View {
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




