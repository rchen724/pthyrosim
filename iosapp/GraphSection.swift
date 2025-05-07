import SwiftUI
import Charts

struct GraphSection: View {
    let title: String
    let yLabel: String
    let xLabel: String
    let values: [(Double, Double)]
    let color: Color
    let yAxisRange: ClosedRange<Double>
    let xAxisRange: ClosedRange<Double>?
    let xZoom: CGFloat
    let yZoom: CGFloat

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .foregroundColor(.black)
                .font(.headline)

            if values.isEmpty {
                Text("No data available for \(title).")
                    .italic()
                    .foregroundColor(.gray)
                    .padding()
            } else {
                Chart {
                    if let range = normalRange(for: title), values.count > 1 {
                        RectangleMark(
                            xStart: .value("Start", values.first!.0),
                            xEnd: .value("End", values.last!.0),
                            yStart: .value("Min", range.lowerBound),
                            yEnd: .value("Max", range.upperBound)
                        )
                        .foregroundStyle(Color.yellow.opacity(0.3))
                    }

                    ForEach(values, id: \.0) { time, value in
                        LineMark(
                            x: .value("Time", time),
                            y: .value("Value", value)
                        )
                        .foregroundStyle(color)
                        .interpolationMethod(.catmullRom)
                    }
                }
                .chartYScale(domain: scaledYRange())
                .chartXScale(domain: scaledXRange())
                .chartXAxisLabel(xLabel)
                .chartYAxisLabel(yLabel)
                .chartXAxis {
                    AxisMarks(position: .bottom)
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 250)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.gray.opacity(0.3), radius: 4, x: 0, y: 2)
            }
        }
    }

    func normalRange(for hormone: String) -> ClosedRange<Double>? {
        switch hormone {
        case "T4": return 60...90
        case "T3": return 0.8...1.8
        case "TSH": return 0.5...4.0
        default: return nil
        }
    }

    func scaledYRange() -> ClosedRange<Double> {
        let center = (yAxisRange.lowerBound + yAxisRange.upperBound) / 2
        let half = max((yAxisRange.upperBound - yAxisRange.lowerBound) / 2 / Double(yZoom), 0.05)
        return (center - half)...(center + half)
    }

    func scaledXRange() -> ClosedRange<Double> {
        guard let xRange = xAxisRange, values.count > 1 else {
            let fallback = values.first?.0 ?? 0.0
            return fallback...(fallback + 1.0)
        }
        let center = (xRange.lowerBound + xRange.upperBound) / 2
        let half = max((xRange.upperBound - xRange.lowerBound) / 2 / Double(xZoom), 0.05)
        return (center - half)...(center + half)
    }
}
