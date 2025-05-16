import SwiftUI
import Charts

struct GraphSection: View {
    let title: String
    let yLabel: String
    let xLabel: String
    let values: [(Double, Double)]
    let color: Color

    @State private var currentXDomain: ClosedRange<Double>
    @State private var currentYDomain: ClosedRange<Double>

    private let initialXDomainCalculated: ClosedRange<Double>
    private let initialYDomainCalculated: ClosedRange<Double>

    // Optional: Define zoom limits
    private let minXRange: Double = 1.0
    private let minYRange: Double = 1.0
    private let maxXRange: Double
    private let maxYRange: Double

    init(title: String, yLabel: String, xLabel: String, values: [(Double, Double)], color: Color, yAxisRange: ClosedRange<Double>, xAxisRange: ClosedRange<Double>) {
        self.title = title
        self.yLabel = yLabel
        self.xLabel = xLabel
        self.values = values
        self.color = color

        self.initialYDomainCalculated = yAxisRange
        self.initialXDomainCalculated = xAxisRange

        _currentXDomain = State(initialValue: self.initialXDomainCalculated)
        _currentYDomain = State(initialValue: self.initialYDomainCalculated)

        self.maxXRange = xAxisRange.upperBound - xAxisRange.lowerBound
        self.maxYRange = yAxisRange.upperBound - yAxisRange.lowerBound
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            if values.isEmpty {
                Text("No data available for \(title).")
                    .italic()
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(height: 300)
            } else {
                Chart {
                    if let range = normalRange(for: title) {
                        RectangleMark(
                            xStart: .value("Start Time", initialXDomainCalculated.lowerBound),
                            xEnd: .value("End Time", initialXDomainCalculated.upperBound),
                            yStart: .value("Min Normal", range.lowerBound),
                            yEnd: .value("Max Normal", range.upperBound)
                        )
                        .foregroundStyle(Color.yellow.opacity(0.3))
                        .annotation(position: .topLeading, alignment: .leading, spacing: 2) {
                            Text("Normal Range")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
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
                .chartYScale(domain: currentYDomain)
                .chartXScale(domain: currentXDomain)
                .chartScrollableAxes([]) // We handle zoom/pan manually
                .contentShape(Rectangle())
                .chartXAxisLabel(xLabel, alignment: .center)
                .chartYAxisLabel(yLabel, alignment: .center)
                .chartXAxis {
                    AxisMarks(preset: .automatic, values: .automatic) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 3])).foregroundStyle(.gray.opacity(0.5))
                        AxisTick(stroke: StrokeStyle(lineWidth: 1)).foregroundStyle(Color(UIColor.label))
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text(doubleValue.formatted(.number.precision(.fractionLength(doubleValue.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 1))))
                                    .foregroundStyle(Color(UIColor.label))
                                    .font(.caption)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(preset: .automatic, position: .leading, values: .automatic) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 3])).foregroundStyle(.gray.opacity(0.5))
                        AxisTick(stroke: StrokeStyle(lineWidth: 1)).foregroundStyle(Color(UIColor.label))
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text(doubleValue.formatted(.number.precision(.significantDigits(3))))
                                    .foregroundStyle(Color(UIColor.label))
                                    .font(.caption)
                            }
                        }
                    }
                }
                .frame(height: 300)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                .padding(.horizontal, 5)
                .simultaneousGesture(
                    MagnificationGesture()
                        .onChanged { scale in
                            zoom(scale: scale)
                        }
                )
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            pan(translation: value.translation, width: 300, height: 300)
                        }
                )

                Button("Reset View") {
                    currentXDomain = initialXDomainCalculated
                    currentYDomain = initialYDomainCalculated
                }
                .font(.caption)
                .padding(.top, 4)
            }
        }
    }

    func zoom(scale: CGFloat) {
        guard scale != 1 else { return }

        let xMid = (currentXDomain.lowerBound + currentXDomain.upperBound) / 2
        let yMid = (currentYDomain.lowerBound + currentYDomain.upperBound) / 2

        let newXRange = max(minXRange, min(maxXRange, (currentXDomain.upperBound - currentXDomain.lowerBound) / scale))
        let newYRange = max(minYRange, min(maxYRange, (currentYDomain.upperBound - currentYDomain.lowerBound) / scale))

        currentXDomain = (xMid - newXRange / 2)...(xMid + newXRange / 2)
        currentYDomain = (yMid - newYRange / 2)...(yMid + newYRange / 2)
    }

    func pan(translation: CGSize, width: CGFloat, height: CGFloat) {
        let xRange = currentXDomain.upperBound - currentXDomain.lowerBound
        let yRange = currentYDomain.upperBound - currentYDomain.lowerBound

        let xShift = Double(translation.width) / Double(width) * xRange
        let yShift = -Double(translation.height) / Double(height) * yRange // Inverted

        currentXDomain = (currentXDomain.lowerBound + xShift)...(currentXDomain.upperBound + xShift)
        currentYDomain = (currentYDomain.lowerBound + yShift)...(currentYDomain.upperBound + yShift)
    }

    func normalRange(for hormone: String) -> ClosedRange<Double>? {
        switch hormone {
        case "T4": return 60.0...90.0
        case "T3": return 0.8...1.8
        case "TSH": return 0.5...4.0
        case "Free T4": return 9.0...23.0
        case "Free T3": return 2.3...4.2
        default: return nil
        }
    }
}
