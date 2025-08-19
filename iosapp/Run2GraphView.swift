import SwiftUI
import Charts

struct Run2GraphView: View {
    private enum HormoneType: String, CaseIterable {
        case total = "Total"
        case free = "Free"
    }
    
    let run2Result: ThyroidSimulationResult
    let simulationDurationDays: Int

    @State private var selectedHormoneType: HormoneType = .free
    @State private var showNormalRange: Bool = true
    
    @State private var pdfURL: URL?
    @State private var showShareSheet = false

    // --- CORRECTED VIEW FOR PDF EXPORT ---
    private var viewToRender: some View {
        VStack(spacing: 20) {
            Text("Dosing Simulation Results")
                .font(.title2).bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            let effectiveXAxisRange: ClosedRange<Double> = 0...Double(max(1, simulationDurationDays))

            GraphSection(
                title: selectedHormoneType == .free ? "Free T4" : "T4",
                yLabel: selectedHormoneType == .free ? "FT4 (ng/dL)" : "T4 (µg/L)",
                xLabel: "Days",
                values: t4GraphData_Run2,
                color: .green,
                yAxisRange: calculateYAxisDomain(for: t4GraphData_Run2.map { $0.1 }, title: selectedHormoneType == .free ? "Free T4" : "T4"),
                xAxisRange: effectiveXAxisRange,
                showNormalRange: $showNormalRange
            )

            GraphSection(
                title: selectedHormoneType == .free ? "Free T3" : "T3",
                yLabel: selectedHormoneType == .free ? "FT3 (pg/mL)" : "T3 (ng/dL)",
                xLabel: "Days",
                values: t3GraphData_Run2,
                color: .green,
                yAxisRange: calculateYAxisDomain(for: t3GraphData_Run2.map { $0.1 }, title: selectedHormoneType == .free ? "Free T3" : "T3"),
                xAxisRange: effectiveXAxisRange,
                showNormalRange: $showNormalRange
            )

            GraphSection(
                title: "TSH",
                yLabel: "TSH (mU/L)",
                xLabel: "Days",
                values: tshGraphData_Run2,
                color: .green,
                yAxisRange: calculateYAxisDomain(for: tshGraphData_Run2.map { $0.1 }, title: "TSH"),
                xAxisRange: effectiveXAxisRange,
                showNormalRange: $showNormalRange
            )
        }
        .padding()
        .background(Color.white)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Dosing Simulation Results")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 15) {
                    Picker("Hormone Type", selection: $selectedHormoneType) {
                        ForEach(HormoneType.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Text("Normal ranges shown in yellow")
                        .font(.footnote)
                        .fontWeight(.bold)

                    //Toggle("Show Normal Range", isOn: $showNormalRange)
                }
                
                let effectiveXAxisRange: ClosedRange<Double> = 0...Double(max(1, simulationDurationDays))

                GraphSection(
                    title: selectedHormoneType == .free ? "Free T4" : "T4",
                    yLabel: selectedHormoneType == .free ? "FT4 (ng/dL)" : "T4 (µg/L)",
                    xLabel: "Days",
                    values: t4GraphData_Run2,
                    color: .green,
                    yAxisRange: calculateYAxisDomain(for: t4GraphData_Run2.map { $0.1 }, title: selectedHormoneType == .free ? "Free T4" : "T4"),
                    xAxisRange: effectiveXAxisRange,
                    showNormalRange: $showNormalRange
                )

                GraphSection(
                    title: selectedHormoneType == .free ? "Free T3" : "T3",
                    yLabel: selectedHormoneType == .free ? "FT3 (pg/mL)" : "T3 (ng/dL)",
                    xLabel: "Days",
                    values: t3GraphData_Run2,
                    color: .green,
                    yAxisRange: calculateYAxisDomain(for: t3GraphData_Run2.map { $0.1 }, title: selectedHormoneType == .free ? "Free T3" : "T3"),
                    xAxisRange: effectiveXAxisRange,
                    showNormalRange: $showNormalRange
                )

                GraphSection(
                    title: "TSH",
                    yLabel: "TSH (mU/L)",
                    xLabel: "Days",
                    values: tshGraphData_Run2,
                    color: .green,
                    yAxisRange: calculateYAxisDomain(for: tshGraphData_Run2.map { $0.1 }, title: "TSH"),
                    xAxisRange: effectiveXAxisRange,
                    showNormalRange: $showNormalRange
                )
            }
            .padding()
        }
        .navigationTitle("Dosing Simulation")
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
    private var t4GraphData_Run2: [(Double, Double)] {
        let sourceData = selectedHormoneType == .free ? run2Result.ft4 : run2Result.t4
        return zip(run2Result.time, sourceData).filter { $0.1.isFinite }
    }
    private var t3GraphData_Run2: [(Double, Double)] {
        let sourceData = selectedHormoneType == .free ? run2Result.ft3 : run2Result.t3
        return zip(run2Result.time, sourceData).filter { $0.1.isFinite }
    }
    private var tshGraphData_Run2: [(Double, Double)] {
        return zip(run2Result.time, run2Result.tsh).filter { $0.1.isFinite }
    }
    private func getNormalRange(for hormone: String) -> ClosedRange<Double>? {
        switch hormone {
        case "T4": return 50.0...120.0
        case "Free T4": return 8...18
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
