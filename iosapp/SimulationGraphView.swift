import SwiftUI
import Charts

private enum HormoneType: String, CaseIterable {
    case total = "Total"
    case free = "Free"
}

struct SimulationGraphView: View {
    let result: ThyroidSimulationResult
    let simulationDurationDays: Int

    @State private var selectedHormoneType: HormoneType = .total
    @State private var showNormalRange: Bool = true
    
    @State private var pdfURL: URL?
    @State private var showShareSheet = false

    // --- CORRECTED VIEW FOR PDF EXPORT ---
    // This view now contains ONLY the elements we want in the PDF, excluding the problematic UI controls.
    private var viewToRender: some View {
        VStack(spacing: 20) {
            Text("Euthyroid Simulation")
                .font(.largeTitle).fontWeight(.bold).padding(.top)

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
                VStack(spacing: 20) {
                    Text("Euthyroid Simulation")
                        .font(.largeTitle).fontWeight(.bold).padding(.top)

                    VStack(spacing: 15) {
                        Picker("Hormone Type", selection: $selectedHormoneType) {
                            ForEach(HormoneType.allCases, id: \.self) { Text($0.rawValue) }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)

                        //Toggle(isOn: $showNormalRange) {
                        //    Text("Show Normal Range").fontWeight(.medium)
                        //}
                        //.padding(.horizontal)
                        Text("Normal ranges shown in yellow below")
                        .font(.footnote)
                        .fontWeight(.bold)
                        
                    }
                    .padding(.vertical, 10)

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
            }
        }
        .navigationTitle("Euthyroid Simulation")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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
