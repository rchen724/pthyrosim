import SwiftUI
import Charts

struct SimulationGraphView: View {
    let result: ThyroidSimulationResult
    let simulationDurationDays: Int // New property to receive simulation days

    @State private var showFreeHormones: Bool = false

    var body: some View {
        // Calculate effectiveXAxisRange based on simulation results and duration
        let effectiveXAxisRange: ClosedRange<Double>
        if result.time.isEmpty {
            // If no time data (e.g., 0-day simulation), use 0 to simulationDurationDays
            // Ensure a minimal range if simulationDurationDays is 0
            let upper = Double(simulationDurationDays)
            effectiveXAxisRange = 0.0...(upper > 0.0 ? upper : 0.1)
        } else {
            // If time data exists, use its actual range
            let firstTime = result.time.first ?? 0.0
            // Use simulationDurationDays as a reliable upper bound if result.time.last is missing or inconsistent
            let lastTime = result.time.last ?? Double(simulationDurationDays)
            // Ensure the upper bound of the range is at least the simulation duration,
            // and also at least the last time point from data.
            let actualLastTime = max(lastTime, Double(simulationDurationDays))

            if firstTime < actualLastTime {
                effectiveXAxisRange = firstTime...actualLastTime
            } else {
                 // Handle case where firstTime might somehow be >= actualLastTime (e.g. single point data)
                effectiveXAxisRange = (actualLastTime - 0.1)...actualLastTime
            }
        }

        return List {
            Section {
                Toggle(isOn: $showFreeHormones) {
                    Text("Show Free Hormones")
                        .foregroundColor(.primary)
                }
                .padding(.horizontal)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
            }

            GraphSection(
                title: showFreeHormones ? "Free T4" : "T4",
                yLabel: showFreeHormones ? "FT4 (µg/L)" : "T4 (µg/L)",
                xLabel: "Days",
                values: result.time.indices.map {
                    (result.time[$0], showFreeHormones ? result.ft4[$0] : result.t4[$0])
                },
                color: showFreeHormones ? .purple : .blue,
                yAxisRange: dynamicRange(showFreeHormones ? result.ft4 : result.t4),
                xAxisRange: effectiveXAxisRange // Use the calculated effective range
            )
            .listRowInsets(EdgeInsets(top: 20, leading: 15, bottom: 20, trailing: 15))

            GraphSection(
                title: showFreeHormones ? "Free T3" : "T3",
                yLabel: showFreeHormones ? "FT3 (µg/L)" : "T3 (µg/L)",
                xLabel: "Days",
                values: result.time.indices.map {
                    (result.time[$0], showFreeHormones ? result.ft3[$0] : result.t3[$0])
                },
                color: showFreeHormones ? .orange : .green,
                yAxisRange: dynamicRange(showFreeHormones ? result.ft3 : result.t3),
                xAxisRange: effectiveXAxisRange // Use the calculated effective range
            )
            .listRowInsets(EdgeInsets(top: 20, leading: 15, bottom: 20, trailing: 15))

            GraphSection(
                title: "TSH",
                yLabel: "TSH (mU/L)",
                xLabel: "Days",
                values: result.time.indices.map { (result.time[$0], result.tsh[$0]) },
                color: .red,
                yAxisRange: dynamicRange(result.tsh),
                xAxisRange: effectiveXAxisRange // Use the calculated effective range
            )
            .listRowInsets(EdgeInsets(top: 20, leading: 15, bottom: 20, trailing: 15))

        }
        .navigationTitle("Simulation Results")
        .listStyle(.plain)
    }

    func dynamicRange(_ values: [Double]) -> ClosedRange<Double> {
        guard let minVal = values.min(), let maxVal = values.max(), minVal <= maxVal else {
            let defaultVal = values.first ?? 0.0
            return (defaultVal - 1)...(defaultVal + 1) // Provide a default range if data is empty or constant
        }
        if minVal == maxVal { // Handle constant data
            return (minVal - 1)...(maxVal + 1)
        }
        // Add a small buffer (e.g., 10%) to min and max for better visibility
        let buffer = (maxVal - minVal) * 0.1
        let effectiveBuffer = buffer > 0 ? buffer : 1.0 // Ensure buffer is not zero
        
        let lower = minVal - effectiveBuffer
        let upper = maxVal + effectiveBuffer
        // For hormone values, often good to ensure lower bound doesn't go significantly below zero if data is non-negative.
        // However, if minVal itself is negative, allow negative lower bound.
        return (minVal >= 0 && lower < 0 ? 0 : lower)...upper
    }
}
