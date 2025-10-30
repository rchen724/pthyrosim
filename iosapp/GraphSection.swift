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
    /// Parent-provided ranges (kept as hints); we’ll expand them to fit all series.
    let yAxisRange: ClosedRange<Double>
    let xAxisRange: ClosedRange<Double>
    let height: CGFloat
    let lineWidth: CGFloat
    let chartHeight: CGFloat
    @Binding var showNormalRange: Bool

    @State private var currentXDomain: ClosedRange<Double>
    @State private var currentYDomain: ClosedRange<Double>
    @State private var selectedDataPoint: (time: Double, value: Double)? = nil

    init(
        title: String, yLabel: String, xLabel: String,
        values: [(Double, Double)], color: Color,
        secondaryValues: [(Double, Double)]? = nil, secondaryColor: Color? = nil,
        tertiaryValues: [(Double, Double)]? = nil,   tertiaryColor: Color? = nil,
        yAxisRange: ClosedRange<Double>, xAxisRange: ClosedRange<Double>,
        height: CGFloat = 150,
        lineWidth: CGFloat = 1.2,
        showNormalRange: Binding<Bool>,
        chartHeight: CGFloat = 250
    ) {
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
        self.height = height
        self.lineWidth = lineWidth
        self.chartHeight = chartHeight

        // ---- Auto-expand domains to include ALL series (prevents Run 1 clipping) ----
        let combinedXMinMax = GraphSection.combinedMinMaxX(values: values, s: secondaryValues, t: tertiaryValues)
        let combinedYMinMax = GraphSection.combinedMinMaxY(values: values, s: secondaryValues, t: tertiaryValues)

        // Start X at 0 and extend to cover parent hint OR combined data (whichever is larger)
        let initialXUpper = max(xAxisRange.upperBound, combinedXMinMax.max ?? xAxisRange.upperBound)
        let initialXDomain: ClosedRange<Double> = 0...max(5, initialXUpper)

        // Y domain: expand parent hint to include all series; keep 0 baseline if below.
        let combinedYMin = min(yAxisRange.lowerBound, combinedYMinMax.min ?? yAxisRange.lowerBound)
        let combinedYMax = max(yAxisRange.upperBound, combinedYMinMax.max ?? yAxisRange.upperBound)
        let initialYLower = min(0, combinedYMin) // keep zero baseline visible
        let initialYUpper = max(initialYLower + 1, combinedYMax) // avoid zero span
        let initialYDomain: ClosedRange<Double> = initialYLower...initialYUpper

        _currentXDomain = State(initialValue: initialXDomain)
        _currentYDomain = State(initialValue: initialYDomain)
    }

    private static func combinedMinMaxX(
        values: [(Double, Double)],
        s: [(Double, Double)]?,
        t: [(Double, Double)]?
    ) -> (min: Double?, max: Double?) {
        var xs: [Double] = values.map { $0.0 }
        if let s = s { xs.append(contentsOf: s.map { $0.0 }) }
        if let t = t { xs.append(contentsOf: t.map { $0.0 }) }
        return (xs.min(), xs.max())
    }

    private static func combinedMinMaxY(
        values: [(Double, Double)],
        s: [(Double, Double)]?,
        t: [(Double, Double)]?
    ) -> (min: Double?, max: Double?) {
        var ys: [Double] = values.map { $0.1 }
        if let s = s { ys.append(contentsOf: s.map { $0.1 }) }
        if let t = t { ys.append(contentsOf: t.map { $0.1 }) }
        return (ys.min(), ys.max())
    }

    private var chartData: [ChartDataPoint] {
        var data: [ChartDataPoint] = []
        for (x, y) in values { data.append(.init(x: x, y: y, series: "Current")) }
        if let s = secondaryValues { for (x, y) in s { data.append(.init(x: x, y: y, series: "Secondary")) } }
        if let t = tertiaryValues  { for (x, y) in t { data.append(.init(x: x, y: y, series: "Tertiary")) } }
        return data
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title).font(.headline)
                Spacer()
                HStack(spacing: 6) {
                    Button { self.zoom(by: 1.25) } label: {
                        Image(systemName: "minus.magnifyingglass").font(.caption).foregroundColor(.secondary)
                    }
                    .buttonStyle(.borderless)
                    Button { self.zoom(by: 0.8) } label: {
                        Image(systemName: "plus.magnifyingglass").font(.caption).foregroundColor(.secondary)
                    }
                    .buttonStyle(.borderless)
                    Button { self.resetZoomAndPan() } label: {
                        Image(systemName: "arrow.uturn.backward.circle").font(.caption).foregroundColor(.secondary)
                    }
                    .buttonStyle(.borderless)
                }
            }
            .padding(.horizontal, 8)

            if values.isEmpty {
                ContentUnavailableView("No Data", systemImage: "chart.bar.xaxis.ascending")
                    .frame(height: height)
            } else {
                ZStack(alignment: .bottomTrailing) {
                    Chart {
                        if showNormalRange, let range = self.normalRange(for: title) {
                            RectangleMark(
                                xStart: .value("X Start", currentXDomain.lowerBound),
                                xEnd: .value("X End", currentXDomain.upperBound),
                                yStart: .value("Normal Min", range.lowerBound),
                                yEnd: .value("Normal Max", range.upperBound)
                            )
                            .foregroundStyle(Color.yellow.opacity(0.18))
                        }

                        ForEach(chartData) { p in
                            LineMark(x: .value(xLabel, p.x), y: .value(yLabel, p.y))
                                .foregroundStyle(by: .value("Series", p.series))
                                .lineStyle(by: .value("Series", p.series))
                        }

                        if let s = selectedDataPoint {
                            RuleMark(x: .value("Selected", s.time))
                                .foregroundStyle(Color.gray.opacity(0.6))
                                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                            PointMark(x: .value("Selected", s.time), y: .value("Value", s.value))
                                .symbolSize(CGSize(width: 6, height: 6))
                                .foregroundStyle(color)
                                .annotation(position: .top) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(String(format: "%@: %.2f", title, s.value))
                                        Text(String(format: "Day: %.2f", s.time))
                                    }
                                    .font(.caption2)
                                    .padding(6)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(6)
                                }
                        }
                    }
                    .chartForegroundStyleScale([
                        "Current": color,
                        "Secondary": (secondaryColor ?? .red.opacity(0.8)),
                        "Tertiary": (tertiaryColor ?? .purple.opacity(0.8))
                    ])
                    .chartLineStyleScale([
                        "Current": StrokeStyle(lineWidth: lineWidth),
                        "Secondary": StrokeStyle(lineWidth: max(0.9, lineWidth - 0.3)),
                        "Tertiary": StrokeStyle(lineWidth: max(0.8, lineWidth - 0.4))
                    ])
                    // Y: max 10 ticks
                    .chartYAxis {
                        AxisMarks(
                            position: .leading,
                            values: tickValues(for: currentYDomain, maxTicks: 10, forceZeroBaseline: true)
                        ) { _ in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.4, dash: [1, 1]))
                            AxisTick()
                            AxisValueLabel()
                        }
                    }
                    // X: max 10 ticks
                    .chartXAxis {
                        AxisMarks(
                            position: .bottom,
                            values: tickValues(for: currentXDomain, maxTicks: 10, forceZeroBaseline: false)
                        ) { _ in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.4, dash: [1, 1]))
                            AxisTick()
                            AxisValueLabel()
                        }
                    }
                    .chartXScale(domain: currentXDomain)
                    .chartYScale(domain: currentYDomain)
                    .chartPlotStyle { $0.clipped() }
                    .chartLegend(.hidden)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .chartOverlay { proxy in
                        GeometryReader { geo in
                            Rectangle().fill(.clear).contentShape(Rectangle())
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { updateSelectedDataPoint(at: $0.location, proxy: proxy, geometry: geo) }
                                        .onEnded { _ in selectedDataPoint = nil }
                                )
                        }
                    }
                    .frame(height: height)
                    .padding(.horizontal, 8)
                }
            }
        }
        // If the parent recomputes yAxisRange (e.g., after data update), re-expand to keep all lines visible
        .onChange(of: yAxisRange) { _, _ in
            let combinedY = GraphSection.combinedMinMaxY(values: values, s: secondaryValues, t: tertiaryValues)
            let minY = min(yAxisRange.lowerBound, combinedY.min ?? yAxisRange.lowerBound)
            let maxY = max(yAxisRange.upperBound, combinedY.max ?? yAxisRange.upperBound)
            currentYDomain = min(0, minY)...max(min(0, minY) + 1, maxY)
        }
    }

    // MARK: - Tick helpers (max 10)
    private func tickValues(for domain: ClosedRange<Double>, maxTicks: Int, forceZeroBaseline: Bool) -> [Double] {
        var lo = domain.lowerBound
        var hi = domain.upperBound
        if forceZeroBaseline { lo = min(0, lo) }

        let range = hi - lo
        guard range > 0, maxTicks > 1 else { return [lo] }

        let rawStep = range / Double(maxTicks - 1)
        let step = niceStep(rawStep)
        let niceLo = floor(lo / step) * step
        let niceHi = ceil(hi / step) * step

        var vals: [Double] = []
        var v = niceLo
        while v <= niceHi + step * 1e-6 {
            vals.append(v)
            v += step
        }
        if vals.count > maxTicks {
            let strideBy = Int(ceil(Double(vals.count) / Double(maxTicks)))
            vals = vals.enumerated().compactMap { idx, val in idx % strideBy == 0 ? val : nil }
        }
        return vals
    }

    private func niceStep(_ x: Double) -> Double {
        guard x.isFinite, x > 0 else { return 1 }
        let expv = floor(log10(x))
        let f = x / pow(10, expv) // 1..10
        let nf: Double
        if f < 1.5 { nf = 1 }
        else if f < 3 { nf = 2 }
        else if f < 7 { nf = 5 }
        else { nf = 10 }
        return nf * pow(10, expv)
    }

    // MARK: - Overlay & zoom
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
        // Rebuild union domains on reset as well
        let combinedX = GraphSection.combinedMinMaxX(values: values, s: secondaryValues, t: tertiaryValues)
        let combinedY = GraphSection.combinedMinMaxY(values: values, s: secondaryValues, t: tertiaryValues)

        let xUpper = max(xAxisRange.upperBound, combinedX.max ?? xAxisRange.upperBound)
        currentXDomain = 0...max(5, xUpper)

        let minY = min(yAxisRange.lowerBound, combinedY.min ?? yAxisRange.lowerBound)
        let maxY = max(yAxisRange.upperBound, combinedY.max ?? yAxisRange.upperBound)
        currentYDomain = min(0, minY)...max(min(0, minY) + 1, maxY)

        selectedDataPoint = nil
    }

    // MARK: - Normal ranges
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
