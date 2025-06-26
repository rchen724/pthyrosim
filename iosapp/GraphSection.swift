import SwiftUI
import Charts

struct GraphSection: View {
    let title: String
    let yLabel: String
    let xLabel: String

    // Primary data series (Run 1)
    let values: [(Double, Double)]
    let color: Color

    // Secondary data series (Run 2)
    let secondaryValues: [(Double, Double)]?
    let secondaryColor: Color?

    // Axis ranges
    let yAxisRange: ClosedRange<Double>
    let xAxisRange: ClosedRange<Double>

    @Binding var showNormalRange: Bool

    // State variables for zoom/pan
    @State private var currentXDomain: ClosedRange<Double>
    @State private var currentYDomain: ClosedRange<Double>
    @State private var gestureStartDomainX: ClosedRange<Double>?
    @State private var gestureStartDomainY: ClosedRange<Double>?
    @State private var currentMagnification: CGFloat = 1.0
    @State private var currentTranslation: CGSize = .zero

    private let minDomainSpanFactor: CGFloat = 0.01 // Max zoom in
    private let maxDomainSpanFactor: CGFloat = 20.0  // Max zoom out

    init(title: String, yLabel: String, xLabel: String, values: [(Double, Double)], color: Color, secondaryValues: [(Double, Double)]? = nil, secondaryColor: Color? = nil, yAxisRange: ClosedRange<Double>, xAxisRange: ClosedRange<Double>, showNormalRange: Binding<Bool>) {
        self.title = title
        self.yLabel = yLabel
        self.xLabel = xLabel
        self.values = values
        self.color = color
        self.secondaryValues = secondaryValues
        self.secondaryColor = secondaryColor
        self._showNormalRange = showNormalRange

        // --- FIX: Validate the incoming ranges to prevent crashes ---
        
        // 1. Correct the ranges if lowerBound > upperBound
        let correctedYAxisRange = (yAxisRange.lowerBound <= yAxisRange.upperBound) ? yAxisRange : (yAxisRange.upperBound...yAxisRange.lowerBound)
        let correctedXAxisRange = (xAxisRange.lowerBound <= xAxisRange.upperBound) ? xAxisRange : (xAxisRange.upperBound...xAxisRange.lowerBound)

        self.yAxisRange = correctedYAxisRange
        self.xAxisRange = correctedXAxisRange
        
        // 2. Ensure the ranges have a non-zero span for the chart view
        let finalYRange = (correctedYAxisRange.lowerBound < correctedYAxisRange.upperBound)
            ? correctedYAxisRange
            : (correctedYAxisRange.lowerBound...(correctedYAxisRange.lowerBound + 1.0))
        
        let finalXRange = (correctedXAxisRange.lowerBound < correctedXAxisRange.upperBound)
            ? correctedXAxisRange
            : (correctedXAxisRange.lowerBound...(correctedXAxisRange.lowerBound + 1.0))

        // 3. Initialize the state for zoom/pan
        _currentYDomain = State(initialValue: finalYRange)
        _currentXDomain = State(initialValue: finalXRange)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                if secondaryValues != nil {
                    HStack(spacing: 15) {
                        HStack(spacing: 4) {
                            Rectangle().frame(width: 15, height: 3).foregroundStyle(color)
                            Text("Run 1").font(.caption)
                        }
                        HStack(spacing: 4) {
                            Rectangle().frame(width: 15, height: 3).foregroundStyle(secondaryColor ?? .white)
                            Text("Run 2").font(.caption)
                        }
                    }
                }
                Button { resetZoomAndPan() } label: { Image(systemName: "arrow.uturn.backward.circle").font(.title3) }.buttonStyle(.borderless)
            }
            .padding(.horizontal)

            if values.isEmpty {
                ContentUnavailableView("No Data", systemImage: "chart.bar.xaxis.ascending")
                    .frame(height: 250)
            } else {
                ZStack(alignment: .bottomTrailing) {
                    GeometryReader { chartGeometry in
                        Chart {
                             if showNormalRange, let range = normalRange(for: title) {
                                 RectangleMark(
                                    xStart: .value("X Start", currentXDomain.lowerBound),
                                    xEnd: .value("X End", currentXDomain.upperBound),
                                    yStart: .value("Normal Min", range.lowerBound),
                                    yEnd: .value("Normal Max", range.upperBound)
                                 )
                                 .foregroundStyle(Color.yellow.opacity(0.2))
                             }

                            ForEach(Array(values.enumerated()), id: \.offset) { index, dataPoint in
                                // dataPoint is now the (time, value) tuple from your `values` array
                                LineMark(
                                    x: .value(xLabel, dataPoint.0), // Use dataPoint.0 for Time
                                    y: .value(yLabel, dataPoint.1)  // Use dataPoint.1 for Value
                                )
                                .foregroundStyle(color)
                                .interpolationMethod(.catmullRom)
                            }
                            
                            if let secondary = secondaryValues, let secColor = secondaryColor {
                                ForEach(Array(secondary.enumerated()), id: \.offset) { index, dataPoint in
                                    // dataPoint is the (time, value) tuple
                                    LineMark(
                                        x: .value(xLabel, dataPoint.0), // Use dataPoint.0 for Time
                                        y: .value(yLabel, dataPoint.1)  // Use dataPoint.1 for Value
                                    )
                                    .foregroundStyle(secColor)
                                    .interpolationMethod(.catmullRom)
                                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                                }
                            }
                        }
                        .chartXScale(domain: currentXDomain)
                        .chartYScale(domain: currentYDomain)
                        .chartPlotStyle { $0.clipped() }
                        .background(Color(UIColor.systemGray6)).cornerRadius(8)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    if gestureStartDomainX == nil {
                                        gestureStartDomainX = currentXDomain
                                        gestureStartDomainY = currentYDomain
                                    }
                                    currentTranslation = value.translation
                                    updateDomains(chartRenderSize: chartGeometry.size)
                                }
                                .onEnded { _ in gestureStartDomainX = nil; gestureStartDomainY = nil }
                                .simultaneously(with: MagnificationGesture()
                                    .onChanged { value in
                                        if gestureStartDomainX == nil {
                                            gestureStartDomainX = currentXDomain
                                            gestureStartDomainY = currentYDomain
                                        }
                                        currentMagnification = value
                                        updateDomains(chartRenderSize: chartGeometry.size)
                                    }
                                    .onEnded { _ in gestureStartDomainX = nil; gestureStartDomainY = nil }
                                )
                        )
                    }
                    .frame(height: 250).padding(.horizontal)
                    
                    HStack {
                        Button { zoom(by: 1.25) } label: { Image(systemName: "minus.magnifyingglass") }
                        Button { zoom(by: 0.8) } label: { Image(systemName: "plus.magnifyingglass") }
                    }
                    .font(.title2)
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
                    .padding([.trailing, .bottom], 10)
                    .buttonStyle(.borderless)
                }
            }
        }
        .onChange(of: values.count) {
            resetZoomAndPan()
        }
    }

    private func zoom(by scaleFactor: CGFloat) {
        let newXSpan = currentXDomain.span * scaleFactor
        let newYSpan = currentYDomain.span * scaleFactor
        
        currentXDomain = currentXDomain.zoomed(by: newXSpan)
        currentYDomain = currentYDomain.zoomed(by: newYSpan)
    }
    
    private func updateDomains(chartRenderSize: CGSize) {
        guard let xStart = gestureStartDomainX, let yStart = gestureStartDomainY else { return }
        
        let xTranslation = currentTranslation.width * (xStart.span / chartRenderSize.width)
        let yTranslation = -currentTranslation.height * (yStart.span / chartRenderSize.height)
        
        let newXLower = xStart.lowerBound - xTranslation
        let newYLower = yStart.lowerBound - yTranslation
        
        let newXSpan = xStart.span / currentMagnification
        let newYSpan = yStart.span / currentMagnification
        
        currentXDomain = newXLower...(newXLower + newXSpan)
        currentYDomain = newYLower...(newYLower + newYSpan)
    }

    private func resetZoomAndPan() {
        currentXDomain = xAxisRange
        currentYDomain = yAxisRange
    }
    
    func normalRange(for hormone: String) -> ClosedRange<Double>? {
        switch hormone {
        case "T4":
            return 50.0...120.0
        case "Free T4":
            return 10.0...25.0
        case "T3":
            return 0.8...1.8
        case "Free T3":
            return 2.3...4.2
        case "TSH":
            return 0.4...4.5
        default:
            return nil
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
