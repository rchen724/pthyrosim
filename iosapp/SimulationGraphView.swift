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
