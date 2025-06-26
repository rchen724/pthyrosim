import SwiftUI
import Charts

struct Run2GraphView: View {
    let run1Result: ThyroidSimulationResult
    let run2Result: ThyroidSimulationResult
    let simulationDurationDays: Int

    // **FIX**: Default to showing free hormones
    @State private var showFreeHormones: Bool = true
    @State private var showNormalRange: Bool = true

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text("Comparison of Hormone Levels")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Toggle("Show Free Hormones", isOn: $showFreeHormones)
                    Toggle("Show Normal Range", isOn: $showNormalRange)
                }
                .padding(.bottom, 10)
                
                let effectiveXAxisRange: ClosedRange<Double> = 0...Double(max(1, simulationDurationDays))

                let t4Data1 = showFreeHormones ? run1Result.ft4 : run1Result.t4
                let t4Data2 = showFreeHormones ? run2Result.ft4 : run2Result.t4
                
                let t3Data1 = showFreeHormones ? run1Result.ft3 : run1Result.t3
                let t3Data2 = showFreeHormones ? run2Result.ft3 : run2Result.t3
                
                let tshData1 = run1Result.tsh
                let tshData2 = run2Result.tsh

                GraphSection(
                    title: showFreeHormones ? "Free T4" : "T4",
                    yLabel: showFreeHormones ? "FT4 (ng/dL)" : "T4 (µg/L)",
                    xLabel: "Days",
                    values: run1Result.time.indices.map { (run1Result.time[$0], t4Data1[$0]) },
                    color: .blue,
                    secondaryValues: run2Result.time.indices.map { (run2Result.time[$0], t4Data2[$0]) },
                    secondaryColor: .cyan,
                    yAxisRange: calculateYAxisDomain(for: t4Data1 + t4Data2, title: showFreeHormones ? "Free T4" : "T4"),
                    xAxisRange: effectiveXAxisRange,
                    showNormalRange: $showNormalRange
                )

                GraphSection(
                    title: showFreeHormones ? "Free T3" : "T3",
                    yLabel: showFreeHormones ? "FT3 (pg/mL)" : "T3 (ng/dL)",
                    xLabel: "Days",
                    values: run1Result.time.indices.map { (run1Result.time[$0], t3Data1[$0]) },
                    color: .green,
                    secondaryValues: run2Result.time.indices.map { (run2Result.time[$0], t3Data2[$0]) },
                    secondaryColor: .mint,
                    yAxisRange: calculateYAxisDomain(for: t3Data1 + t3Data2, title: showFreeHormones ? "Free T3" : "T3"),
                    xAxisRange: effectiveXAxisRange,
                    showNormalRange: $showNormalRange
                )

                GraphSection(
                    title: "TSH",
                    yLabel: "TSH (mU/L)",
                    xLabel: "Days",
                    values: run1Result.time.indices.map { (run1Result.time[$0], tshData1[$0]) },
                    color: .red,
                    secondaryValues: run2Result.time.indices.map { (run2Result.time[$0], tshData2[$0]) },
                    secondaryColor: .orange,
                    yAxisRange: calculateYAxisDomain(for: tshData1 + tshData2, title: "TSH"),
                    xAxisRange: effectiveXAxisRange,
                    showNormalRange: $showNormalRange
                )
            }
            .padding()
        }
        .navigationTitle("Dosing Simulation")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Helper Functions to Prevent Crashing
    
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

    
    /// **FIXED**: Safely calculates a dynamic range for an array of values, handling empty, single-value, and non-finite numbers.
    private func dynamicRange(for values: [Double]) -> ClosedRange<Double> {
        let finiteValues = values.filter { $0.isFinite }

        guard let minVal = finiteValues.min(), let maxVal = finiteValues.max() else {
            return 0.0...1.0
        }

        if minVal == maxVal {
            let buffer = abs(minVal * 0.5) > 0 ? abs(minVal * 0.5) : 1.0
            return (minVal - buffer)...(maxVal + buffer)
        }

        let buffer = (maxVal - minVal) * 0.1
        let lower = minVal - buffer
        let upper = maxVal + buffer
        let finalLower = (minVal >= 0 && lower < 0) ? 0 : lower

        return finalLower...upper
    }

    /// **FIXED**: Calculates the final Y-axis domain, combining the data range and normal range safely.
    private func calculateYAxisDomain(for values: [Double], title: String) -> ClosedRange<Double> {
        let dataRange = dynamicRange(for: values)

        guard showNormalRange, let normalRange = getNormalRange(for: title) else {
            return dataRange
        }

        let lowerBound = min(dataRange.lowerBound, normalRange.lowerBound)
        let upperBound = max(dataRange.upperBound, normalRange.upperBound)
        let padding = (upperBound - lowerBound) * 0.05
        let finalLower = lowerBound - padding
        let finalUpper = upperBound + padding

        if finalLower > finalUpper {
            return dataRange
        }

        return finalLower...finalUpper
    }
}
