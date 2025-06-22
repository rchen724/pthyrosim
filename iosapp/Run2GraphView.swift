import SwiftUI

struct Run2GraphView: View {
    let run1Result: ThyroidSimulationResult
    let run2Result: ThyroidSimulationResult
    let simulationDurationDays: Int

    @State private var showFreeHormones: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Run 1 vs. Run 2")
                    .font(.largeTitle).fontWeight(.bold).padding(.top)

                Toggle(isOn: $showFreeHormones) {
                    Text("Show Free Hormones")
                }.padding(.horizontal).toggleStyle(SwitchToggleStyle(tint: .blue))

                let effectiveXAxisRange: ClosedRange<Double> = 0...Double(max(1, simulationDurationDays))
                
                let t4Values1 = showFreeHormones ? run1Result.ft4 : run1Result.t4
                let t4Values2 = showFreeHormones ? run2Result.ft4 : run2Result.t4
                let t3Values1 = showFreeHormones ? run1Result.ft3 : run1Result.t3
                let t3Values2 = showFreeHormones ? run2Result.ft3 : run2Result.t3


                GraphSection(
                    title: showFreeHormones ? "Free T4" : "T4",
                    yLabel: showFreeHormones ? "FT4 (µg/L)" : "T4 (µg/L)",
                    xLabel: "Days",
                    values: run1Result.time.indices.map { (run1Result.time[$0], t4Values1[$0]) },
                    color: .blue,
                    secondaryValues: run2Result.time.indices.map { (run2Result.time[$0], t4Values2[$0]) },
                    secondaryColor: .purple,
                    yAxisRange: calculateYAxisDomain(for: t4Values1, and: t4Values2, title: showFreeHormones ? "Free T4" : "T4"),
                    xAxisRange: effectiveXAxisRange
                )

                GraphSection(
                    title: showFreeHormones ? "Free T3" : "T3",
                    yLabel: showFreeHormones ? "FT3 (µg/L)" : "T3 (µg/L)",
                    xLabel: "Days",
                    values: run1Result.time.indices.map { (run1Result.time[$0], t3Values1[$0]) },
                    color: .green,
                    secondaryValues: run2Result.time.indices.map { (run2Result.time[$0], t3Values2[$0]) },
                    secondaryColor: .orange,
                    yAxisRange: calculateYAxisDomain(for: t3Values1, and: t3Values2, title: showFreeHormones ? "Free T3" : "T3"),
                    xAxisRange: effectiveXAxisRange
                )

                GraphSection(
                    title: "TSH",
                    yLabel: "TSH (mU/L)",
                    xLabel: "Days",
                    values: run1Result.time.indices.map { (run1Result.time[$0], run1Result.tsh[$0]) },
                    color: .red,
                    secondaryValues: run2Result.time.indices.map { (run2Result.time[$0], run2Result.tsh[$0]) },
                    secondaryColor: .pink,
                    yAxisRange: calculateYAxisDomain(for: run1Result.tsh, and: run2Result.tsh, title: "TSH"),
                    xAxisRange: effectiveXAxisRange
                )
            }
            .padding()
        }
        .navigationTitle("Superimposed Results")
        .navigationBarTitleDisplayMode(.inline)
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

    private func calculateYAxisDomain(for run1Values: [Double], and run2Values: [Double], title: String) -> ClosedRange<Double> {
        let combinedData = run1Values + run2Values
        let dataRange = dynamicRange(for: combinedData)
        
        guard let normalRange = getNormalRange(for: title) else {
            return dataRange
        }
        
        let lowerBound = min(dataRange.lowerBound, normalRange.lowerBound)
        let upperBound = max(dataRange.upperBound, normalRange.upperBound)
        
        let padding = (upperBound - lowerBound) * 0.05
        
        return (lowerBound - padding)...(upperBound + padding)
    }
}
