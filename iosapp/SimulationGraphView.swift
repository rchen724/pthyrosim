import SwiftUI
import Charts

// MARK: - HormoneType Enum
private enum HormoneType: String, CaseIterable {
    case total = "Total"
    case free = "Free"
}

struct SimulationGraphView: View {
    let result: ThyroidSimulationResult
    let simulationDurationDays: Int

    // MARK: - State Variables
    @State private var selectedHormoneType: HormoneType = .total
    @State private var showNormalRange: Bool = true

    // MARK: - Data Preparation & Filtering
    
    /// **FIX 1: This is the key fix.**
    /// This function filters out any data points that are not finite, preventing crashes.
    private func filteredData(for values: [Double]) -> [(Double, Double)] {
        return zip(result.time, values)
            .filter { $0.1.isFinite }
    }

    private var t4GraphData: [(Double, Double)] {
        let sourceData = selectedHormoneType == .free ? result.ft4 : result.t4
        return filteredData(for: sourceData)
    }
    
    private var t3GraphData: [(Double, Double)] {
        let sourceData = selectedHormoneType == .free ? result.ft3 : result.t3
        return filteredData(for: sourceData)
    }

    private var tshGraphData: [(Double, Double)] {
        return filteredData(for: result.tsh)
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            // Set the background color to white
            Color.white.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Text("Euthyroid Simulation")
                        .font(.largeTitle).fontWeight(.bold).padding(.top)

                    // --- UI Controls ---
                    VStack(spacing: 15) {
                        Picker("Hormone Type", selection: $selectedHormoneType) {
                            ForEach(HormoneType.allCases, id: \.self) {
                                Text($0.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)

                        Toggle(isOn: $showNormalRange) {
                            Text("Show Normal Range")
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 10)

                    let effectiveXAxisRange: ClosedRange<Double> = 0...Double(max(1, simulationDurationDays))
                    
                    // --- T4 Graph ---
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
                    .chartYAxis { AxisMarks(position: .leading) }

                    // --- T3 Graph ---
                    GraphSection(
                        title: selectedHormoneType == .free ? "Free T3" : "T3",
                        yLabel: selectedHormoneType == .free ? "FT3 (pg/mL)" : "T3 (ng/dL)",
                        xLabel: "Days",
                        values: t3GraphData,
                        color: .green,
                        yAxisRange: calculateYAxisDomain(for: t3GraphData.map { $0.1 }, title: selectedHormoneType == .free ? "Free T3" : "T3"),
                        xAxisRange: effectiveXAxisRange,
                        showNormalRange: $showNormalRange
                    )
                    .chartYAxis { AxisMarks(position: .leading) }

                    // --- TSH Graph ---
                    GraphSection(
                        title: "TSH",
                        yLabel: "TSH (mU/L)",
                        xLabel: "Days",
                        values: tshGraphData,
                        color: .red,
                        yAxisRange: calculateYAxisDomain(for: tshGraphData.map { $0.1 }, title: "TSH"),
                        xAxisRange: effectiveXAxisRange,
                        showNormalRange: $showNormalRange
                    )
                    .chartYAxis { AxisMarks(position: .leading) }
                }
                .padding()
                .foregroundColor(.black)
            }
        }
        .navigationTitle("Euthyroid Simulation")
        .navigationBarTitleDisplayMode(.inline)
    }

     // MARK: - Helper Functions for Axis Range
    
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

    /// **FIX 2: This function is now safer**
    /// It calculates a dynamic range only from finite values.
    private func dynamicRange(for values: [Double]) -> ClosedRange<Double> {
        guard let minVal = values.min(), let maxVal = values.max() else {
            return 0...1
        }
        
        if minVal == maxVal {
            let buffer = abs(minVal * 0.1) > 0 ? abs(minVal * 0.1) : 1.0
            return (minVal - buffer)...(maxVal + buffer)
        }
        
        let buffer = (maxVal - minVal) * 0.1
        let lower = minVal - buffer
        let upper = maxVal + buffer
        
        return (minVal >= 0 && lower < 0 ? 0 : lower)...upper
    }

    private func calculateYAxisDomain(for values: [Double], title: String) -> ClosedRange<Double> {
        // Since the values are already filtered, this calculation is much safer.
        let dataRange = dynamicRange(for: values)
        
        if showNormalRange, let normalRange = getNormalRange(for: title) {
            let lowerBound = min(dataRange.lowerBound, normalRange.lowerBound)
            let upperBound = max(dataRange.upperBound, normalRange.upperBound)
            
            let padding = abs(upperBound - lowerBound) * 0.05
            
            return (lowerBound - padding)...(upperBound + padding)
        }
        
        return dataRange
    }
}
