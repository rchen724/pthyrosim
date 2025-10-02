import SwiftUI
import Charts

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let x: Double
    let y: Double
    let series: String
}

struct GraphSection: View {
    let title: String
    let yLabel: String
    let xLabel: String
    let values: [(Double, Double)]
    let color: Color
    let secondaryValues: [(Double, Double)]?
    let secondaryColor: Color?
    let tertiaryValues: [(Double, Double)]?
    let tertiaryColor: Color?
    let yAxisRange: ClosedRange<Double>
    let xAxisRange: ClosedRange<Double>
    @Binding var showNormalRange: Bool
    @State private var currentXDomain: ClosedRange<Double>
    @State private var currentYDomain: ClosedRange<Double>
    @State private var gestureStartDomainX: ClosedRange<Double>?
    @State private var gestureStartDomainY: ClosedRange<Double>?
    @State private var currentMagnification: CGFloat = 1.0
    @State private var selectedDataPoint: (time: Double, value: Double)? = nil
    
    init(title: String, yLabel: String, xLabel: String, values: [(Double, Double)], color: Color, secondaryValues: [(Double, Double)]? = nil, secondaryColor: Color? = nil, tertiaryValues: [(Double, Double)]? = nil, tertiaryColor: Color? = nil, yAxisRange: ClosedRange<Double>, xAxisRange: ClosedRange<Double>, showNormalRange: Binding<Bool>) {
        self.title = title
        self.yLabel = yLabel
        self.xLabel = xLabel
        self.values = values
        self.color = color
        self.secondaryValues = secondaryValues
        self.secondaryColor = secondaryColor
        self.tertiaryValues = tertiaryValues
        self.tertiaryColor = tertiaryColor
        self._showNormalRange = showNormalRange
        self.yAxisRange = yAxisRange
        self.xAxisRange = xAxisRange
        _currentYDomain = State(initialValue: yAxisRange)
        _currentXDomain = State(initialValue: 0...max(5, xAxisRange.upperBound))
    }
    
    // Combined data for Chart
    private var chartData: [ChartDataPoint] {
        var data: [ChartDataPoint] = []
        
        // Add primary data
        for (x, y) in values {
            data.append(ChartDataPoint(x: x, y: y, series: "Current"))
        }
        
        // Add secondary data if available
        if let secondaryValues = secondaryValues {
            for (x, y) in secondaryValues {
                data.append(ChartDataPoint(x: x, y: y, series: "Secondary"))
            }
        }
        
        // Add tertiary data if available
        if let tertiaryValues = tertiaryValues {
            for (x, y) in tertiaryValues {
                data.append(ChartDataPoint(x: x, y: y, series: "Tertiary"))
            }
        }
        
        return data
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title).font(.headline)
                Spacer()
                // Zoom controls moved to top
                HStack(spacing: 8) {
                    Button { self.zoom(by: 1.25) } label: { 
                        Image(systemName: "minus.magnifyingglass")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.borderless)
                    
                    Button { self.zoom(by: 0.8) } label: { 
                        Image(systemName: "plus.magnifyingglass")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.borderless)
                    
                    Button { self.resetZoomAndPan() } label: { 
                        Image(systemName: "arrow.uturn.backward.circle")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.borderless)
                }
            }
            .padding(.horizontal)
            
            if values.isEmpty {
                ContentUnavailableView("No Data", systemImage: "chart.bar.xaxis.ascending").frame(height: 250)
            } else {
                ZStack(alignment: .bottomTrailing) {
                    Chart {
                        if showNormalRange, let range = self.normalRange(for: title) {
                            RectangleMark(
                               xStart: .value("X Start", currentXDomain.lowerBound),
                               xEnd: .value("X End", currentXDomain.upperBound),
                               yStart: .value("Normal Min", range.lowerBound),
                               yEnd: .value("Normal Max", range.upperBound)
                            ).foregroundStyle(Color.yellow.opacity(0.2))
                        }
                        
                        ForEach(chartData) { dataPoint in
                            LineMark(
                                x: .value(xLabel, dataPoint.x),
                                y: .value(yLabel, dataPoint.y)
                            )
                            .foregroundStyle(by: .value("Series", dataPoint.series))
                            .lineStyle(by: .value("Series", dataPoint.series))
                        }
                        
                        if let selectedDataPoint {
                            RuleMark(x: .value("Selected Time", selectedDataPoint.time))
                                .foregroundStyle(Color.gray.opacity(0.6))
                                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                            PointMark(
                                x: .value("Selected Time", selectedDataPoint.time),
                                y: .value("Selected Value", selectedDataPoint.value)
                            ).symbolSize(CGSize(width: 8, height: 8)).foregroundStyle(color)
                            .annotation(position: .top) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(String(format: "%@: %.2f", title, selectedDataPoint.value))
                                    Text(String(format: "Time: %.2f", selectedDataPoint.time))
                                }
                                .font(.caption).padding(6).background(Color(UIColor.systemGray5)).cornerRadius(6)
                            }
                        }
                    }
                    .chartForegroundStyleScale([
                        "Current": color,
                        "Secondary": secondaryColor ?? .orange,
                        "Tertiary": tertiaryColor ?? .green
                    ])
                    .chartLineStyleScale([
                        "Current": StrokeStyle(lineWidth: 4.0),
                        "Secondary": StrokeStyle(lineWidth: 3.0),
                        "Tertiary": StrokeStyle(lineWidth: 2.5)
                    ])
                    // --- AXIS FIXES ARE HERE ---
                    .chartYAxis {
                        // Use the new helper function to generate detailed grid lines
                        AxisMarks(position: .leading, values: generateAxisValues(for: currentYDomain, title: title)) {
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [1, 1]))
                            AxisTick()
                            AxisValueLabel()
                        }
                    }
                    .chartXAxis {
                        // Enhanced X-axis with better grid spacing
                        AxisMarks(position: .bottom, values: generateXAxisValues(for: currentXDomain)) {
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [1, 1]))
                            AxisTick()
                            AxisValueLabel()
                        }
                    }
                    .chartXScale(domain: currentXDomain)
                    .chartYScale(domain: currentYDomain)
                    .chartPlotStyle { $0.clipped() }
                    .chartLegend(.hidden)
                    .background(Color(UIColor.systemGray6)).cornerRadius(8)
                    .chartOverlay { proxy in
                        GeometryReader { geo in
                            Rectangle().fill(.clear).contentShape(Rectangle())
                                .gesture(DragGesture(minimumDistance: 0)
                                    .onChanged { updateSelectedDataPoint(at: $0.location, proxy: proxy, geometry: geo) }
                                    .onEnded { _ in selectedDataPoint = nil }
                                )
                        }
                    }
                    .frame(height: 250).padding(.horizontal)
                }
            }
        }
        .onChange(of: yAxisRange) { resetZoomAndPan() }
    }

    // --- HELPER FUNCTION TO GENERATE DETAILED AXIS VALUES ---
    private func generateAxisValues(for domain: ClosedRange<Double>, title: String) -> [Double] {
        let step: Double
        // Define the step size for each hormone to match the target images
        switch title {
            case "T4":      step = 10
            case "Free T4": step = 2
            case "T3":      step = 0.2
            case "Free T3": step = 0.5
            case "TSH":     step = 0.5
            default:        step = (domain.upperBound - domain.lowerBound) / 5.0
        }

        guard step > 0 else { return [domain.lowerBound] }
        
        // Create an array of values from 0 up to the domain's upper bound
        let values = Array(stride(from: 0, through: domain.upperBound, by: step))
        return values
    }
    
    // --- HELPER FUNCTION TO GENERATE X-AXIS VALUES ---
    private func generateXAxisValues(for domain: ClosedRange<Double>) -> [Double] {
        let range = domain.upperBound - domain.lowerBound
        let step: Double
        
        // Determine appropriate step size based on the range
        if range <= 1 {
            step = 0.1
        } else if range <= 5 {
            step = 0.5
        } else if range <= 10 {
            step = 1.0
        } else if range <= 30 {
            step = 2.0
        } else {
            step = 5.0
        }
        
        // Create an array of values from the domain's lower bound to upper bound
        let values = Array(stride(from: domain.lowerBound, through: domain.upperBound, by: step))
        return values
    }
    
    private func updateSelectedDataPoint(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        let xPos = location.x - geometry[proxy.plotAreaFrame].origin.x
        guard let time: Double = proxy.value(atX: xPos) else { return }
        
        var closestIndex: Int? = nil
        var minDistance: Double = .greatestFiniteMagnitude
        for i in values.indices {
            let d = abs(values[i].0 - time)
            if d < minDistance {
                minDistance = d
                closestIndex = i
            }
        }
        if let index = closestIndex { selectedDataPoint = values[index] }
    }
    
    private func zoom(by factor: CGFloat) {
        currentXDomain = currentXDomain.zoomed(by: currentXDomain.span * factor)
        currentYDomain = currentYDomain.zoomed(by: currentYDomain.span * factor)
    }
    
    private func resetZoomAndPan() {
        currentXDomain = 0...max(5, xAxisRange.upperBound)
        currentYDomain = yAxisRange
        selectedDataPoint = nil
    }
    
    func normalRange(for hormone: String) -> ClosedRange<Double>? {
        switch hormone {
        case "T4": return 50.0...120.0
        case "Free T4": return 8...18
        case "T3": return 0.8...1.8
        case "Free T3": return 2.3...4.2
        case "TSH": return 0.4...4.5
        default: return nil
        }
    }
}

extension ClosedRange where Bound: FloatingPoint {
    var span: Bound { upperBound - lowerBound }
    func zoomed(by newSpan: Bound) -> Self {
        let center = lowerBound + span / 2
        return (center - newSpan / 2)...(center + newSpan / 2)
    }
}
