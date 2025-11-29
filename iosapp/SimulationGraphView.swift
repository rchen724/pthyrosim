import SwiftUI
import Charts

private enum HormoneType: String, CaseIterable {
    case free = "Free"
    case total = "Total"
}

struct SimulationGraphView: View {
    let result: ThyroidSimulationResult
    let simulationDurationDays: Int

    @State private var selectedHormoneType: HormoneType = .free
    @State private var showNormalRange: Bool = true
    
    @State private var pdfURL: URL?
    @State private var showShareSheet = false
    
    // AppStorage variables to retrieve simulation conditions
    @AppStorage("t4Secretion") private var t4Secretion: String = "100"
    @AppStorage("t3Secretion") private var t3Secretion: String = "100"
    @AppStorage("t4Absorption") private var t4Absorption: String = "88"
    @AppStorage("t3Absorption") private var t3Absorption: String = "88"
    @AppStorage("height") private var height: String = "170"
    @AppStorage("weight") private var weight: String = "70"
    @AppStorage("selectedHeightUnit") private var selectedHeightUnit: String = "cm"
    @AppStorage("selectedWeightUnit") private var selectedWeightUnit: String = "kg"
    @AppStorage("selectedGender") private var selectedGender: String = "FEMALE"
    @AppStorage("isInitialConditionsOn") private var isInitialConditionsOn: Bool = true

    @State private var testURL: URL?
    @State private var showTestShare = false
    @Environment(\.presentationMode) var presentationMode

    // --- CORRECTED VIEW FOR PDF EXPORT ---
    // This view now contains ONLY the elements we want in the PDF, excluding the problematic UI controls.
    private var viewToRender: some View {
        VStack(spacing: 20) {
            Text("Run 1 Simulation")
                .font(.title).fontWeight(.bold).padding(.top)

            SimulationConditionsView(
                t4Secretion: t4Secretion,
                t3Secretion: t3Secretion,
                t4Absorption: t4Absorption,
                t3Absorption: t3Absorption,
                height: height,
                weight: weight,
                heightUnit: selectedHeightUnit,
                weightUnit: selectedWeightUnit,
                gender: selectedGender,
                simulationDays: String(simulationDurationDays),
                isInitialConditionsOn: isInitialConditionsOn
            )

            let effectiveXAxisRange: ClosedRange<Double> = 0...Double(max(1, simulationDurationDays))
            
            GraphSection(
                title: selectedHormoneType == .free ? "Free T4" : "T4",
                yLabel: selectedHormoneType == .free ? "FT4 (ng/dL)" : "T4 (µg/L)",
                xLabel: "Days",
                values: t4GraphData,
                color: .blue,
                yAxisRange: calculateYAxisDomain(for: t4GraphData.map { $0.1 }, title: selectedHormoneType == .free ? "Free T4" : "T4"),
                xAxisRange: effectiveXAxisRange,
                showNormalRange: $showNormalRange
            )

            GraphSection(
                title: selectedHormoneType == .free ? "Free T3" : "T3",
                yLabel: selectedHormoneType == .free ? "FT3 (pg/mL)" : "T3 (ng/dL)",
                xLabel: "Days",
                values: t3GraphData,
                color: .blue,
                yAxisRange: calculateYAxisDomain(for: t3GraphData.map { $0.1 }, title: selectedHormoneType == .free ? "Free T3" : "T3"),
                xAxisRange: effectiveXAxisRange,
                showNormalRange: $showNormalRange
            )

            GraphSection(
                title: "TSH",
                yLabel: "TSH (mU/L)",
                xLabel: "Days",
                values: tshGraphData,
                color: .blue,
                yAxisRange: calculateYAxisDomain(for: tshGraphData.map { $0.1 }, title: "TSH"),
                xAxisRange: effectiveXAxisRange,
                showNormalRange: $showNormalRange
            )
        }
        .padding()
        .foregroundColor(.black)
        .background(Color.white) // Ensure a solid white background for the PDF
    }

    // The body of the view remains the same for display on the screen
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 10) {

                    VStack(spacing: 6) {              // was 15
                        Picker("Hormone Type", selection: $selectedHormoneType) {
                            ForEach(HormoneType.allCases, id: \.self) { Text($0.rawValue) }
                        }
                        .pickerStyle(.segmented)
                        .controlSize(.small)          // smaller segmented control
                        .padding(.horizontal, 8)      // was full .padding(.horizontal)

                        Text("Normal ranges shown in yellow below")
                            .font(.footnote).fontWeight(.bold)
                            .padding(.top, 2)         // was more implicit spacing
                    }
                    .padding(.vertical, 4)            // was 10

                    

                    let effectiveXAxisRange: ClosedRange<Double> = 0...Double(max(1, simulationDurationDays))
                    
                    let sectionHeight: CGFloat = 150
                    let lineWidth: CGFloat = 1.2

                    GraphSection(
                        title: selectedHormoneType == .free ? "Free T4" : "T4",
                        yLabel: selectedHormoneType == .free ? "FT4 (ng/dL)" : "T4 (µg/L)",
                        xLabel: "Days",
                        values: t4GraphData,
                        color: .blue,
                        yAxisRange: calculateYAxisDomain(for: t4GraphData.map { $0.1 }, title: selectedHormoneType == .free ? "Free T4" : "T4"),
                        xAxisRange: effectiveXAxisRange,
                        height: sectionHeight,          // NEW
                        lineWidth: lineWidth,           // NEW
                        showNormalRange: $showNormalRange
                    )

                    GraphSection(
                        title: selectedHormoneType == .free ? "Free T3" : "T3",
                        yLabel: selectedHormoneType == .free ? "FT3 (ng/dL)" : "T3 (ng/dL)",
                        xLabel: "Days",
                        values: t3GraphData,
                        color: .blue,
                        yAxisRange: calculateYAxisDomain(for: t3GraphData.map { $0.1 }, title: selectedHormoneType == .free ? "Free T3" : "T3"),
                        xAxisRange: effectiveXAxisRange,
                        height: sectionHeight,          // NEW
                        lineWidth: lineWidth,           // NEW
                        showNormalRange: $showNormalRange
                    )

                    GraphSection(
                        title: "TSH",
                        yLabel: "TSH (mU/L)",
                        xLabel: "Days",
                        values: tshGraphData,
                        color: .blue,
                        yAxisRange: calculateYAxisDomain(for: tshGraphData.map { $0.1 }, title: "TSH"),
                        xAxisRange: effectiveXAxisRange,
                        height: sectionHeight,          // NEW
                        lineWidth: lineWidth,           // NEW
                        showNormalRange: $showNormalRange
                    )
                }
                .padding()
                .foregroundColor(.black)
            }
        }
        .navigationTitle("Run 1 Simulation")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Make Changes")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // --- CORRECTED BUTTON ACTION ---
                    // Use a Task to run the async PDF rendering
                    Task {
                        // 'await' waits for the function to finish and return the URL
                        let url = await renderViewToPDF(view: viewToRender)
                        self.pdfURL = url
                        self.showShareSheet = true
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let pdfURL {
                ShareSheet(activityItems: [pdfURL])
            }
        }
    }

    // Helper functions remain the same
    private var t4GraphData: [(Double, Double)] {
        let sourceData = selectedHormoneType == .free ? result.ft4 : result.t4
        return zip(result.time, sourceData).filter { $0.1.isFinite }
    }
    private var t3GraphData: [(Double, Double)] {
        let sourceData = selectedHormoneType == .free ? result.ft3 : result.t3
        return zip(result.time, sourceData).filter { $0.1.isFinite }
    }
    private var tshGraphData: [(Double, Double)] {
        return zip(result.time, result.tsh).filter { $0.1.isFinite }
    }
    private func getNormalRange(for hormone: String) -> ClosedRange<Double>? {
        switch hormone {
        case "T4": return 50.0...120.0
        case "Free T4": return 10.0...25.0
        case "T3": return 0.8...1.8
        case "Free T3": return 2.3...4.2
        case "TSH": return 0.4...4.5
        default: return nil
        }
    }
    private func dynamicRange(for values: [Double]) -> ClosedRange<Double> {
        guard let minVal = values.min(), let maxVal = values.max() else { return 0...1 }
        if minVal == maxVal {
            let buffer = abs(minVal * 0.1) > 0 ? abs(minVal * 0.1) : 1.0
            return (minVal - buffer)...(maxVal + buffer)
        }
        let buffer = (maxVal - minVal) * 0.1
        return (minVal - buffer)...(maxVal + buffer)
    }
    
    private func calculateYAxisDomain(for values: [Double], title: String) -> ClosedRange<Double> {
        let dataRange = dynamicRange(for: values)
        var upperBound: Double
        if showNormalRange, let normalRange = getNormalRange(for: title) {
            upperBound = max(dataRange.upperBound, normalRange.upperBound)
        } else {
            upperBound = dataRange.upperBound
        }
        let padding = abs(upperBound) * 0.05
        return 0...(upperBound + padding)
    }
}
