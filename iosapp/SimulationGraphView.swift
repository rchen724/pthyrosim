import SwiftUI
import Charts

struct SimulationGraphView: View {
    let result: ThyroidSimulationResult
    let simulationDurationDays: Int

    @State private var showFreeHormones: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Run 1 Results")
                    .font(.largeTitle).fontWeight(.bold).padding(.top)

                Toggle(isOn: $showFreeHormones) {
                    Text("Show Free Hormones")
                }.padding(.horizontal).toggleStyle(SwitchToggleStyle(tint: .blue))

                let effectiveXAxisRange: ClosedRange<Double> = 0...Double(max(1, simulationDurationDays))
                
                let t4Data = showFreeHormones ? result.ft4 : result.t4
                let t3Data = showFreeHormones ? result.ft3 : result.t3

                GraphSection(
                    title: showFreeHormones ? "Free T4" : "T4",
                    yLabel: showFreeHormones ? "FT4 (µg/L)" : "T4 (µg/L)",
                    xLabel: "Days",
                    values: result.time.indices.map { (result.time[$0], t4Data[$0]) },
                    color: .blue,
                    yAxisRange: calculateYAxisDomain(for: t4Data, title: showFreeHormones ? "Free T4" : "T4"),
                    xAxisRange: effectiveXAxisRange
                )

                GraphSection(
                    title: showFreeHormones ? "Free T3" : "T3",
                    yLabel: showFreeHormones ? "FT3 (µg/L)" : "T3 (µg/L)",
                    xLabel: "Days",
                    values: result.time.indices.map { (result.time[$0], t3Data[$0]) },
                    color: .green,
                    yAxisRange: calculateYAxisDomain(for: t3Data, title: showFreeHormones ? "Free T3" : "T3"),
                    xAxisRange: effectiveXAxisRange
                )

                GraphSection(
                    title: "TSH",
                    yLabel: "TSH (mU/L)",
                    xLabel: "Days",
                    values: result.time.indices.map { (result.time[$0], result.tsh[$0]) },
                    color: .red,
                    yAxisRange: calculateYAxisDomain(for: result.tsh, title: "TSH"),
                    xAxisRange: effectiveXAxisRange
                )
            }
            .padding()
        }
        .navigationTitle("Simulation Results (Run 1)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: Run2View(run1Result: result)) {
                    Text("Compare (Run 2)")
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
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
        guard let minVal = values.min(), let maxVal = values.max(), minVal <= maxVal else {
            let defaultVal = values.first ?? 0.0
            return (defaultVal - 1)...(defaultVal + 1)
        }
        if minVal == maxVal {
            return (minVal - 1)...(maxVal + 1)
        }
        let buffer = (maxVal - minVal) * 0.1
        let effectiveBuffer = buffer > 0 ? buffer : 1.0
        
        let lower = minVal - effectiveBuffer
        let upper = maxVal + effectiveBuffer
        
        return (minVal >= 0 && lower < 0 ? 0 : lower)...upper
    }
    
    // **NEW**: This function calculates a Y-axis that includes both the data's range and the fixed normal range.
    private func calculateYAxisDomain(for values: [Double], title: String) -> ClosedRange<Double> {
        let dataRange = dynamicRange(for: values)
        
        guard let normalRange = getNormalRange(for: title) else {
            return dataRange
        }
        
        let lowerBound = min(dataRange.lowerBound, normalRange.lowerBound)
        let upperBound = max(dataRange.upperBound, normalRange.upperBound)
        
        // Add a small padding to the final combined range
        let padding = (upperBound - lowerBound) * 0.05
        
        return (lowerBound - padding)...(upperBound + padding)
    }
}
